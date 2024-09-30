local get_us_time = minetest.get_us_time

local s = afk_api.settings

afk_api.last_action_by_player_name = {}
afk_api.previous_player_state_by_player_name = {}

afk_api.registered_on_afks = {}
afk_api.registered_on_backs = {}

function afk_api.get_player_state(player)
	return {
		player:get_wield_index(),
		player:get_look_dir(),
		player:get_player_control_bits(),
	}
end

function afk_api.register_on_afk(def)
	def = table.copy(def)
	def.min_afk_time = def.min_afk_time or s.default_afk_time
	if def.period then
		def.elapsed_by_player_name = {}
	else
		def.is_afk_by_player_name = {}
	end
	table.insert(afk_api.registered_on_afks, def)
end

function afk_api.register_on_back(def)
	def = table.copy(def)
	def.min_afk_time = def.min_afk_time or s.default_afk_time
	table.insert(afk_api.registered_on_backs, def)
end

function afk_api.afk(player, now, elapsed_dtime)
	now = now or get_us_time() / 1e6
	elapsed_dtime = elapsed_dtime or 0
	local player_name = player:get_player_name()
	local last_action = afk_api.last_action_by_player_name[player_name]
	local afk_time = now - last_action
	local registered_on_afks = afk_api.registered_on_afks
	for i = 1, #registered_on_afks do
		local def = registered_on_afks[i]
		if afk_time >= def.min_afk_time then
			if def.period then
				local elapsed = def.elapsed_by_player_name[player_name]
				if elapsed == 0 then
					def.func(player, afk_time)
				end

				elapsed = elapsed + elapsed_dtime
				if elapsed >= def.period then
					def.elapsed_by_player_name[player_name] = 0
				else
					def.elapsed_by_player_name[player_name] = elapsed
				end
			elseif not def.is_afk_by_player_name[player_name] then
				def.is_afk_by_player_name[player_name] = true
				def.func(player, afk_time)
			end
		end
	end
end

function afk_api.back(player)
	local now = get_us_time() / 1e6
	local player_name = player:get_player_name()
	local last_action_by_player_name = afk_api.last_action_by_player_name
	local last_action = last_action_by_player_name[player_name]
	local afk_time = now - last_action
	local registered_on_backs = afk_api.registered_on_backs

	for i = 1, #registered_on_backs do
		local def = registered_on_backs[i]
		if afk_time >= def.min_afk_time then
			def.func(player, afk_time)
		end
	end

	last_action_by_player_name[player_name] = now

	local registered_on_afks = afk_api.registered_on_afks
	for i = 1, #registered_on_afks do
		local def = registered_on_afks[i]
		if def.is_afk_by_player_name then
			def.is_afk_by_player_name[player_name] = nil
		end
		if def.elapsed_by_player_name then
			def.elapsed_by_player_name[player_name] = 0
		end
	end
end

function afk_api.get_afk_time(player_or_name, now)
	local player_name
	if type(player_or_name) == "string" then
		player_name = player_or_name
	elseif futil.is_player(player_or_name) then
		player_name = player_or_name:get_player_name()
	else
		return
	end
	local last_action = afk_api.last_action_by_player_name[player_name]
	if last_action then
		now = now or get_us_time() / 1e6
		return now - last_action
	end
end

function afk_api.is_afk(player_or_name, min_afk_time, now)
	min_afk_time = min_afk_time or s.default_afk_time
	now = now or get_us_time() / 1e6
	local afk_time = afk_api.get_afk_time(player_or_name, now)
	if afk_time then
		return afk_time >= min_afk_time
	end
end

function afk_api.get_afk_players(min_afk_time, now)
	min_afk_time = min_afk_time or s.default_afk_time
	now = now or get_us_time() / 1e6
	local players = minetest.get_connected_players()
	local afk_players = {}
	for i = 1, #players do
		local player = players[i]
		local afk_time = afk_api.get_afk_time(player, now)
		if afk_time and afk_time >= min_afk_time then
			afk_players[#afk_players + 1] = player
		end
	end
	return afk_players
end

function afk_api.get_non_afk_players(min_afk_time, now)
	min_afk_time = min_afk_time or s.default_afk_time
	now = now or get_us_time() / 1e6
	local players = minetest.get_connected_players()
	local non_afk_players = {}
	for i = 1, #players do
		local player = players[i]
		local afk_time = afk_api.get_afk_time(player, now)
		if not afk_time or afk_time < min_afk_time then
			non_afk_players[#non_afk_players + 1] = player
		end
	end
	return non_afk_players
end

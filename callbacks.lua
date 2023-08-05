local get_us_time = minetest.get_us_time

local s = afk_api.settings

minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	afk_api.last_action_by_player_name[player_name] = get_us_time() / 1e6
	afk_api.previous_player_state_by_player_name[player_name] = afk_api.get_player_state(player)
	local registered_on_afks = afk_api.registered_on_afks
	for i = 1, #registered_on_afks do
		local def = registered_on_afks[i]
		if def.elapsed_by_player_name then
			def.elapsed_by_player_name[player_name] = 0
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	local player_name = player:get_player_name()
	afk_api.last_action_by_player_name[player_name] = nil
	afk_api.previous_player_state_by_player_name[player_name] = nil
	local registered_on_afks = afk_api.registered_on_afks
	for i = 1, #registered_on_afks do
		local def = registered_on_afks[i]
		if def.is_afk_by_player_name then
			def.is_afk_by_player_name[player_name] = nil
		end
		if def.elapsed_by_player_name then
			def.elapsed_by_player_name[player_name] = nil
		end
	end
end)

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
	if minetest.is_player(placer) then
		afk_api.back(placer)
	end
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
	if minetest.is_player(digger) then
		afk_api.back(digger)
	end
end)

minetest.register_on_punchnode(function(pos, node, puncher, pointed_thing)
	if minetest.is_player(puncher) then
		afk_api.back(puncher)
	end
end)

minetest.register_on_rightclickplayer(function(player, clicker)
	if minetest.is_player(clicker) then
		afk_api.back(clicker)
	end
end)

minetest.register_on_cheat(function(player, cheat)
	if minetest.is_player(player) then
		afk_api.back(player)
	end
end)

table.insert(minetest.registered_on_chat_messages, 1, function(name, message)
	local chatter = minetest.get_player_by_name(name)
	if chatter then
		afk_api.back(chatter)
	end
end)

table.insert(minetest.registered_on_chatcommands, 1, function(name, command, params)
	local chatter = minetest.get_player_by_name(name)
	if chatter then
		afk_api.back(chatter)
	end
end)

table.insert(minetest.registered_on_player_receive_fields, 1, function(player, formname, fields)
	if minetest.is_player(player) then
		afk_api.back(player)
	end
end)

table.insert(minetest.registered_on_crafts, 1, function(itemstack, player, old_craft_grid, craft_inv)
	if minetest.is_player(player) then
		afk_api.back(player)
	end
end)

minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if minetest.is_player(player) then
		afk_api.back(player)
	end
end)

minetest.register_on_protection_violation(function(pos, name)
	local violator = minetest.get_player_by_name(name)
	if violator then
		afk_api.back(violator)
	end
end)

table.insert(
	minetest.registered_on_item_eats,
	1,
	function(hp_change, replace_with_item, itemstack, eater, pointed_thing)
		if minetest.is_player(eater) then
			afk_api.back(eater)
		end
	end
)

table.insert(minetest.registered_on_item_pickups, 1, function(itemstack, picker, pointed_thing, time_from_last_punch)
	if minetest.is_player(picker) then
		afk_api.back(picker)
	end
end)

futil.register_globalstep({
	name = "afk_api:check_state",
	period = s.check_state_period,
	func = function(elapsed_dtime)
		local now = get_us_time() / 1e6
		local players = minetest.get_connected_players()
		for i = 1, #players do
			local player = players[i]
			local player_name = player:get_player_name()
			local previous_state = afk_api.previous_player_state_by_player_name[player_name]
			local current_state = afk_api.get_player_state(player)
			if futil.equals(previous_state, current_state) then
				afk_api.afk(player, now, elapsed_dtime)
			else
				afk_api.previous_player_state_by_player_name[player_name] = current_state
				afk_api.back(player)
			end
		end
	end,
})

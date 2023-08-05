local f = string.format
local S = afk_api.S
local s = afk_api.settings

minetest.register_chatcommand("afk_check", {
	description = S("get AFK status of connected players"),
	params = S("[<min afk time>]"),
	privs = { server = true },
	func = function(name, param)
		local now = minetest.get_us_time() / 1e6
		local min_afk_time = tonumber(param) or s.default_afk_time
		local players = minetest.get_connected_players()
		if #players == 0 then
			return false, S("no-one connected")
		end
		local max_name_len = #players[1]:get_player_name()
		table.sort(players, function(a, b)
			local a_name = a:get_player_name()
			local b_name = b:get_player_name()
			max_name_len = math.max(max_name_len, #a_name, #b_name)
			return a_name:lower() < b_name:lower()
		end)
		for i = 1, #players do
			local player = players[i]
			local player_name = player:get_player_name()
			local afk_time = afk_api.get_afk_time(player, now)
			local time_string = futil.seconds_to_interval(afk_time)
			local message = f(f("%%-%ds%%s", max_name_len + 1), player_name, time_string)
			if afk_time >= min_afk_time then
				minetest.chat_send_player(name, minetest.colorize("red", message))
			else
				minetest.chat_send_player(name, message)
			end
		end
	end,
})

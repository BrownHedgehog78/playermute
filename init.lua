local storage = minetest.get_mod_storage()
local muted_players = {}
if storage:contains("muted_players") then
  muted_players = minetest.deserialize(storage:get_string("muted_players"))
end

minetest.register_chatcommand("mute", {
	description = "Mute a player",
	params = "[<playername>]",
	privs = {kick = true},
	func = function(name, param, n)
		local player = minetest.get_player_by_name(param)
		if not player then return false, param .. " is not online or does not exist!" end
		local admin = core.settings:get("name")
		if param == admin then return false, "You mute can't the admin!"
		elseif param == name then return false, "You can't mute yourself!" end
		muted_players[param] = true
		minetest.chat_send_player(name, "Muted " .. param .. ".")
		minetest.chat_send_player(param, "You were muted by " .. name .. ".")
	end
})

minetest.register_chatcommand("unmute", {
	description = "Unmute a player",
	params = "[<playername>]",
        privs = {kick = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(param)
		local privs = minetest.get_player_privs(param)
		minetest.set_player_privs(param, privs)
		minetest.get_player_by_name(name)
			if param == name then
			minetest.chat_send_player(name, "You can't unmute yourself!")
			elseif player then
			muted_players[param] = false
			minetest.chat_send_player(name, "Unmuted " .. param .. ".")
			minetest.chat_send_player(param, "You were unmuted by " .. name .. ".")
			elseif not player then
			minetest.chat_send_player(name, param .. " is not online or does not exist!")
		end
	end
})

minetest.register_on_chat_message(function(name, n)
	if muted_players[name] then
		minetest.chat_send_player(name, "You're muted so you can't talk")
		return true
	end
end)

minetest.register_on_shutdown(function()
  storage:set_string("muted_players", minetest.serialize(muted_players))
end)

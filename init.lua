local storage = minetest.get_mod_storage()
local muted = {}
if storage:contains("muted_players") then
	muted = minetest.deserialize(storage:get_string("muted_players"))
end

minetest.register_chatcommand("mute", {
	description = "Mutes a player",
	params = "<playername>",
	privs = {kick = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(param)
		local admin = core.settings:get("name")
		if muted[param] == true then
			return false, "Player " .. param .. " is already muted"
		end

		if param == admin or minetest.check_player_privs(param, {antimute = true}) then
			return false, "You can't mute this player"
		elseif param == name then
			return false, "You can't mute yourself"
		elseif not minetest.player_exists(param) then
			return false, "Player " .. param .. " does not exist"
		else
			muted[param] = true
			minetest.chat_send_player(name, "Muted " .. param)
			if player then
				minetest.chat_send_player(param, "You were muted by " .. name)
			end
		end
	end
})

minetest.register_chatcommand("unmute", {
	description = "Unmutes a player",
	params = "<playername>",
	privs = {kick = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(param)
		if muted[param] ~= true then
			return false, "Player " .. param .. " is not muted"
		end

		if param == name then
			return false, "You can't unmute yourself"
		elseif not minetest.player_exists(param) then
			return false, "Player " .. param .. " does not exist"
		else
			muted[param] = nil
			minetest.chat_send_player(name, "Unmuted " .. param)
			if player then
				minetest.chat_send_player(param, "You were unmuted by " .. name)
			end
		end
	end
})

minetest.register_on_chat_message(function(name)
	if muted[name] == true then
		minetest.chat_send_player(name, "You're muted, you can't talk")
		return true
	end
end)

minetest.register_on_chatcommand(function(name, command)
	if command == "msg" and muted[name] == true then
		minetest.chat_send_player(name, "You can't send private messages, you're muted")
		return true
	end
end)

minetest.register_on_shutdown(function()
	storage:set_string("muted_players", minetest.serialize(muted))
end)

-- 'antimute' Privilege
minetest.register_privilege("antimute", "Players who have it, can't be muted")

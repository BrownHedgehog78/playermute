playermute = {}
local storage = minetest.get_mod_storage()
local muted = {}
if storage:contains("muted_players") then
	muted = minetest.deserialize(storage:get_string("muted_players"))
end

function playermute.is_muted(name)
	return muted[name] ~= nil
end

-- Commands for muting/unmuting players (only their accounts)

minetest.register_chatcommand("p_mute", {
	description = "Mutes a player",
	params = "<playername>",
	privs = {pmute = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(param)
		if playermute.is_muted(param) then
			return false, "Player " .. param .. " is already muted"
		end

		if minetest.check_player_privs(param, {antimute = true}) then
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

minetest.register_chatcommand("p_unmute", {
	description = "Unmutes a player",
	params = "<playername>",
	privs = {pmute = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(param)
		if not playermute.is_muted(param) then
			return false, "Player " .. param .. " is not muted"
		end

		if param == name then
			return false, "You can't unmute yourself"
		else
			muted[param] = nil
			minetest.chat_send_player(name, "Unmuted " .. param)
			if player then
				minetest.chat_send_player(param, "You were unmuted by " .. name)
			end
		end
	end
})

-- Override 'msg' command

minetest.register_on_chatcommand(function(name, command, params)
	if command ~= "msg" then
		return
	end

	if playermute.is_muted(name) and not minetest.check_player_privs(name, {antimute = true}) then
		minetest.chat_send_player(name, "You're muted, you can't use this command")
		return true
	end
end)

-- Functions

minetest.register_on_chat_message(function(name)
	if playermute.is_muted(name) and not minetest.check_player_privs(name, {antimute = true}) then
		minetest.chat_send_player(name, "You're muted, you can't talk")
		return true
	end
end)

local function save()
	storage:set_string("muted_players", minetest.serialize(muted))
end
minetest.register_on_shutdown(save)

-- Save every 15 minutes
local function safe_after()
	safe()
	minetest.after(60 * 15,safe_after())
end
minetest.after(60 * 15,safe_after())

-- Privileges

minetest.register_privilege("antimute", "Players who have it can't be muted")
minetest.register_privilege("pmute", "Players with this privilege can mute players")

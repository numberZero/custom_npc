-- Helpers

local function get_name(object)
	if not object then
		return "<nothing>"
	end
	if object:is_player() then
		return object:get_player_name()
	end
	local ent = object:get_luaentity()
	return ent and ent.name or "<something>"
end

local function get_nameref(object)
	if not object then
		return "<nothing> <nowhere>"
	end
	return string.format("%s at %s", get_name(object), minetest.pos_to_string(object:getpos()))
end

local function speak(pos, loudness, message)
	local players = {}
	local objs = minetest.get_objects_inside_radius(pos, loudness)
	for _, obj in ipairs(objs) do
		if obj:is_player() then
			players[obj:get_player_name()] = true
		end
	end
	players[""] = nil
	for player, _ in pairs(players) do
		minetest.chat_send_player(player, message)
	end
end

local function shout()
end

local function whisper()
end

local function hexrandom(bytes)
	local result = ""
	for i = 1, bytes do
		result = result .. string.format("%02x", math.random(0, 255))
	end
	return result
end

-- NPC definition

local npc = {
	name = "custom_npc:npc",
}

setmetatable(npc, {
	__call = function(npc, pos, ...) -- constructor
		local obj = minetest.add_entity(pos, npc.name)
		if not obj then
			return nil
		end
		local self = obj:get_luaentity()
		npc.initialize(self, ...)
		self.initialized = true
	end,
})

function npc.initialize(self, params)
	self.info = {
		owner = params.owner and tostring(params.owner) or nil,
		name = params.name and tostring(params.name) or string.format("NPC_%s", hexrandom(4)),
	}
end

function npc.restore(self, data)
	self.info = {
		owner = data.owner,
		name = data.name,
	}
end

function npc.hibernate(self)
	return {
		owner = self.info.owner,
		name = self.info.name
	}
end

function npc.on_rightclick(self, clicker)
	local player = clicker:get_player_name()
	if player and player ~= "" then
		minetest.chat_send_player(player, "Entity data: " .. dump(self:hibernate()))
	end
end

function npc.on_step(self, dtime)
-- self: LuaEntity
-- dtime: number
	local mypos = vector(self.object:getpos())
	if self.follow then
-- self.object: ObjectRef
-- self.follow: ObjectRef
		local hispos = vector(self.follow:getpos())
		if not hispos then
			minetest.log("action", string.format("Lost target"))
			self.follow = nil
			return
		end
		local dir = hispos - mypos
		local d = dir:length()
		local v = self.object:getvelocity()
		if d < 3 then
			minetest.log("action", string.format("custom_npc: %s: Target reached: %s", self.info.name, get_nameref(self.follow)))
			local player = self.follow:is_player() and self.follow:get_player_name()
			speak(mypos, 8, string.format("[%s]: Got you %s!", self.info.name, get_name(self.follow)))
			self.follow:punch(self.object, 1.0, minetest.registered_items["default:sword_steel"].tool_capabilities, dir / d)
			self.object:setvelocity({x=0, y=v.y, z=0})
			self.follow = nil
			self.sleep = 2
			minetest.log("action", string.format("Sleeping for %d seconds", self.sleep))
		else
			dir = (2 / d) * dir
			self.object:setvelocity(vector(dir.x, v.y, dir.z))
			self.object:setyaw(vector.yaw(dir))
		end
	else
		if self.sleep and self.sleep > 0 then
			self.sleep = self.sleep - dtime
			return
		end
		local objs = minetest.get_objects_inside_radius(mypos, 16)
		local targets = {}
		for _,obj in ipairs(objs) do
-- 			local ent = obj:get_luaentity()
-- 			if obj:is_player() or (ent and ent.name ~= "custom_npc:npc") then
			if obj ~= self.object then
				table.insert(targets, obj)
			end
		end
		local i = math.random(#targets)
		self.follow = targets[i]
		if self.follow then
			minetest.log("action", string.format("New target: %s", get_nameref(self.follow)))
			local player = self.follow:is_player() and self.follow:get_player_name()
			if player and player ~= "" then
				minetest.chat_send_player(player, string.format("(%s): I see you }:->", self.info.name))
			end
		else
			minetest.log("action", string.format("Can’t find new target (%d options)", #targets))
		end
	end
	self.object:setacceleration({x=0, y=-10, z=0})
end

custom_npc.npc = npc

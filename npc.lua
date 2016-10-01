-- Helpers

local moves = custom_npc.moves
local G = custom_npc.GRAVITY
local G_VEC = custom_npc.GRAVITY_VECTOR

local function get_name(object)
	if not object then
		return "<nothing>"
	end
	local ent = object:get_luaentity()
	local name = object:is_player() and object:get_player_name() or ent and ent.info and ent.info.name or ""
	local category = object:is_player() and ":player" or ent and ent.name or ":unknown"
	return string.format("%s (%s)", name, category)
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
	self.phys = {
		mass = params.mass or 20,
		jump_height = params.jump_height or 1.125,
	}
	self.object:set_properties({
		weight = self.phys.mass
	})
	moves.stop(self)
end

function npc.restore(self, data)
	self:initialize(data)
--[[
	self.info = {
		owner = data.owner,
		name = data.name,
	}
]]
end

function npc.hibernate(self)
	return {
		owner = self.info.owner,
		name = self.info.name
	}
end

function npc.get_feet_pos(self)
	return self.object:getpos() - self.origin_offset
end

function npc.get_jump_height(self)
	return self.phys.jump_height
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
			self.follow = nil
			return
		end
		local dir = hispos - mypos
		local d = dir:length()
		local v = self.object:getvelocity()
		if d < 3 then
			local player = self.follow:is_player() and self.follow:get_player_name()
			speak(mypos, 8, string.format("[%s]: Got you %s!", self.info.name, get_name(self.follow)))
			self.follow:punch(self.object, 1.0, minetest.registered_items["default:sword_steel"].tool_capabilities, dir / d)
			self.object:setvelocity({x=0, y=v.y, z=0})
			self.follow = nil
			self.sleep = 2
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
			if obj ~= self.object then
				table.insert(targets, obj)
			end
		end
		local i = math.random(#targets)
		self.follow = targets[i]
		if self.follow then
			local player = self.follow:is_player() and self.follow:get_player_name()
			if player and player ~= "" then
				minetest.chat_send_player(player, string.format("(%s): I see you }:->", self.info.name))
			end
		end
	end
	if math.random() < 0.1 * dtime then
		self.move:jump()
	end
	self.object:setacceleration(G_VEC)
end

custom_npc.npc = npc

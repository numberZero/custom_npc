local LOG_ACTION = "action"
local PATH = minetest.get_modpath("custom_npc")

dofile(PATH.."/vector.lua")

local function get_name(object)
	if not object then
		return "<nothing>"
	end
	if object:is_player() then
		return object:get_player_name()
	else
		return object:get_luaentity().name
	end
end

local function get_nameref(object)
	if not object then
		return "<nothing> <nowhere>"
	end
	return string.format("%s at %s", get_name(object), minetest.pos_to_string(object:getpos()))
end

local function on_activate(self, staticdata)
--	self.object:set_properties({visual_size = {x=1, y=2}})
	local data = minetest.deserialize(staticdata)
	if not data then
		data = {
			name = string.format("NPC_%04X", math.random(0, 65535))
		}
	end
	self.info = {
		name = data.name
	}
	self.get_name = get_name
end

local function get_staticdata(self)
	return minetest.serialize({
		name = self.info.name
	})
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

local npc = {
}

setmetatable(npc, {
	__call = function(self) -- constructor
	end,
})

local function shout()
end

local function whisper()
end

local function on_step(self, dtime)
-- self: LuaEntity
-- dtime: number
	local mypos = vector(self.object:getpos())
	if self.follow then
-- self.object: ObjectRef
-- self.follow: ObjectRef
		local hispos = vector(self.follow:getpos())
		if not hispos then
			minetest.log(LOG_ACTION, string.format("Lost target"))
			self.follow = nil
			return
		end
		local dir = hispos - mypos
		local d = dir:length()
		local v = self.object:getvelocity()
		if d < 4 then
			minetest.log(LOG_ACTION, string.format("custom_npc: %s: Target reached: %s", self.info.name, get_nameref(self.follow)))
			local player = self.follow:is_player() and self.follow:get_player_name()
			speak(mypos, 8, string.format("[%s]: Got you %s!", self.info.name, get_name(self.follow)))
			self.object:setvelocity({x=0, y=v.y, z=0})
			self.follow = nil
			self.sleep = 2
			minetest.log(LOG_ACTION, string.format("Sleeping for %d seconds", self.sleep))
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
			local ent = obj:get_luaentity()
			if obj:is_player() or (ent and ent.name ~= "custom_npc:npc") then
				table.insert(targets, obj)
			end
		end
		local i = math.random(#targets)
		self.follow = targets[i]
		if self.follow then
			minetest.log(LOG_ACTION, string.format("New target: %s", get_nameref(self.follow)))
			local player = self.follow:is_player() and self.follow:get_player_name()
			if player and player ~= "" then
				minetest.chat_send_player(player, string.format("(%s): I see you }:->", self.info.name))
			end
		else
			minetest.log(LOG_ACTION, string.format("Can’t find new target (%d options)", #targets))
		end
	end
	self.object:setacceleration({x=0, y=-10, z=0})
end

minetest.register_entity("custom_npc:npc", {
	initial_properties = {
		hp_max = 10,
		physical = true,
		weight = 5,
		collisionbox = {-0.45,-0.90,-0.45, 0.45,0.90,0.45},
		visual = "cube",
		visual_size = {x=0.75, y=1.80, z=0.50},
		textures = {
			"default_cobble.png",
			"default_stone.png",
			"default_bronze_block.png",
			"default_bronze_block.png",
			"default_gold_block.png",
			"default_bronze_block.png",
		},
		is_visible = true,
		makes_footstep_sound = true,
	},
	on_activate = on_activate,
	on_step = on_step,
	get_staticdata = get_staticdata,
})
--[[
local time = 0
minetest.register_globalstep(function(dtime)
	local objs = minetest.get_objects_inside_radius({x=0, y=8, z=0}, 5)
	for _,obj in ipairs(objs) do
		local ent = obj:get_luaentity()
		if ent and ent.name == "custom_npc:npc" then
			return
		end
	end
	time = time + dtime
	if time < 5 then
		return
	end
	time = 0
	local obj = minetest.add_entity({x=0, y=12, z=0}, "custom_npc:npc")
	if obj then
		obj:setacceleration({x=0, y=-10, z=0})
	end
end)
]]

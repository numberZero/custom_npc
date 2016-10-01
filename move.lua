local moves = {}
local G = custom_npc.GRAVITY
local G_VEC = custom_npc.GRAVITY_VECTOR

local function dummy()
end

local function get_ground(feet_pos)
	local node_under_pos = vector.round(feet_pos - vector(0.0, 0.1, 0.0))
	local node_under_def = minetest.registered_nodes[minetest.get_node(node_under_pos).name]
	return node_under_def
end

local function have_ground(feet_pos)
	local ground = get_ground(feet_pos)
	return not ground or ground.walkable
end

local function can_jump_from(feet_pos)
	local ground = get_ground(feet_pos)
	return not ground or ground.walkable and not ground.groups.disable_jump
end

local function jump(self)
	if not can_jump_from(self.npc:get_feet_pos()) then
		return false
	end
	local vel = self.npc.object:getvelocity()
	if math.abs(vel.y) > 0.3 then
		return false
	end
	self.npc.object:setvelocity(vel + vector(0, math.sqrt(2 * G * self.npc:get_jump_height()), 0))
	return true
end

local function walk(self, dtime)
	local mypos = self.npc.object:getpos()
	local dir = self.target - mypos
	local d = dir:length()
	local v = self.npc.object:getvelocity()
	if d < self.eps then
		moves.stop(self.npc)
		self.on_reach(self.npc, self.target, d)
	else
		dir.y = 0
		dir = (2 / dir:length()) * dir
		self.npc.object:setvelocity(vector(dir.x, v.y, dir.z))
		self.npc.object:setyaw(vector.yaw(dir))
	end
end

function moves.stop(npc)
	local self = {
		npc = npc,
		mode = "stop",
		anim = { "stand", "mine" },
		on_step = dummy,
		jump = jump,
	}
	npc.move = self
	npc.object:setvelocity({x=0, y=0, z=0})
	return self
end

function moves.walk(npc, to, eps, on_reach)
	assert(to, "Can't walk to nowhere")
	local self = {
		npc = npc,
		mode = "walk",
		anim = { "walk", "walk_mine" },
		on_step = walk,
		jump = jump,
		target = vector(to),
		eps = eps or 1.5,
		on_reach = on_reach or dummy,
	}
	npc.move = self
	return self
end

function moves.climb(npc)
	return moves.stop(npc)
end

custom_npc.moves = moves

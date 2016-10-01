local moves = {}
local G = custom_npc.GRAVITY
local G_VEC = custom_npc.GRAVITY_VECTOR

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

moves.base = custom_npc.class({
	_constructor = function(self, npc)
		self.npc = npc
		npc.move = self
	end,
	on_step = function(self, dtime)
	end,
	jump = function(self)
	end,
})

moves.jumping = custom_npc.class({
	_constructor = function(self, npc)
		moves.base._constructor(self, npc)
	end,
	can_jump = function(self, threshold)
		if not can_jump_from(self.npc:get_feet_pos()) then
			return false
		end
		local vel = self.npc.object:getvelocity()
		if math.abs(vel.y) > (threshold or 0.1) then
			return false
		end
		return true
	end,
	get_jump_vel = function(self, height)
		return vector(0, math.sqrt(2 * G * (height or self.npc:get_jump_height())), 0)
	end,
})

moves.stop = custom_npc.class({
	_parent = moves.jumping,
	mode = "stop",
	anim = { "stand", "mine" },
	_constructor = function(self, npc)
		moves.jumping._constructor(self, npc)
		local vel = vector(npc.object:getvelocity())
		npc.object:setvelocity({x=0, y=0, z=0})
	end,
	jump = function(self)
		if not self:can_jump(0.1) then
			return false
		end
		self.npc.object:setvelocity(self:get_jump_vel())
		return true
	end,
})

moves.walk = custom_npc.class({
	_parent = moves.jumping,
	mode = "walk",
	anim = { "walk", "walk_mine" },
	_constructor = function(self, npc, to, eps)
		moves.jumping._constructor(self, npc)
		self.target = to.getpos and to:getpos() or vector(to)
		self.eps = eps or 1.5
	end,
	jump = function(self)
		if not self:can_jump(0.5) then
			return false
		end
		self.npc.object:setvelocity(vel + self:get_jump_vel())
		return true
	end,
	on_step = function(self, dtime)
	end,
})

custom_npc.moves = moves

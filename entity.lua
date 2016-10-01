local npc = custom_npc.npc

local npc_entity = {
	initial_properties = {
		hp_max = 20,
		armor_groups = {punch_operable=1},
		physical = true,
		weight = 10,
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
}

setmetatable(npc_entity, {
	__index = npc,
})

function npc_entity.on_activate(self, staticdata)
	minetest.log("info", "Activating entity. Static data: “"..staticdata.."”")
	if staticdata ~= "" then
		local data = minetest.deserialize(staticdata)
		if not data then
			minetest.log("error", "Can’t restore entity properly. Static data: “"..staticdata.."”")
			self.object:remove()
			return false
		end
		self:restore(data)
	end
end

function npc_entity.get_staticdata(self)
	return minetest.serialize(self:hibernate())
end

function npc_entity.on_step(self, dtime)
	if not self.initialized then
		minetest.log("warning", "Entity was not properly initialized; default-initializing")
		self:initialize()
	end
	npc.on_step(self, dtime)
end

minetest.register_entity(npc.name, npc_entity)

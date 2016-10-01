local npc = custom_npc.npc

local npc_entity = {
	initial_properties = {
		hp_max = 20,
		physical = true,
		weight = 10,
		collisionbox = {-0.45,-0.90,-0.45, 0.45,0.90,0.45},
		visual = "mesh",
		mesh = "3d_armor_18.b3d",
		textures = {
			"multiskin_18.png",
			"multiskin_trans.png",
			"multiskin_trans.png",
			"multiskin_trans.png",
		},
		is_visible = true,
		makes_footstep_sound = true,
	},
	initialized = false,
	origin_offset = vector(0.0, 0.90, 0.0),
}

setmetatable(npc_entity, {
	__index = npc,
})

function npc_entity.on_activate(self, staticdata)
	minetest.log("info", "Activating entity. Static data: <<"..staticdata..">>")
	if staticdata ~= "" then
		local data = minetest.deserialize(staticdata)
		if not data then
			minetest.log("error", "Can't restore entity properly; removing. Static data: <<"..staticdata..">>")
			self.object:remove()
			return false
		end
		self:restore(data)
		self.initialized = true
	end
end

function npc_entity.get_staticdata(self)
	if not self.initialized then
		minetest.log("warning", "Serializing non-initialized entity")
		return ""
	end
	return minetest.serialize(self:hibernate())
end

function npc_entity.on_step(self, dtime)
	if not self.initialized then
		minetest.log("error", "Entity was not properly initialized; removing")
		self.object:remove()
		return
	end
	npc.on_step(self, dtime)
end

minetest.register_entity(npc.name, npc_entity)

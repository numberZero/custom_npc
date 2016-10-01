custom_npc.GRAVITY = 9.81
custom_npc.GRAVITY_VECTOR = vector(0, -custom_npc.GRAVITY, 0)

local function default_constructor()
-- this function is intentionally empty
end

function custom_npc.class(def)
	local meta = {
		__index = def
	}
	if not def._constructor then
		def._constructor = default_constructor
	end
	local function new(self, ...)
		local instance = {}
		setmetatable(instance, meta)
		result = self._constructor(instance, ...)
		if result == nil then
			return instance
		end
		return result
	end
	setmetatable(def, {
		__index = def._parent,
		__call = new,
	})
	return def
end

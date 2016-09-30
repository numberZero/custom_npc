local vector_meta = {}
local vector_proto = {}
vector_meta.__index = vector_proto

-- helper

local function from_xyz(x, y, z)
	local v = {x=x, y=y, z=z}
	setmetatable(v, vector_meta)
	return v
end

-- operators

function vector_meta.__add(a, b)
	return from_xyz(a.x + b.x, a.y + b.y, a.z + b.z)
end

function vector_meta.__sub(a, b)
	return from_xyz(a.x - b.x, a.y - b.y, a.z - b.z)
end

function vector_meta.__mul(a, b) -- number-vector or scalar vector-vector product
	if type(a) == "number" then
		return from_xyz(a * b.x, a * b.y, a * b.z)
	end
	if type(b) == "number" then
		return from_xyz(b * a.x, b * a.y, b * a.z)
	end
	return a.x * b.x + a.y * b.y + a.z * b.z
end

function vector_meta.__div(a, b) -- vector-by-number division
	assert(type(b) == "number", "Invalid vector division")
	b = 1 / b
	return from_xyz(a.x * b, a.y * b, a.z * b)
end

function vector_meta.__pow(a, b) -- component-wise product
	return from_xyz(a.x * b.x, a.y * b.y, a.z * b.z)
end

function vector_meta.__eq(a, b)
	return vector.equals(a, b)
end

function vector_meta.__unm(a)
	return from_xyz(-a.x, -a.y, -a.z)
end

function vector_meta.__tostring(a)
	return string.format("(%.3f, %.3f, %.3f)", a.x, a.y, a.z)
end

-- prototype

vector_proto.is_vector = true
vector_proto.constructor = vector

function vector_proto.length(self)
	return vector.length(self)
end

function vector_proto.square(self)
	return vector.square(self)
end

-- constructor

vector.prototype = vector_proto

setmetatable(vector, {
	__call = function(self, a, b, c)
		if not a then
			return from_xyz(0, 0, 0)
		end
		if type(a) == "table" then
			assert(a.x and a.y and a.z, "Invalid vector passed to vector()")
			return from_xyz(a.x, a.y, a.z)
		end
		assert(b and c, "Invalid arguments for vector()")
		return from_xyz(a, b, c)
	end,
})

-- standalone versions

function vector.new(...)
	return vector(...)
end

-- function vector.move(a)
-- 	if a.is_vector then
-- 		return a
-- 	end
-- 	assert(type(a) == "table" and a.x and a.y and a.z, "Invalid arguments for vector.move()")
-- 	return from_xyz(a.x, a.y, a.z)
-- end

function vector.yaw(a)
	return -math.atan2(a.x, a.z)
end

function vector.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

function vector.square(a)
	return a.x * a.x + a.y * a.y + a.z * a.z
end

function vector.cross(a, b)
	return from_xyz(
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x
	)
end

function vector.dot_2d(a, b)
	return a.x * b.x + a.z * b.z
end

function vector.det_2d(a, b)
	return a.x * b.z - a.z * b.x
end

function vector.square_2d(a)
	return a.x * a.x + a.z * a.z
end

function vector.cross_2d(a)
	return from_xyz(-a.z, 0.0, a.x)
end

function vector.angle_3d(a, b)
	return math.acos(vector.dot(a, b) / math.sqrt(vector.square(a) * vector.square(b)))
end

function vector.angle_2d(a, b)
	return math.acos(vector.dot_2d(a, b) / math.sqrt(vector.square_2d(a) * vector.square_2d(b)))
end

function vector.oriented_angle_2d(a, b)
	return math.asin(vector.det_2d(a, b) / math.sqrt(vector.square_2d(a) * vector.square_2d(b)))
end

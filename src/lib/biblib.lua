---@alias directions "up"|"down"|"left"|"right"|"w"|"s"|"a"|"d"
local vec = require("lib.vector")
local biblib = {
	directions = { vec.new(1, 0), vec.new(-1, 0), vec.new(0, 1), vec.new(0, -1) },
	---@param direction directions | Vector.lua
	---@return "up"|"down"|"left"|"right"
	---@return Vector.lua
	dirVec = function(direction)
		local name
		local vector
		if direction == vec.new(0, -1) or direction == "up" or direction == "w" then
			name = "up"
			vector = vec.new(0, -1)
		elseif direction == vec.new(0, 1) or direction == "down" or direction == "s" then
			name = "down"
			vector = vec.new(0, 1)
		elseif direction == vec.new(-1, 0) or direction == "left" or direction == "a" then
			name = "left"
			vector = vec.new(-1, 0)
		elseif direction == vec.new(1, 0) or direction == "right" or direction == "d" then
			name = "right"
			vector = vec.new(1, 0)
		end
		return name, vector
	end,
	getTableKeys = function(t, includeMeta)
		local keys = {}
		for k, _ in pairs(t) do
			if includeMeta or k:sub(0, 1) ~= "_" then
				table.insert(keys, k)
			end
		end
		return keys
	end,
	shallowCopy = function(orig)
		local orig_type = type(orig)
		local copy
		if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in pairs(orig) do
				copy[orig_key] = orig_value
			end
		else -- number, string, boolean, etc
			copy = orig
		end
		return copy
	end,
	lerp = function(a, b, t) return a * (1 - t) + b * t end
}
function biblib.cookieCutter(source, form, out)
	out = out or false
	local result = {}
	for i, v1 in pairs(source) do
		local hit = false
		for _, v2 in pairs(form) do
			if v1 == v2 then
				hit = true
				break
			end
		end
		if hit == out then
			result[#result + 1] = v1
		end
	end
	return result
end

function biblib.addIfNotPresent(t, value)
	for _, candidate in ipairs(t) do
		if candidate == value then
			return false
		end
	end
	t[#t + 1] = value
	return true
end

function biblib.equals(a, b)
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return a == b
	end

	local keySet = {}

	for key1, value1 in pairs(a) do
		local value2 = b[key1]
		if value2 == nil then
			return false
		end
		local result = biblib.equals(value1, value2)
		if result == false then
			return false
		end
		keySet[key1] = true
	end

	for key2, _ in pairs(b) do
		if not keySet[key2] then return false end
	end
	return true
end

function biblib.sign(number)
	return number > 0 and 1 or (number == 0 and 0 or -1)
end

---@param low number
---@param n number
---@param high number
---@return number
function biblib.clamp(low, n, high)
	return math.min(math.max(n, low), high)
end

return biblib

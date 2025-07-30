---@alias directions "up"|"down"|"left"|"right"|"w"|"s"|"a"|"d"
local vec = require("lib.vector")
return {
	---@param direction directions
	---@return Vector.lua
	dirVec = function(direction)
		local vector
		if direction == "up" or direction == "w" then
			vector = vec.new(0, -1)
		elseif direction == "down" or direction == "s" then
			vector = vec.new(0, 1)
		elseif direction == "left" or direction == "a" then
			vector = vec.new(-1, 0)
		elseif direction == "right" or direction == "d" then
			vector = vec.new(1, 0)
		end
		return vector
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

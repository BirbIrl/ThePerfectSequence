---@alias codes "g"|"w"|"p"|"b"
local vec = require "lib.vector"
local Entity = require "entity"
local serpent = require "lib.serpent"
local Grid = require("grid")
---@class Loader.lua
local loader = {}
loader.levelData = {}
function loader:reload(index)
	print(index)
	loader.levelData[index] = require("levels." .. index)
end

local filenames = love.filesystem.getDirectoryItems("levels")
table.sort(filenames)
for index, level in ipairs(filenames) do
	loader:reload(index)
end

---@param code string
---@return tileTypes
---@return entityTypes[]
function loader:parse(code)
	---@type tileTypes
	local tile = "void"
	local entities = {}
	---@type codes[]
	local letters = { code:match((code:gsub(".", "(.)"))) }
	for _, letter in ipairs(letters) do
		if letter == "g" then
			tile = "ground"
		elseif letter == "w" then
			tile = "wall"
		elseif letter == "p" then
			entities[#entities + 1] = "player"
		elseif letter == "b" then
			entities[#entities + 1] = "box"
		end
	end
	return tile, entities
end

function loader:load(index)
	local grid = Grid.new()
	for y, row in ipairs(self.levelData[index]) do
		for x, code in ipairs(row) do
			local pos = vec.new(x, y)
			local tileType, entityTypes = self:parse(code)
			grid:setTile(pos, tileType)
			for _, entityType in ipairs(entityTypes) do
				Entity.new(grid:getTile(pos), entityType)
			end
		end
	end
	return grid
end

return loader

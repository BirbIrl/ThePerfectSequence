--[[
return {
	{ "", "", "", "", "", "", "", "" },
	{ "", "", "", "", "", "", "", "" },
	{ "", "", "", "", "", "", "", "" },
	{ "", "", "", "", "", "", "", "" },
	{ "", "", "", "", "", "", "", "" },
	{ "", "", "", "", "", "", "", "" },
	{ "", "", "", "", "", "", "", "" },
	{ "", "", "", "", "", "", "", "" },
}
--]]
---@alias codes "g"|"w"|"p"|"b"
local vec = require "lib.vector"
local Entity = require "entity"
local serpent = require "lib.serpent"
local Grid = require("grid")
---@class Loader.lua
local loader = {}
loader.levelData = {}
function loader:reload(index)
	loader.levelData[index] = require("levels." .. index)
end

local filenames = love.filesystem.getDirectoryItems("levels")
table.sort(filenames)
for index, level in ipairs(filenames) do
	local levelNum = tonumber(level:sub(0, -5))
	if levelNum then
		loader:reload(levelNum)
	end
end

---@param code string
---@return tileTypes
---@return {name:entityTypes,data: table }[]
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
		elseif letter == "P" then
			entities[#entities + 1] = { name = "player" }
		elseif letter == "B" then
			entities[#entities + 1] = { name = "box" }
		elseif letter == "G" then
			entities[#entities + 1] = { name = "glass" }
		elseif tonumber(letter) then
			entities[#entities + 1] = { name = "teleporter", data = { link = tonumber(letter) } }
		end
	end
	return tile, entities
end

function loader:load(index)
	local grid = Grid.new()
	local level = self.levelData[index]
	if not level then
		error("game attempted to load level: levels/" .. index .. ".lua, but couldn't find it")
	end
	for y, row in ipairs(self.levelData[index]) do
		for x, code in ipairs(row) do
			local pos = vec.new(x, y)
			local tileType, entityTypes = self:parse(code)
			grid:setTile(pos, tileType)
			for _, entityType in ipairs(entityTypes) do
				Entity.new(grid:getTile(pos), entityType.name, entityType.data)
			end
		end
	end
	return grid
end

return loader

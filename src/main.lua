---@diagnostic disable-next-line: lowercase-global
lurker = require "lib.lurker"
local bib = require "lib.biblib"
local entity = require "entity"
local vec = require "lib.vector"
local loader = require "loader"
local field1 = loader:load(1)

function love.load()

end

function love.update()
	lurker.update()
end

function lurker.postswap(file)
	if file:sub(0, 6) == "levels" then
		local index = file:sub(8, -5)
		loader:reload(index)
	end
end

---@diagnostic disable-next-line: duplicate-set-field
function love.draw()
	field1:draw()
end

---@diagnostic disable-next-line: duplicate-set-field
function love.keypressed(key)
	local movement = bib.dirVec(key)
	if movement then
		field1:step(movement)
	end
	if key == "r" then
		lurker.hotswapfile("main.lua")
	end
end

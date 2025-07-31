---@diagnostic disable-next-line: lowercase-global
lurker = require "lib.lurker"
serpent = require "lib.serpent"
function sprint(table)
	print(serpent.block(table))
end

Loader = require "loader"
local Gamestate = require("gamestate")
local bib = require "lib.biblib"
local entity = require "entity"
local vec = require "lib.vector"
local gamestate = Gamestate.new(2, 1)
function love.load()

end

function love.update()
	lurker.update()
end

function lurker.postswap(file)
	if file:sub(0, 6) == "levels" then
		local index = file:sub(8, -5)
		Loader:reload(index)
		gamestate:restart()
	end
end

---@diagnostic disable-next-line: duplicate-set-field
function love.draw()
	love.graphics.push()
	for _, grid in ipairs(gamestate.grids) do
		grid:draw()
		love.graphics.translate(200, 0)
	end
	local inputsAll = ""
	local inputs = ""
	for i, input in ipairs(gamestate.inputs) do
		if gamestate.moveCount >= i then
			inputs = inputs .. " " .. input
		end
		inputsAll = inputsAll .. " " .. input
	end
	love.graphics.setColor(1, 1, 1, 0.5)
	local x = 10
	local y = 600
	love.graphics.pop()
	love.graphics.printf(inputsAll, x, y, love.graphics.getWidth() - x, "left")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(inputs, x, y, love.graphics.getWidth() - x, "left")
end

---@diagnostic disable-next-line: duplicate-set-field
function love.keypressed(key)
	local directionName = bib.dirVec(key)
	if directionName then
		gamestate:step(directionName, true)
	elseif key == "q" then
		gamestate:backwards()
	elseif key == "e" then
		gamestate:forward()
	elseif key == "c" and love.keyboard.isDown("lctrl") then
		love.system.setClipboardText(serpent.serialize(gamestate.inputs,
			{ nocode = true, sparse = true, comment = false, }))
	elseif key == "v" and love.keyboard.isDown("lctrl") then
		local worked, inputs = serpent.load("return " .. love.system.getClipboardText())
		if worked then
			gamestate.inputs = inputs
			gamestate.moveCount = #inputs
			gamestate:restart()
		end
	elseif key == "r" then
		lurker.hotswapfile("main.lua")
	end
end

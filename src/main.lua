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
--- DEV ZONE ---
--- levels named [number].lua are loaded from the `./levels/` folder, you can load the chosen one using the number below
--- the level live-updates when you save it's file, and reloads the game replaying all inputs to reach the same point you're in
local level = 3 -- which level to load?
local depth = 2 -- how many previous levels should this display in parallel? (only 0/1 works well for now)
---
local gamestate = Gamestate.new(level, depth)
function love.load()
	love.keyboard.setKeyRepeat(true)
end

local keyCooldown = 0
---@type love.KeyConstant?
local keyCooldownKey = nil
function love.update(dt)
	if keyCooldown > 0 then
		keyCooldown = keyCooldown - dt
		if keyCooldown < 0 then
			keyCooldown = 0
		end
	end
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
		love.graphics.translate(104, 0)
	end
	local message =
	"\nUse q/e to go back/forward in time, shift+q/e to go to the beginning/end of a set of inputs and r to hard restart\nUse: ctrl+c/ctrl+v to copy inputs to clipboard\nThe game realods and replays your inputs whenver you update a level file, open up your editor with any levels/[num].lua file on another monitor\nCheck main.lua for level selection\n\ninputs: "
	local inputs = message
	for i, input in ipairs(gamestate.inputs) do
		if gamestate.moveCount >= i then
			inputs = inputs .. input .. " "
		end
		message = message .. input .. " "
	end
	love.graphics.setColor(1, 1, 1, 0.5)
	local x = 10
	local y = 600
	love.graphics.pop()
	love.graphics.printf(message, x, y, love.graphics.getWidth() - x, "left")
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(inputs, x, y, love.graphics.getWidth() - x, "left")
end

---@diagnostic disable-next-line: duplicate-set-field
function love.keypressed(key, _, isRepeat)
	local directionName = bib.dirVec(key)
	if not isRepeat or keyCooldownKey ~= key or keyCooldown == 0 then
		if directionName then
			gamestate:step(directionName, true)
		elseif key == "e" or (key == "y" and love.keyboard.isDown("lctrl")) or (key == "z" and love.keyboard.isDown("lctrl") and love.keyboard.isDown("lshift")) then
			gamestate:forward()
		elseif key == "q" or key == "backspace" or (key == "z" and love.keyboard.isDown("lctrl")) then
			gamestate:backwards()
		end

		keyCooldown = 0.08
		keyCooldownKey = key
	end
	if not isRepeat then
		if key == "e" and love.keyboard.isDown("lshift") then
			gamestate:moveToInput(#gamestate.inputs)
			gamestate.moveCount = #gamestate.inputs
		elseif key == "q" and love.keyboard.isDown("lshift") then
			gamestate:moveToInput(0)
			gamestate.moveCount = 0
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
end

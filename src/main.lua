---@diagnostic disable-next-line: lowercase-global
lurker = require "lib.lurker"
serpent = require "lib.serpent"
function sprint(table)
	print(serpent.block(table))
end

Loader = require "loader"
local Gamestate = require("gamestate")
local bib = require "lib.biblib"
local colors = require "lib.colors"
local entity = require "entity"
local vec = require "lib.vector"
--- DEV ZONE ---
--- levels named [number].lua are loaded from the `./levels/` folder, you can load the chosen one using the number below
--- the level live-updates when you save it's file, and reloads the game replaying all inputs to reach the same point you're in
local level = 2  -- which level to load?
local depth = 1  -- how many previous levels should this display in parallel? (only 0/1 works well for now)
local extra = {} -- levels you always want to be loaded as preview
---
-- levels on which you wanna run checks
local checks = Gamestate.new(0, 0, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 })
function love.load()
	gamestate = Gamestate.new(level, depth, extra)

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
	if gamestate.extra ~= extra then
		gamestate.extra = extra
		gamestate:reload()
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
	{ { 1, 1, 1, 1 },
		"\nUse q/e to go back/forward in time, shift+q/e to go to the beginning/end of a set of inputs and r to hard restart\nUse: ctrl+c/ctrl+v to copy inputs to clipboard\nThe game reloads and replays your inputs whenver you update a level file, open up your editor with any levels/[num].lua file on another monitor\nCheck main.lua for level selection\n\ninputs: " }
	for i, input in ipairs(gamestate.inputs) do
		if gamestate.moveCount == i - 1 then
			message[#message + 1] = { 1, 1, 1, 0.5 }
			message[#message + 1] = ""
		end
		message[#message] = message[#message] .. input .. " "
	end
	if checks then
		message[#message + 1] = { 1, 1, 1, 1 }
		local statuses = checks:status()
		message[#message + 1] = "\n\nChecks:"
		for _, status in ipairs(statuses) do
			message[#message + 1] = { 1, 1, 1, 1 }
			message[#message + 1] = "\nLevel " .. status.id .. ": "
			if status.state == "running" then
				message[#message + 1] = { 1, 1, 1, 1 }
			elseif status.state == "failed" then
				message[#message + 1] = colors.list["Red"]
			elseif status.state == "success" then
				message[#message + 1] = colors.list["Green"]
			end

			message[#message + 1] = status.state
		end
	end
	local x = 10
	local y = 600
	love.graphics.pop()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(message, x, y, love.graphics.getWidth() - x, "left")
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
		elseif key == "r" and love.keyboard.isDown("lshift") then
			lurker.hotswapfile("main.lua")
			gamestate:restart(true)
		elseif key == "r" then
			lurker.hotswapfile("main.lua")
			gamestate.moveCount = 0
			gamestate:restart()
		end
	end
	if checks then
		checks.inputs = gamestate.inputs
		checks.moveCount = #gamestate.inputs
		checks:moveToInput(gamestate.moveCount)
	end
end

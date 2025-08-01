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
local sprites = require "sprites"
local entity = require "entity"
local vec = require "lib.vector"
local keyPreview = require "keyPreview"
--- DEV ZONE ---
--- levels named [number].lua are loaded from the `./levels/` folder, you can load the chosen one using the number below
--- the level live-updates when you save it's file, and reloads the game replaying all inputs to reach the same point you're in
local level = 0          -- which level to load?
local depth = 0          -- how many previous levels should this display in parallel? (only 0/1 works well for now)
local extra = { 15, 16 } -- levels you always want to be loaded as preview
--local extra = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 } -- millions must load
---
-- levels on which you wanna run checks
--local checks = Gamestate.new(0, 0, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 })

local chroma = love.graphics.newShader("assets/shaders/chroma.vert")
chroma:send("elapsed", love.timer.getTime())
local scan = love.graphics.newShader("assets/shaders/scan.vert")
function love.load()
	sw = love.graphics.getWidth()
	sh = love.graphics.getHeight()
	gamestate = Gamestate.new(level, depth, extra)
	mainCanvas = love.graphics.newCanvas(sw, sh)
	bounceCanvas = love.graphics.newCanvas(sw, sh)

	love.graphics.setDefaultFilter("nearest", "nearest")
	love.keyboard.setKeyRepeat(true)
end

local keyCooldown = 0
---@type love.KeyConstant?
local keyCooldownKey = nil
local timer = 0
function love.update(dt)
	if keyCooldown > 0 then
		keyCooldown = keyCooldown - dt
		if keyCooldown < 0 then
			keyCooldown = 0
		end
	end
	lurker.update()
	gamestate:update(dt)
	timer = timer + dt
	keyPreview:update(gamestate, dt)
	chroma:send("elapsed", love.timer.getTime())
	scan:send("phase", love.timer.getTime())
	--print(timer)
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
	love.graphics.setCanvas(bounceCanvas)
	love.graphics.setBlendMode("alpha")
	love.graphics.setColor(18 / 256, 32 / 256, 32 / 256)
	love.graphics.rectangle("fill", 0, 0, sw, sh)
	love.graphics.setCanvas(mainCanvas)
	love.graphics.clear()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(bounceCanvas, 0, 0)
	local gridCount = #gamestate.grids
	local scale
	local wrap
	local lines
	if gridCount == 1 then
		scale = 3
		wrap = 1
		lines = 1
	elseif gridCount < 3 then
		scale = 3
		wrap = 2
		lines = 1
	elseif gridCount < 7 then
		scale = 2
		wrap = 3
		lines = 2
	elseif gridCount < 10 then
		scale = 1.5
		wrap = 3
		lines = 3
	else
		scale = 1
		wrap = 4
		lines = 4
	end
	local grids = gamestate.grids
	local gridSize = grids[1].size
	local paddingW = (sw - (wrap) * gridSize * scale - scale * gridSize / 9) / 2
	local paddingH = (sh - (lines) * gridSize * scale - scale * gridSize / 9) / (8 / lines)
	for i, grid in ipairs(grids) do
		grid:draw(((i - 1) % wrap) * gridSize * scale + paddingW,
			(math.floor((i - 1) / wrap)) * gridSize * scale + paddingH,
			scale)
	end
	local message =
	{ { 1, 1, 1, 1 }, "FPS: " .. love.timer.getFPS() ..
	"\nUse q/e to go back/forward in time, shift+q/e to go to the beginning/end of a set of inputs and r to hard restart\nUse: ctrl+c/ctrl+v to copy inputs to clipboard\nThe game reloads and replays your inputs whenver you update a level file, open up your editor with any levels/[num].lua file on another monitor\nCheck main.lua for level selection" }
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
	local y = 10 + sh
	love.graphics.setBlendMode("alpha")
	keyPreview:draw(gamestate)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.printf(message, x, y, love.graphics.getWidth() - x, "left")
	love.graphics.setCanvas(bounceCanvas)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.setShader(chroma)
	love.graphics.draw(mainCanvas)
	love.graphics.setCanvas()
	love.graphics.setShader(scan)
	love.graphics.draw(bounceCanvas)
	chroma:send("alphaStuff", true)
	love.graphics.setShader(chroma)
	love.graphics.draw(sprites.ui.frame, 0, 0)
	chroma:send("alphaStuff", false)
	love.graphics.setShader()
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

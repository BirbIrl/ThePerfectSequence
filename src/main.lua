---@diagnostic disable-next-line: lowercase-global
lurker = require "lib.lurker"
serpent = require "lib.serpent"
function sprint(table)
	print(serpent.block(table))
end

--TODO:
--music
--wall texture
--endgame
--rewind shader
--boot on/off
--sound
--itch.io page, windows build
Loader = require "loader"
local Gamestate = require("gamestate")
local bib = require "lib.biblib"
local colors = require "lib.colors"
sprites = require "assetIndex".sprites
local entity = require "entity"
local vec = require "lib.vector"
local keyPreview = require "keyPreview"
local font = love.graphics.newFont("assets/fonts/TerminessNerdFont-Bold.ttf", 128)
local song = require "assetIndex".songs.stuck
local enableShaders = true
local depth
--- DEV ZONE ---
--- levels named [number].lua are loaded from the `./levels/` folder, you can load the chosen one using the number below
--- the level live-updates when you save it's file, and reloads the game replaying all inputs to reach the same point you're in
local level = 14 -- which level to load?
local extra = {} -- levels you always want to be loaded as preview
--local extra = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 } -- millions must load
---
-- levels on which you wanna run checks
--local checks = Gamestate.new(0, 0, { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 })
if level == 1 then
	depth = 0
else
	depth = 1
end

local chroma = love.graphics.newShader("assets/shaders/chroma.vert")
chroma:send("elapsed", love.timer.getTime())
local scan = love.graphics.newShader("assets/shaders/scan.vert")
function love.load()
	sw = 960 --love.graphics.getWidth()
	sh = 640 --love.graphics.getHeight()
	gamestate = Gamestate.new(level, depth, extra)
	mainCanvas = love.graphics.newCanvas(sw, sh)
	transitionState = nil
	transitionPercentage = 0
	transitionDistance = sw / 2
	bounceCanvas = love.graphics.newCanvas(sw, sh)
	popup = {
		message = nil,
		showPercent = 0,
		duration = 0,
		revealRate = 5,
		hideRate = 3,
		next = nil,
		nextDuration = 0
	}


	love.graphics.setDefaultFilter("nearest", "nearest")
	love.keyboard.setKeyRepeat(true)
	love.graphics.setLineStyle("rough")

	song:setLooping(true)
	local loopStart = 20 - 1
	loopEnd = song:getDuration("seconds") - 1.2732
	loopLength = loopEnd - loopStart
	song:play()
	song:setVolume(0.8)
end

local keyCooldown = 0
---@type love.KeyConstant?
local keyCooldownKey = nil
local timer = 0
function love.update(dt)
	local now = song:tell("seconds")
	if (now >= loopEnd) then
		song:seek(song:tell("seconds") - loopLength, "seconds")
	end
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
	local tCap = 1.2
	if transitionState then
		if transitionPercentage < tCap then
			transitionPercentage = bib.lerp(transitionPercentage, tCap, dt * tCap)
			if gamestate.moveCount / #gamestate.inputs > 1 - transitionPercentage then
				gamestate:backwards()
			end
			if transitionPercentage > tCap * 0.9 then
				transitionPercentage = 0
				gamestate = transitionState
				transitionState = nil
			end
		end
	end
	if popup.duration > 0 then
		popup.duration = popup.duration - dt
		popup.showPercent = bib.lerp(popup.showPercent, 1, dt * popup.revealRate)
	else
		popup.showPercent = bib.lerp(popup.showPercent, -0.1, dt * popup.hideRate)
	end
	popup.duration = math.max(popup.duration, 0)
	popup.showPercent = bib.clamp(0, popup.showPercent, 1)
	if popup.showPercent == 0 and popup.next then
		popup.message = popup.next
		popup.duration = popup.nextDuration
		popup.next = nil
		popup.nxtDuration = nil
	end
	---soundsworks (i sure hope it does)
	for _, grid in ipairs(gamestate.grids) do
		for _, row in ipairs(grid.tiles) do
			for _, tile in ipairs(row) do
				for _, ent in ipairs(tile.entities) do
					if ent.sound then
						ent.sound:clone():play()
						ent.sound = nil
					end
				end
			end
		end
	end
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

local function drawGamestate(gamestate, shiftScreen, skipFirst)
	local gridCount = #gamestate.grids
	local scale
	local wrap
	local lines
	if gridCount == 1 and not transitionState then
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
	else
		scale = 1
		wrap = 5
		lines = 3
	end
	local grids = gamestate.grids
	local gridSize = grids[1].size
	local paddingW = (sw - (wrap) * gridSize * scale - scale * gridSize / 9) / 2
	local paddingH = (sh - (lines) * gridSize * scale - scale * gridSize / 9) / (8 / lines)
	local transitionPercentageCapped = math.min(transitionPercentage, 1)
	local transitionShift = -(sw / 2 - paddingW * 2) * (transitionPercentageCapped)
	if transitionShift > 0 then
		transitionShift = 0
	end
	if shiftScreen then
		transitionShift = transitionShift + (sw / 2 - paddingW * 2)
	elseif gamestate.depth == 0 then
		transitionShift = transitionShift / 2 + sw / 4 - paddingW
	end
	for i, grid in ipairs(grids) do
		if not (skipFirst and i == 1) then
			grid:draw(((i - 1) % wrap) * gridSize * scale + paddingW +
				transitionShift,
				(math.floor((i - 1) / wrap)) * gridSize * scale + paddingH,
				scale)
		end
	end
	love.graphics.setColor(1, 1, 1, 1)
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
	drawGamestate(gamestate, false)
	if transitionState then
		drawGamestate(transitionState, true, true)
	end
	if popup.message then
		love.graphics.setColor(1, 1, 1, popup.showPercent)
		love.graphics.printf(popup.message, font, 0, (sh + font:getDescent() - font:getAscent()) / 2, sw,
			"center")
		love.graphics.setColor(1, 1, 1, 1)
	end
	--
	love.graphics.setBlendMode("alpha")
	keyPreview:draw(gamestate)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setCanvas(bounceCanvas)
	love.graphics.setBlendMode("alpha", "premultiplied")
	if enableShaders then
		love.graphics.setShader(chroma)
	end
	love.graphics.draw(mainCanvas)
	love.graphics.setCanvas()
	if enableShaders then
		love.graphics.setShader(scan)
	end
	love.graphics.draw(bounceCanvas)
	chroma:send("alphaStuff", true)
	if enableShaders then
		love.graphics.setShader(chroma)
	end
	love.graphics.draw(sprites.ui.frame, 0, 0, 0, 2, 2)
	chroma:send("alphaStuff", false)
	love.graphics.setBlendMode("alpha")
	love.graphics.setShader()
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

	love.graphics.printf(message, x, y, love.graphics.getWidth() - x, "left")
end

---@diagnostic disable-next-line: duplicate-set-field
function love.keypressed(key, _, isRepeat)
	local directionName = bib.dirVec(key)
	if not transitionState then
		if not isRepeat or keyCooldownKey ~= key or keyCooldown == 0 then
			if directionName then
				if gamestate:step(directionName, true) then
					local newDepth = gamestate.depth
					if newDepth == 0 then newDepth = 1 end
					transitionState = Gamestate.new(gamestate.level + 1, newDepth)
					transitionState.inputs = gamestate.inputs
					transitionState.moveCount = 0
					popup.next = gamestate.level .. "/15"
					popup.nextDuration = 2
					transitionPercentage = -0.5
					if gamestate.depth > 0 then
						gamestate.lockFirst = true
					end
				end
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
end

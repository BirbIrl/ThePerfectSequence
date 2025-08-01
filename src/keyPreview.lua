local sprites = require "sprites"
local bib = require "lib.biblib"
local vec = require "lib.vector"
local preview = {
	canvas = love.graphics.newCanvas(),
	keyvas = love.graphics.newCanvas(48, 48),
	pos = 0,
	velocity = 0,
	seeds = {},
	time = 0,
}
local glow = love.graphics.newShader("assets/shaders/glow.vert")
glow:send("alpha", 1)

for i = 1, 64, 1 do
	preview.seeds[i] = (love.math.random() + 0.25) * bib.sign(love.math.random() - 0.5)
end


function preview:getDrift(id)
	local speed = 1.5
	local magnitude = 0.05
	local seed = self.seeds[id]
	local x = math.sin(self.time * speed * seed + seed * 9) * (magnitude)
	local y = math.cos(self.time * speed * seed + seed * 9) * (magnitude)
	return vec.new(x, y)
end

local scale = 6

function preview:update(gamestate, dt)
	self.time = self.time + dt
	self.pos = bib.lerp(self.pos, gamestate.moveCount + 0.001, dt * 10)
end

preview.canvas:setFilter("nearest", "nearest")
preview.keyvas:setFilter("nearest", "nearest")
---@param gamestate Gamestate.lua
function preview:draw(gamestate)
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()
	local width = sw
	local moveCount = gamestate.moveCount
	love.graphics.setBlendMode("alpha")
	for i, input in ipairs(gamestate.inputs) do
		love.graphics.setColor(1, 1, 1, 1)
		local drift = preview:getDrift(i)
		local x = (i - 1.25 - self.pos + drift.x) * 19 * scale + width / 2
		local y = 500 - (16 * scale) + drift.y * 19 * scale
		love.graphics.setCanvas(self.keyvas)
		love.graphics.clear()
		love.graphics.draw(sprites.ui.key.body, 16, 16)
		love.graphics.setCanvas(self.canvas)
		local moveResult
		for _, result in ipairs(gamestate.results) do
			if result.step == i and moveResult ~= false then
				moveResult = result.status
			end
		end
		if i > moveCount then
			love.graphics.setColor(1, 1, 1, 0.65)
		elseif moveResult == false then
			love.graphics.setColor(1, 0.5, 0.5, 1)
		elseif moveResult == true then
			love.graphics.setColor(0.5, 1, 0.5, 1)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		if i == moveCount then
			love.graphics.setShader(glow)
		end
		love.graphics.draw(self.keyvas, x, y, 0, scale, scale)

		love.graphics.setShader()
		love.graphics.setCanvas(self.keyvas)
		love.graphics.clear()
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setBlendMode("alpha", "premultiplied")
		love.graphics.draw(sprites.ui.key[input], 16, 16)
		love.graphics.setBlendMode("alpha", "alphamultiply")
		love.graphics.setCanvas(self.canvas)
		love.graphics.draw(self.keyvas, x, y, 0, scale, scale)
	end
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.setCanvas(mainCanvas)
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(self.canvas, 0, 0, 0, 1, 1)
	love.graphics.setBlendMode("alpha", "alphamultiply")
end

return preview

local sprites = require "sprites"
local moonshine = require "moonshine"
local preview = {
	canvas = love.graphics.newCanvas(960, 180),
	keyvas = love.graphics.newCanvas(16, 16)
}
local effect = moonshine(moonshine.effects.glow)


function preview:drawKey(canvas, i)
end

local scale = 6

effect.glow.strength = 8
preview.canvas:setFilter("nearest", "nearest")
preview.keyvas:setFilter("nearest", "nearest")
---@param gamestate Gamestate.lua
function preview:draw(gamestate)
	love.graphics.setCanvas(self.canvas)
	love.graphics.clear()
	love.graphics.setBlendMode("alpha", "alphamultiply")
	local moveCount = gamestate.moveCount
	for i, input in ipairs(gamestate.inputs) do
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.setCanvas(self.keyvas)
		love.graphics.clear()
		love.graphics.draw(sprites.ui.key.body, 0, 0)
		love.graphics.draw(sprites.ui.key[input], 0, 0)
		love.graphics.setCanvas(self.canvas)
		if i > moveCount then
			love.graphics.setColor(1, 1, 1, 0.5)
		else
			love.graphics.setColor(1, 1, 1, 1)
		end
		if i == moveCount then
			effect(function()
				love.graphics.draw(self.keyvas, i * 18 * scale, 16 + 54, 0, scale, scale)
			end)
		else
			love.graphics.draw(self.keyvas, i * 18 * scale, 16 + 54, 0, scale, scale)
		end
	end
	love.graphics.setCanvas()
	love.graphics.setBlendMode("alpha", "premultiplied")
	love.graphics.draw(self.canvas, 49, 432, 0, 1, 1)
	love.graphics.setBlendMode("alpha", "alphamultiply")
end

return preview

local tile = require "tile"
local grid = require "grid"
local vec = require "lib.vector"
local field1 = grid.new(vec.new(50, 50))
function love.load()
end

function love.update()

end

function love.draw()
	field1:draw()
end

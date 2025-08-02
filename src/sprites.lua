local s = "assets/sprites/"
local p = s .. "player/"
local k = s .. "key/"
local l = love.graphics.newImage
return {
	player = {
		body = l(p .. "body.png"),
		idle = l(p .. "idle.png"),
		right = l(p .. "right.png"),
		left = l(p .. "left.png"),
		up = l(p .. "up.png"),
		down = l(p .. "down.png"),
		back = l(p .. "back.png"),
		forward = l(p .. "forward.png"),
	},
	ui = {
		frame = l(s .. "frame.png"),
		key = {
			body = l(k .. "body.png"),
			left = l(k .. "left.png"),
			right = l(k .. "right.png"),
			up = l(k .. "up.png"),
			down = l(k .. "down.png"),
		}
	},
	box = l(s .. "box.png"),
	glass = l(s .. "glass.png"),
	wall = l(s .. "wall.png"),
	ground = l(s .. "ground.png"),
}

local s = "assets/sprites/"
local p = s .. "player/"
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
	}
}

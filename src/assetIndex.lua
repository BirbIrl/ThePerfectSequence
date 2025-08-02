local s = "assets/sprites/"
local so = "assets/sounds/"
local p = s .. "player/"
local k = s .. "key/"
local i = love.graphics.newImage
local a = love.audio.newSource
return {

	sprites =
	{
		player = {
			body = i(p .. "body.png"),
			idle = i(p .. "idle.png"),
			right = i(p .. "right.png"),
			left = i(p .. "left.png"),
			up = i(p .. "up.png"),
			down = i(p .. "down.png"),
			back = i(p .. "back.png"),
			forward = i(p .. "forward.png"),
		},
		ui = {
			frame = i(s .. "frame.png"),
			key = {
				body = i(k .. "body.png"),
				left = i(k .. "left.png"),
				right = i(k .. "right.png"),
				up = i(k .. "up.png"),
				down = i(k .. "down.png"),
			}
		},
		box = i(s .. "box.png"),
		glass = i(s .. "glass.png"),
		wall = i(s .. "wall.png"),
		ground = i(s .. "ground.png"),
		groundfade = i(s .. "groundfade.png"),
	},
	sounds = {
		die = a(so .. "die.ogg", "static")
	},
	songs = {
		stuck = a("assets/songs/stuck.ogg", "stream")
	}
}

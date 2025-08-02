local s = "assets/sprites/"
local so = "assets/sounds/"
local p = s .. "player/"
local k = s .. "key/"
local w = s .. "wall/"
local t = s .. "teleporter/"
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
		wall = {
			base   = i(w .. "base.png"),
			right  = i(w .. "right.png"),
			left   = i(w .. "left.png"),
			up     = i(w .. "up.png"),
			down   = i(w .. "down.png"),
			chisel = {
				i(w .. "chisel1.png"),
				i(w .. "chisel2.png"),
			}
		},
		teleporter = {
			i(t .. "1.png"),
			i(t .. "2.png"),
			i(t .. "3.png"),
			i(t .. "4.png"),
			i(t .. "5.png"),
			i(t .. "6.png"),
			i(t .. "7.png"),
			base = i(t .. "base.png"),
		},
		box = i(s .. "box.png"),
		glass = i(s .. "glass.png"),
		ground = i(s .. "ground.png"),
		groundfade = i(s .. "groundfade.png"),
	},
	sounds = {
		die = a(so .. "die.ogg", "static"),
		levelComplete = a(so .. "levelComplete.ogg", "static"),
		portal = a(so .. "portal.ogg", "static"),
		push = a(so .. "push.ogg", "static"),
		ding = {
			a(so .. "ding1.ogg", "static"),
			a(so .. "ding2.ogg", "static")
		},
		clear = a(so .. "clear.ogg", "static"),
		bump = a(so .. "bump.ogg", "static"),
		walk = a(so .. "walk.ogg", "static"),
		falltile = a(so .. "falltile.ogg", "static"),
	},
	songs = {
		stuck = a("assets/songs/stuck.ogg", "stream")
	}
}

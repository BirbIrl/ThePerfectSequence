local loopStart, loopEnd, loopLength
function love.load()
	song:setLooping(true)
	loopStart = 20 - 1
	loopEnd = song:getDuration("seconds") - 1
	loopLength = loopEnd - loopStart
	song:play()
end

function love.update(dt)
	-- note that with vsync on, this might not be fast enough for the code to be precise enough.
	local now = song:tell("seconds")
	if (now >= loopEnd) then
		song:seek(song:tell("seconds") - loopLength, "seconds")
		--have it recalculate the current position, and jump backwards relatively. this helps make the loop more seamless
	end
end

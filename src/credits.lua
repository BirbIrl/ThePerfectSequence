local credits = {
	1,
	"Made for the 2025 GMTK Game Jam",
	"text",
	2,
	"\n\nDeveloped By:",
	"text",
	2,
	"\n\nBirbirl",
	"text",
	0,
	"\n(Programming, Art)",
	"sub", -- correct
	2,
	"\n\nLuneDaFox",
	"text",
	0,
	"\n\n\n(Level Design)",
	"sub",
	2,
	"\n\nBartuscus",
	"text",
	0,
	"\n\n\n\n\n(Music and Sound)",
	"sub",
	2,
	"",
	"text",

}
globalCreditsSoundCounterISwearToGodIDontCareAboutCodeQualityAnymore = 0
return function(time, font)
	local text = ""
	local counter = 0
	for i = 1, #credits / 3, 1 do
		counter = counter + credits[3 * i - 2]
		if time < counter then
			break
		end
		if credits[3 * i] == "text" then
			text = text .. credits[3 * i - 1]
		else
			love.graphics.printf(credits[3 * i - 1], font, sw / 4, 145 + ((5 + i) * font:getHeight()) / 8, sw * 4,
				"center", 0,
				0.125, 0.125)
		end
		if globalCreditsSoundCounterISwearToGodIDontCareAboutCodeQualityAnymore < i then
			globalCreditsSoundCounterISwearToGodIDontCareAboutCodeQualityAnymore = i
			if i ~= 9 then
				sounds.ding[1]:play()
			else
				sounds.levelComplete:play()
			end
		end
	end

	love.graphics.printf(text, font, 0, 150, sw * 4, "center", 0, 0.25, 0.25)
end

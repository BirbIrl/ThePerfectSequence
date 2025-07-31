local Grid = require "grid"
local bib = require "lib.biblib"
return {
	---@param level integer
	---@param depth integer
	---@param extra integer[]?
	new = function(level, depth, extra)
		depth = depth or 0
		---@class Gamestate.lua
		local gamestate = {
			level = level,
			depth = depth,
			extra = extra or {},
			---@type directions[]
			inputs = {},
			moveCount = 0,
			---@type Grid.lua[]
			grids = {
			}
		}
		function gamestate:reload()
			local grids = {}
			for i = self.level - self.depth, self.level, 1 do
				if i > 0 then
					grids[#grids + 1] = Loader:load(i)
				end
			end
			for _, i in ipairs(self.extra) do
				grids[#grids + 1] = Loader:load(i)
			end
			gamestate.grids = grids
		end

		function gamestate:restart(hard)
			gamestate:reload()
			if hard then
				self.moveCount = 0
				self.inputs = {}
			elseif self.moveCount > 0 then
				gamestate:moveToInput(self.moveCount)
			end
		end

		function gamestate:step(directionName, record)
			local _, moveVec = bib.dirVec(directionName)
			local moved = false
			for _, grid in ipairs(self.grids) do
				if not grid.isBeat and not grid.isLost then
					grid:step(moveVec)
					moved = true
				end
			end
			if moved and record then
				self.moveCount = self.moveCount + 1
				if self.inputs[self.moveCount] ~= directionName then
					for index, _ in ipairs(self.inputs) do
						if index > self.moveCount then
							self.inputs[index] = nil
						end
					end
				end
				self.inputs[self.moveCount] = directionName
			end
		end

		---@return {id: integer, state: "running"|"success"|"failed"}[]
		function gamestate:status()
			local statuses = {}
			for _, grid in ipairs(self.grids) do
				local state = "running"
				if grid.isBeat then
					state = "success"
				elseif grid.isLost then
					state = "failed"
				end
				statuses[#statuses + 1] = { id = grid.id, state = state }
			end
			return statuses
		end

		function gamestate:backwards()
			local inputNum = self.moveCount
			if inputNum > 0 then
				self:moveToInput(inputNum - 1)
				self.moveCount = self.moveCount - 1
			end
		end

		function gamestate:forward()
			local inputNum = self.moveCount
			if inputNum < #self.inputs then
				self:moveToInput(inputNum + 1)
				self.moveCount = inputNum + 1
			end
		end

		function gamestate:moveToInput(moveCount)
			gamestate:reload()
			for i = 1, moveCount, 1 do
				local moveVec = bib.dirVec(self.inputs[i])
				self:step(moveVec)
			end
		end

		function gamestate:trySolve(gridNum)
			local oldInputs = bib.shallowCopy(self.inputs)
			local grid = gamestate.grids[gridNum]
			---@type directions[][]
			local toTry = { bib.shallowCopy(oldInputs) }
			repeat
				local inputs = toTry[1]
				local inputCount = #inputs
				gamestate:reload()
				for i = 1, inputCount, 1 do
					local moveVec = bib.dirVec(inputs[i])
					grid:step(moveVec)
				end
			until grid.isBeat or grid.isLost or (inputCount > 100)
		end

		gamestate:restart(true)
		return gamestate
	end

}

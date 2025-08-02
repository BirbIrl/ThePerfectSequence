local Grid = require "grid"
local bib = require "lib.biblib"
local sprites = require "sprites"
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
			},
			---@type {id: integer, status: boolean, step: integer}[]
			results = {},
			lockFirst = false
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
			for i, grid in ipairs(self.grids) do
				if grid then
					grids[i].beenDead = grid.beenDead
				end
			end
			if self.lockFirst then grids[1] = gamestate.grids[1] end
			gamestate.grids = grids
			gamestate.results = {}
		end

		function gamestate:update(dt)
			for _, grid in ipairs(self.grids) do
				grid:update(dt)
			end
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

		---@param directionName directions
		---@param record boolean
		function gamestate:step(directionName, record, step)
			step = step or self.moveCount + 1
			local moved = false
			for i, grid in ipairs(self.grids) do
				if not (grid.isBeat or grid.isLost) then
					grid:step(directionName)
					moved = true
					if grid.isBeat or grid.isLost then
						self.results[#self.results + 1] = { id = i, status = grid.isBeat, step = step }
					end
				end
			end
			if moved then
				if record then
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
			if self.level > 0 then
				for i = 1, self.depth + 1, 1 do
					local status = gamestate:status()[i]
					if not (status and status.state == "success") then
						return false
					end
				end
				return true
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

		function gamestate:setPlayerFace(face)
			for i, grid in ipairs(self.grids) do
				if not (self.lockFirst and i == 1) then
					local player = grid:find("player")[1]
					if player then
						player.data.eyes = face
					end
				end
			end
		end

		function gamestate:backwards()
			local inputNum = self.moveCount
			if inputNum > 0 then
				self:moveToInput(inputNum - 1)
				self.moveCount = self.moveCount - 1
				self:setPlayerFace(sprites.player.back)
			end
		end

		function gamestate:forward()
			local inputNum = self.moveCount
			if inputNum < #self.inputs then
				self:moveToInput(inputNum + 1, true)
				self.moveCount = inputNum + 1
				self:setPlayerFace(sprites.player.forward)
			end
		end

		function gamestate:wipeAnims()
			for _, grid in ipairs(self.grids) do
				for _, row in ipairs(grid.tiles) do
					for _, tile in ipairs(row) do
						for _, entity in ipairs(tile.entities) do
							entity.anims = {}
						end
					end
				end
			end
		end

		function gamestate:moveToInput(moveCount, keepAnims)
			gamestate:reload()
			for i = 1, moveCount, 1 do
				local moveVec = bib.dirVec(self.inputs[i])
				if i == moveCount then
					gamestate:wipeAnims()
				end
				self:step(moveVec, nil, i)
			end
			if keepAnims then return true end
			gamestate:wipeAnims()
		end

		--not used, you shouldn't use this either
		function gamestate:trySolve(gridNum)
			local oldInputs = bib.shallowCopy(self.inputs)
			local grid = gamestate.grids[gridNum]
			---@type directions[][]
			local toTry = { bib.shallowCopy(oldInputs) }
			while toTry[1] do
				local inputs = toTry[1]
				local inputCount = #inputs
				gamestate:reload()
				grid = gamestate.grids[gridNum]
				for i = 1, inputCount, 1 do
					local _, moveVec = bib.dirVec(inputs[i])
					if not grid.isBeat and not grid.isLost then
						grid:step(moveVec)
					end
				end
				if grid.isBeat or (inputCount > 100) then
					break
				elseif not grid.isLost then
					for _, dir in ipairs({ "up", "down", "left", "right" }) do
						toTry[#toTry + 1] = bib.shallowCopy(inputs)
						toTry[#toTry][#toTry[#toTry] + 1] = dir
					end
				end
				table.remove(toTry, 1)
			end
			if grid.isBeat then
				return toTry[1]
			else
				return false
			end
		end

		gamestate:restart(true)
		return gamestate
	end

}

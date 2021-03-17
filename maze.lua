local room = require "room"
local node = require "node"

local maze = {}

function maze:new(_w, _h)
	local self = {}

	self.width = _w
	self.height = _h

	self.stack = {}
	self.rooms = {}

	self.endNode, self.startNode = nil, nil
	self.noiseOffsetX, self.noiseOffsetY = nil, nil

	function self:getIndex(_modX, _modY, _element)
		if not _element then _element = self.stack[#self.stack] end
    	return (_element.y + _modY) * self.width + (_element.x + _modX) + 1
	end

	function self:getDistance()
		local tempNode = self.endNode
		local value = 0

		while tempNode.parent do
			value = value + 1
			tempNode = tempNode.parent
		end

		return value
	end

	function self:getNeighbours(_element)
		local neighbours = {}

		--ORDER: top, right, bottom, left
		if _element.y > 0 and not self.rooms[self:getIndex(0, -1, _element)].visited and not self.rooms[self:getIndex(0, -1, _element)].previsited then
			table.insert(neighbours, 0) end
		if _element.x < self.width - 1 and not self.rooms[self:getIndex(1, 0, _element)].visited and not self.rooms[self:getIndex(1, 0, _element)].previsited then
			table.insert(neighbours, 1) end
		if _element.y < self.height - 1 and not self.rooms[self:getIndex(0, 1, _element)].visited and not self.rooms[self:getIndex(0, 1, _element)].previsited then
			table.insert(neighbours, 2) end
		if _element.x > 0 and not self.rooms[self:getIndex(-1, 0, _element)].visited and not self.rooms[self:getIndex(-1, 0, _element)].previsited then
			table.insert(neighbours, 3) end

		return neighbours
	end

	function self:findNeighbour(_xDir, _yDir, _element)
		local xMod, yMod = _xDir, _yDir

		while not self.rooms[self:getIndex(xMod, yMod, _element)].isNode do
			xMod = xMod + _xDir
			yMod = yMod + _yDir
		end

		return self.rooms[self:getIndex(xMod, yMod, _element)].node
	end

	function self:initMaze(_tileSize, _roomSize)
		self.noiseOffsetX, self.noiseOffsetY = love.math.random(-5000, 5000), love.math.random(-5000, 5000)

		self.rooms = {}

		for y = 0, self.height - 1 do
			for x = 0, self.width - 1 do
				table.insert(self.rooms, room:new(x, y, _tileSize, _roomSize))
			end
		end

		--Pick a random entry point
		local startFrom = love.math.random(#self.rooms)
		while self.rooms[startFrom].previsited do startFrom = love.math.random(#self.rooms) end

		table.insert(self.stack, self.rooms[startFrom])
		self.rooms[startFrom].visited = true
	end

	function self:createMaze(_tileSize, _roomSize)
		self:initMaze(_tileSize, _roomSize)
		local visitedCells = 0

		--Carving maze
		while #self.stack > 0 do
			local neighbours = self:getNeighbours(self.stack[#self.stack])

			if #neighbours > 0 then
				local nextDir = neighbours[love.math.random(1, #neighbours)]

				if nextDir == 0 then
					self.rooms[self:getIndex(0, 0)].path[1] = 1
					self.rooms[self:getIndex(0, -1)].path[3] = 1

					table.insert(self.stack, self.rooms[self:getIndex(0, -1)])
				elseif nextDir == 1 then
					self.rooms[self:getIndex(0, 0)].path[2] = 1
					self.rooms[self:getIndex(1, 0)].path[4] = 1

					table.insert(self.stack, self.rooms[self:getIndex(1, 0)])
				elseif nextDir == 2 then
					self.rooms[self:getIndex(0, 0)].path[3] = 1
					self.rooms[self:getIndex(0, 1)].path[1] = 1

					table.insert(self.stack, self.rooms[self:getIndex(0, 1)])
				elseif nextDir == 3 then
					self.rooms[self:getIndex(0, 0)].path[4] = 1
					self.rooms[self:getIndex(-1, 0)].path[2] = 1

					table.insert(self.stack, self.rooms[self:getIndex(-1, 0)])
				end

				self.rooms[self:getIndex(0, 0)].visited = true
			else
				table.remove(self.stack)
			end
		end

		--Removing walls with simplex noise
		for _, j in ipairs(self.rooms) do
			if love.math.noise(j.x - self.noiseOffsetX, j.y - self.noiseOffsetY) > 0.92 and not j.previsited then
				if j.x >= 1 then
					if not self.rooms[self:getIndex(-1, 0, j)].previsited then
						j.path[4] = 1
						self.rooms[self:getIndex(-1, 0, j)].path[2] = 1
					end
				end

				if j.x < self.width - 1 then
					if not self.rooms[self:getIndex(1, 0, j)].previsited then
						j.path[2] = 1
						self.rooms[self:getIndex(1, 0, j)].path[4] = 1
					end
				end

				if j.y >= 1 then
					if not self.rooms[self:getIndex(0, -1, j)].previsited then
						j.path[1] = 1
						self.rooms[self:getIndex(0, -1, j)].path[3] = 1
					end
				end

				if j.y < self.height - 1 then
					if not self.rooms[self:getIndex(0, 1, j)].previsited then
						j.path[3] = 1
						self.rooms[self:getIndex(0, 1, j)].path[1] = 1
					end
				end
			end

			if j.visited then visitedCells = visitedCells + 1 end
		end

		for _, j in ipairs(self.rooms) do if j.visited then j:createTilemap() j:createColliders() j:createShadowboxes() end end

		--Check if generation failed
		if visitedCells < _w * _h / 2 then self:createMaze(_w, _h) end

		self:manageNodes()
		self:solvePath()
		print(self:getDistance())
	end

	function self:manageNodes()
		for _, j in ipairs(self.rooms) do
			if j.previsited then
				j.isNode = false
			else
				j.node = node:new(j.x, j.y, j.w, j.h)
			end
		end

		for _, j in ipairs(self.rooms) do
			if j.isNode then
				if j.path[1] == 1 then table.insert(j.node.neighbours, self:findNeighbour(0, -1, j)) end
				if j.path[2] == 1 then table.insert(j.node.neighbours, self:findNeighbour(1, 0, j)) end
				if j.path[3] == 1 then table.insert(j.node.neighbours, self:findNeighbour(0, 1, j)) end
				if j.path[4] == 1 then table.insert(j.node.neighbours, self:findNeighbour(-1, 0, j)) end
			end
		end

		local startIndex, endIndex = love.math.random(#self.rooms), love.math.random(#self.rooms)

		--Pick a random entrance
		while not self.rooms[startIndex].isNode do startIndex = love.math.random(#self.rooms) end
		self.startNode = self.rooms[startIndex].node

		--Pick a random exit
		while not self.rooms[endIndex].isNode do endIndex = love.math.random(#self.rooms) end
		self.endNode = self.rooms[endIndex].node
	end

	function self:solvePath()
		for _, j in ipairs(self.rooms) do
			if j.isNode then
				j.node:resetNode()
			end
		end

		local function distance(a, b)
			return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2))
		end

		local function heuristic(a, b)
			return distance(a, b)
		end

		local currentNode = self.startNode
		currentNode.localScore = 0
		currentNode.globalScore = heuristic(self.startNode, self.endNode)

		notTestedList = {}
		table.insert(notTestedList, self.startNode)

		while #notTestedList > 0 do
			table.sort(notTestedList, function (a, b) return a.globalScore > b.globalScore end)

			while #notTestedList > 0 and notTestedList[#notTestedList].visited do
				table.remove(notTestedList)
			end

			if #notTestedList == 0 then break end

			currentNode = notTestedList[#notTestedList]
			currentNode.visited = true

			for _, j in ipairs(currentNode.neighbours) do
				if not j.visited then table.insert(notTestedList, j) end

				lowerGoal = currentNode.localScore + distance(currentNode, j)

				if lowerGoal < j.localScore then
					j.parent = currentNode
					j.localScore = lowerGoal
					j.globalScore = j.localScore + heuristic(j, self.endNode)
				end
			end
		end

		if self:getDistance() < self.width + self.height then
			local startIndex, endIndex = love.math.random(#self.rooms), love.math.random(#self.rooms)

			--Pick a random entrance
			while not self.rooms[startIndex].isNode do startIndex = love.math.random(#self.rooms) end
			self.startNode = self.rooms[startIndex].node

			--Pick a random exit
			while not self.rooms[endIndex].isNode do endIndex = love.math.random(#self.rooms) end
			self.endNode = self.rooms[endIndex].node

			self:solvePath()
		end
	end

	function self:render()
		for _, j in ipairs(self.rooms) do
            --[[if j.visited then
                if j.node == self.startNode then
                    love.graphics.setColor(0, 1, 0, 1)
                    love.graphics.circle("fill", j.node.renderX, j.node.renderY, j.node.renderRadius, 100)

                elseif j.node == self.endNode then
                    love.graphics.setColor(1, 0, 0, 1)
                    love.graphics.circle("fill", j.node.renderX, j.node.renderY, j.node.renderRadius, 100)
                end
            end]]

			local xLeft, yTop = cam:toScreen(j.renderX, j.renderY)
			local xRight, yBottom = cam:toScreen(j.renderX + j.w, j.renderY + j.h)

			if j:setRoomActive(xRight >= 0 and xLeft <= love.graphics.getWidth() and yBottom >= 0 and yTop <= love.graphics.getHeight()) then
				j:render()
			end
        end

		--[[love.graphics.setColor(1, 0, 0)

        local tempNode = self.endNode

        while tempNode.parent do
            love.graphics.line(tempNode.renderX, tempNode.renderY, tempNode.parent.renderX, tempNode.parent.renderY)
            tempNode = tempNode.parent
        end]]
	end

	return self
end

return maze
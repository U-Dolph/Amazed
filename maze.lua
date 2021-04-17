local room = require "room"
local node = require "node"

local maze = {}

function maze:new(_w, _h, _tileSize, _roomSize)
	local self = {}

	self.width = _w
	self.height = _h
	self.tileSize = _tileSize
	self.roomSize = _roomSize

	self.stack = {}
	self.rooms = {}

	self.endNode, self.startNode, self.startIndex, self.endIndex = nil, nil, nil, nil
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

	function self:initMaze()
		self.noiseOffsetX, self.noiseOffsetY = love.math.random(-5000, 5000), love.math.random(-5000, 5000)

		self.rooms = {}

		for y = 0, self.height - 1 do
			for x = 0, self.width - 1 do
				table.insert(self.rooms, room:new(x, y, self.tileSize, self.roomSize, self))
			end
		end

		--Pick a random entry point
		local startFrom = love.math.random(#self.rooms)
		while self.rooms[startFrom].previsited do startFrom = love.math.random(#self.rooms) end

		table.insert(self.stack, self.rooms[startFrom])
		self.rooms[startFrom].visited = true
	end

	function self:createMaze(isMenuState)
		self:initMaze()
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

		--Check if generation failed
		if visitedCells < _w * _h / 2 then self:createMaze(_w, _h) end

		self:manageNodes()
		self:solvePath()


		for _, j in ipairs(self.rooms) do
			if j.visited then
				j:createTilemap()

				--!Don't want shadows in the menu
				if not isMenuState then
					j:createShadowboxes()
				end
			end
		end
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

		--Make exit far from the start
		if self:getDistance() < self.width + self.height or self.startIndex == nil then
			self.startIndex, self.endIndex = love.math.random(#self.rooms), love.math.random(#self.rooms)

			--Pick a random entrance
			while not self.rooms[self.startIndex].isNode do self.startIndex = love.math.random(#self.rooms) end
			self.startNode = self.rooms[self.startIndex].node

			--Pick a random exit
			while not (self.rooms[self.endIndex].isNode and self.rooms[self.endIndex].path[1] == 0) do self.endIndex = love.math.random(#self.rooms) end
			self.endNode = self.rooms[self.endIndex].node

			self:solvePath()
		end
	end

	function self:render()
		if Gamestate.current() == menu then
			for _, j in ipairs(self.rooms) do
				local left, top, _, _, right, bottom = menu.cam:getVisibleCorners()
				if j.renderX + j.w >= left and j.renderX <= right and j.renderY + j.h >= top and j.renderY <= bottom then
					j:render()
				end
			end
		else
			local roomsToRender = self:depthSearch(Player.currentRoom, _ROOMDEPTH)

			for _, j in ipairs(self.rooms) do
				j.visible = false
				for _, l in ipairs(roomsToRender) do
					if j == l then j.visible = true end
				end

				if j.visible then j:render() end
			end

			return #roomsToRender
		end
	end

	function self:update(dt)
		for _, j in ipairs(self.rooms) do
			local xLeft, yTop = cam:toScreen(j.renderX, j.renderY)
			local xRight, yBottom = cam:toScreen(j.renderX + j.w, j.renderY + j.h)

			if Player.x >= j.renderX and Player.x <= j.renderX + j.w and Player.y >= j.renderY and Player.y <= j.renderY + j.h then
				if j.path[1] == 1 then self.rooms[self:getIndex(0, -1, j)].explored = true end
				if j.path[2] == 1 then self.rooms[self:getIndex(1, 0, j)].explored = true end
				if j.path[3] == 1 then self.rooms[self:getIndex(0, 1, j)].explored = true end
				if j.path[4] == 1 then self.rooms[self:getIndex(-1, 0, j)].explored = true end
				j.explored = true
			end

			if xRight > 0 and xLeft < 640 and yBottom > 0 and yTop < 360 then
				if #j.colliders == 0 and j.visited then
					j:createColliders()
				end
			else
				for k, l in ipairs(j.colliders) do
					l:destroy()
					table.remove(j.colliders, k)
				end
			end
		end
	end

	function self:depthSearch(_element, _depth)
		local roomsFound = {}
		table.insert(roomsFound, _element)

		if _depth > 0 then
			local subRoomsFound = {}

			if _element.path[1] == 1 then
				table.insert(roomsFound, self.rooms[self:getIndex(0, -1, _element)])
				subroomsFound = self:depthSearch(self.rooms[self:getIndex(0, -1, _element)], _depth - 1)

				for i, j in ipairs(subroomsFound) do
					table.insert(roomsFound, j)
				end
			end

			if _element.path[2] == 1 then
				table.insert(roomsFound, self.rooms[self:getIndex(1, 0, _element)])

				subroomsFound = self:depthSearch(self.rooms[self:getIndex(1, 0, _element)], _depth - 1)

				for i, j in ipairs(subroomsFound) do
					table.insert(roomsFound, j)
				end
			end

			if _element.path[3] == 1 then
				table.insert(roomsFound, self.rooms[self:getIndex(0, 1, _element)])

				subroomsFound = self:depthSearch(self.rooms[self:getIndex(0, 1, _element)], _depth - 1)

				for i, j in ipairs(subroomsFound) do
					table.insert(roomsFound, j)
				end
			end

			if _element.path[4] == 1 then
				table.insert(roomsFound, self.rooms[self:getIndex(-1, 0, _element)])

				subroomsFound = self:depthSearch(self.rooms[self:getIndex(-1, 0, _element)], _depth - 1)

				for i, j in ipairs(subroomsFound) do
					table.insert(roomsFound, j)
				end
			end
		end

		local result = {}

		for i, j in ipairs(roomsFound) do
			--j.visible = false
			local valid = true

			for k, l in ipairs(result) do
				if l == j then valid = false end
			end

			local xLeft, yTop = cam:toScreen(j.renderX, j.renderY)
			local xRight, yBottom = cam:toScreen(j.renderX + j.w, j.renderY + j.h)

			if valid and xRight > 0 and xLeft < 640 and yBottom > 0 and yTop < 360 then
				table.insert(result, j)
			end
		end

		return result
	end

	return self
end

return maze
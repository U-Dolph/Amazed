local enemy = {}

function enemy:new(_x, _y)
	local self = {}

	self.x = _x
	self.y = _y
	self.direction = love.math.random(0, 1) == 0 and -1 or 1
	self.state = "idle"

	self.isAttacking = false

	self.currentRoom = nil
	self.destinationNode = nil

	self.health = 100
	self.maxHealth = 100
	self.invicible = false
	self.alive = true

	self.timer = Timer.new()

	self.footCollider = nil
	self.bodyCollider = nil

	self.path = {}

	function self:render()
		if self.state == "explosion" then
			self.animations[self.state]:draw(smallExplosionImage, self.x, self.y, 0, 1, 1, 8, 8)
		else
			self.animations[self.state]:draw(animationImage, self.x, self.y, 0, self.direction, 1, 9, 8)

			for i, j in ipairs(self.path) do
				love.graphics.line(j[1], j[2], j[3], j[4])
			end
		end

		love.graphics.setColor(0, 1, 0)
		love.graphics.rectangle("fill", self.x - 8, self.y - 10, math.max(16 * self.health / self.maxHealth, 0), 3)
		love.graphics.setColor(1,1,1,1)

		if self.path then
			love.graphics.print(#self.path, self.x - 8, self.y - 14)
		end
	end

	function self:findPath(destination)
		if self.health > 0 then
		for _, j in ipairs(maze.rooms) do
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

		local currentNode = self.currentRoom.node
		local endNode = destination.currentRoom.node
		currentNode.localScore = 0
		currentNode.globalScore = heuristic(currentNode, endNode)

		local notTestedList = {}
		local result = {}
		table.insert(notTestedList, currentNode)

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
					j.globalScore = j.localScore + heuristic(j, endNode)
				end
			end
		end

		local tempNode = endNode

		if tempNode.parent then
			result[1] = {destination.x, destination.y, tempNode.parent.renderX, tempNode.parent.renderY}
			tempNode = tempNode.parent

			while tempNode.parent do
				table.insert(result, {tempNode.renderX, tempNode.renderY, tempNode.parent.renderX, tempNode.parent.renderY})
				tempNode = tempNode.parent
			end

			result[#result] = {result[#result][1], result[#result][2], self.x, self.y,}
		else
			table.insert(result, {destination.x, destination.y, self.x, self.y})
		end

		return result
	end
	end

	function self:getCurrentRoom()
		local RoomHorizontalIndex = math.ceil(self.x / (maze.roomSize * maze.tileSize))
		local RoomVerticalIndex = math.floor(self.y / (maze.roomSize * maze.tileSize))
		return maze.rooms[RoomVerticalIndex * maze.width + RoomHorizontalIndex]
	end

	return self
end

return enemy
local enemy = {}

function enemy:new(_x, _y)
	local self = {}

	self.x = _x
	self.y = _y
	self.direction = love.math.random(0, 1) == 0 and -1 or 1
	self.state = "idle"

	self.currentRoom = nil
	self.destinationNode = nil

	self.health = 100
	self.maxHealth = 100
	self.defense = 0
	self.speed = 0
	self.power = 0
	self.invicible = false
	self.alive = true

	self.canAttack = true
	self.canMove = true
	self.isAttacking = false
	self.attackHandler = nil

	self.timer = Timer.new()

	self.footCollider = nil
	self.bodyCollider = nil

	self.power = nil

	self.path = {}
	self.playerPrevKnownRoom = player.currentRoom
	self.prevKnownRoom = self.currentRoom

	self.rayHitList = {}

	function self:render()
		if self.state == "explosion" then
			self.animations[self.state]:draw(smallExplosionImage, self.x, self.y, 0, 1, 1, 8, 8)
		else
			self.animations[self.state]:draw(animationImage, self.x, self.y, 0, self.direction, 1, 9, 8)

			--for i, j in ipairs(self.path) do
				--love.graphics.line(j[1], j[2], j[3], j[4])
			--end

			--[[for i = 1, #self.path - 1 do
				love.graphics.line(self.path[i].renderX, self.path[i].renderY, self.path[i + 1].renderX, self.path[i + 1].renderY)
			end]]
		end

		love.graphics.setColor(0, 1, 0)
		love.graphics.rectangle("fill", self.x - 8, self.y - 10, math.max(16 * self.health / self.maxHealth, 0), 3)
		love.graphics.setColor(1,1,1,1)

		--if self.path then
		for i = 0, 36 do
			--love.graphics.line(self.x, self.y, self.x + self.direction * 100, self.y)
			--love.graphics.line(self.x + self.direction * 10, self.y, self.x + self.direction * 10 + math.cos(math.pi/36 * i - math.pi/2) * 50 * self.direction, self.y + math.sin(math.pi/36 * i - math.pi/2) * 50)
			--love.graphics.line(self.x, self.y, self.x + math.cos(math.pi/36 * i - math.pi/2) * 50 * self.direction, self.y + math.sin(math.pi/36 * i - math.pi/2) * 50)
		end
		love.graphics.setColor(1, 0, 0)
		--love.graphics.print(#self.rayHitList, self.x - 8, self.y - 14)
		love.graphics.setColor(1, 1, 1)
		--end
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

				--result[#result] = {result[#result][1], result[#result][2], self.x, self.y}
			else
				table.insert(result, {self.x, self.y, destination.x, destination.y})
			end

			return result
		end
	end

	function self:getCurrentRoom()
		local RoomHorizontalIndex 	= math.ceil(self.x / (maze.roomSize * maze.tileSize))
		local RoomVerticalIndex 	= math.floor(self.y / (maze.roomSize * maze.tileSize))
		return maze.rooms[RoomVerticalIndex * maze.width + RoomHorizontalIndex]
	end

	function self:takeDamage(value)
		if not self.invicible and self.health > 0 then
			local damage = math.max(1, (value - self.defense) + love.math.random(-4, 4))
			popupHandler:addElement(damage, self.x, self.y - 18, {1, 0, 0})
			self.invicible = true
			self.health = self.health - damage
			self.timer:after(0.2, function () self.invicible = false end)

			local angle = lume.angle(self.x, self.y, player.x, player.y)
			self.footCollider:applyLinearImpulse(math.cos(angle) * -15, math.sin(angle) * -15)
		end
	end

	function self:move()
		self.state = "idle"
		local targetX, targetY = self.path[#self.path][1], self.path[#self.path][2]
		local angle = lume.angle(self.x, self.y, targetX, targetY)
		if self.canMove then 
			self.state = "running"
			self.footCollider:applyForce(math.cos(angle) * self.speed, math.sin(angle) * self.speed)
		end
	end

	function self:noticePlayer()
		self.path = self:findPath(player)
		if #self.path <= 2 then
			self.isAttacking = true
			popupHandler:addElement("?", self.x, self.y - 18, {1, 0.5, 0.5})
		end
	end

	return self
end

return enemy
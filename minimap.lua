local room = require "room"
local minimap = {}

function minimap:new(_x, _y, _w, _h)
	local self = {}

	self.x = _x
	self.y = _y

	self.width = _w
	self.height = _h

	self.roomSize = maze.roomSize

	self.roomsHorizontal = maze.width
	self.roomsVertical = maze.height

	self.frame = love.graphics.newImage("gfx/minimapFrame.png")
	self.background = love.graphics.newImage("gfx/mapBackground.png")

	function self:render()
		local normalizedPlayerX = player.x / (self.roomSize * self.roomsHorizontal * maze.tileSize)
		local normalizedPlayerY = player.y / (self.roomSize * self.roomsVertical * maze.tileSize)
		local diffHorizontal = (self.roomSize * self.roomsHorizontal) - self.width + 20
		local diffVertical = (self.roomSize * self.roomsVertical) - self.height + 20
		love.graphics.draw(self.background, self.x, self.y)

		love.graphics.push()
		love.graphics.translate(10 + math.ceil(-normalizedPlayerX * diffHorizontal), 10 + math.ceil(-normalizedPlayerY * diffVertical))

		love.graphics.setScissor(self.x + 6, self.y + 6, self.width, self.height)

		for _, j in ipairs(maze.rooms) do
			if j.explored then
				love.graphics.setColor(0, 0, 0, 0.3)
				if j.node == maze.endNode then love.graphics.setColor(0.5, 0.5, 1, 0.3) end

				love.graphics.rectangle("fill", self.x + 6 + j.x * self.roomSize, self.y + 6 + j.y * self.roomSize, self.roomSize, self.roomSize)
				love.graphics.setColor(110/255, 74/255, 72/255)
				love.graphics.setLineStyle("rough")

				if j.path[1] == 0 then
					love.graphics.line(self.x + 6 + j.x * self.roomSize, self.y + 6.5 + j.y * self.roomSize, self.x + 6 + j.x * self.roomSize + self.roomSize, self.y + 6.5 + j.y * self.roomSize)
				end

				if j.path[2] == 0 then
					love.graphics.line(self.x + 6 + j.x * self.roomSize + self.roomSize, self.y + 6 + j.y * self.roomSize, self.x + 6 + j.x * self.roomSize + self.roomSize, self.y + 6 + j.y * self.roomSize + self.roomSize)
				end

				if j.path[3] == 0 then
					love.graphics.line(self.x + 6 + j.x * self.roomSize, self.y + 5.5 + j.y * self.roomSize + self.roomSize, self.x + 6 + j.x * self.roomSize + self.roomSize, self.y + 5.5 + j.y * self.roomSize + self.roomSize)
				end

				if j.path[4] == 0 then
					love.graphics.line(self.x + 6.5 + j.x * self.roomSize, self.y + 6.5 + j.y * self.roomSize, self.x + 6.5 + j.x * self.roomSize, self.y + 6.5 + j.y * self.roomSize + self.roomSize)
				end
			end
		end

		for _, j in ipairs(game.chests) do
			if j.currentRoom.explored then
				if j.opened then love.graphics.setColor(0.5, 0.5, 0.5, 1)
				else love.graphics.setColor(1, 0.8, 0, 1) end

				love.graphics.rectangle("fill", self.x + 6 + j.currentRoom.x * self.roomSize + self.roomSize/2, self.y + 6 + j.currentRoom.y * self.roomSize + 1, 1, 1)
			end
		end

		local playerTileX = math.ceil(player.x / maze.tileSize)
		local playerTileY = math.ceil((player.y + 6) / maze.tileSize)

		love.graphics.setColor(0, 1, 0)
		love.graphics.points(self.x + 6 + playerTileX, self.y + 6 + playerTileY)

		love.graphics.setScissor( )
		love.graphics.pop()

		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.frame, self.x, self.y)
	end

	function self:renderLargeMap()
		love.graphics.draw(self.background, 152, 12, 0, 3, 3)
		love.graphics.draw(self.frame, 152, 12, 0, 3, 3)

		local roomNum = 0
		local explored = 0

		local roomSize = math.floor(300 / maze.width) - 1
		local offsetX = math.floor((300 - roomSize * maze.width) / 2)

		for _, j in ipairs(maze.rooms) do
			if j.visited then
				roomNum = roomNum + 1

				if j.explored then explored = explored + 1 end

				if j.node == maze.endNode and j.explored then game.objectives[2].completed = true end
			end

			if j.explored then
				love.graphics.setColor(0, 0, 0, 0.3)
				if j.node == maze.endNode then love.graphics.setColor(0.5, 0.5, 1, 0.3) end

				if j == player.currentRoom then
					love.graphics.setColor(0, math.max(0.2, math.abs(math.cos(os.clock()))), 0, 0.5)
					love.graphics.rectangle("fill", 170 + offsetX + j.x * roomSize, 30 + offsetX + j.y * roomSize, roomSize, roomSize)
				end

				love.graphics.rectangle("fill", 170 + offsetX + j.x * roomSize, 30 + offsetX + j.y * roomSize, roomSize, roomSize)
				love.graphics.setColor(110/255, 74/255, 72/255)
				love.graphics.setLineStyle("rough")

				if j.path[1] == 0 then
					love.graphics.line(170 + offsetX + j.x * roomSize, 30 + offsetX + j.y * roomSize + 1, 170 + offsetX + j.x * roomSize + roomSize, 30 + offsetX + j.y * roomSize + 1)
				end

				if j.path[2] == 0 then
					love.graphics.line(170 + offsetX + j.x * roomSize + roomSize, 30 + offsetX + j.y * roomSize, 170 + offsetX + j.x * roomSize + roomSize, 30 + offsetX + j.y * roomSize + roomSize)
				end

				if j.path[3] == 0 then
					love.graphics.line(170 + offsetX + j.x * roomSize, 30 + offsetX + j.y * roomSize + roomSize, 170 + offsetX + j.x * roomSize + roomSize, 30 + offsetX + j.y * roomSize + roomSize)
				end

				if j.path[4] == 0 then
					love.graphics.line(170 + offsetX + j.x * roomSize, 30 + offsetX + j.y * roomSize, 170 + offsetX + j.x * roomSize, 30 + offsetX + j.y * roomSize + roomSize)
				end
			end
		end

		for _, j in ipairs(game.chests) do
			if j.currentRoom.explored then
				if j.opened then love.graphics.setColor(0.5, 0.5, 0.5, 1)
				else love.graphics.setColor(1, 0.8, 0, 1) end

				love.graphics.rectangle("fill", 170 + offsetX + j.currentRoom.x * roomSize + roomSize/2, 30 + offsetX + j.currentRoom.y * roomSize + 1, 1, 1)
			end
		end

		return roomNum, explored
	end

	return self
end

return minimap
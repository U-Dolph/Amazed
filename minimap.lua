local minimap = {}

function minimap:new(_x, _y, _w, _h, _horizontalSize, _verticalSize)
	local self = {}

	self.x = _x
	self.y = _y

	self.width = _w
	self.height = _h

	self.roomSize = Maze.roomSize

	self.roomsHorizontal = mazeWidth
	self.roomsVertical = mazeHeight

	self.frame = love.graphics.newImage("gfx/minimapFrame.png")
	self.background = love.graphics.newImage("gfx/mapBackground.png")

	function self:render()
		local normalizedPlayerX = Player.x / (self.roomSize * self.roomsHorizontal * Maze.tileSize)
		local normalizedPlayerY = Player.y / (self.roomSize * self.roomsVertical * Maze.tileSize)
		local diffHorizontal = (self.roomSize * self.roomsHorizontal) - self.width + 20
		local diffVertical = (self.roomSize * self.roomsVertical) - self.height + 20
		love.graphics.draw(self.background, self.x, self.y)

		love.graphics.push()
		love.graphics.translate(10 + math.ceil(-normalizedPlayerX * diffHorizontal), 10 + math.ceil(-normalizedPlayerY * diffVertical))

		love.graphics.setScissor(self.x + 6, self.y + 6, self.width, self.height)

		for _, j in ipairs(Maze.rooms) do
			if j.explored then
				love.graphics.setColor(0, 0, 0, 0.3)
				if j.node == Maze.endNode then love.graphics.setColor(0.5, 0.5, 1, 0.3) end

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

		local playerTileX = math.ceil(Player.x / Maze.tileSize)
		local playerTileY = math.ceil((Player.y + 6) / Maze.tileSize)

		love.graphics.setColor(0, 1, 0)
		love.graphics.points(self.x + 6 + playerTileX, self.y + 6 + playerTileY)

		love.graphics.setScissor( )
		love.graphics.pop()

		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.frame, self.x, self.y)
	end

	return self
end

return minimap
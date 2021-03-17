local minimap = {}

function minimap:new(_x, _y, _w, _h, _tilesHorizontal, _tilesVertical)
	local self = {}

	self.x = _x
	self.y = _y

	self.width = _w
	self.height = _h

	self.horizontalSize = _tilesHorizontal
	self.verticalSize = _tilesVertical

	self.blockWidth = self.width / self.horizontalSize
	self.blockHeight = self.height / self.verticalSize

	self.frame = love.graphics.newImage("gfx/minimapFrame.png")


	function self:render()
		love.graphics.push()
		love.graphics.setColor(0, 0, 1, 1)
		--love.graphics.scale(1/renderScale, 1/renderScale)
		love.graphics.rectangle("fill", (self.x + 6.5) * renderScale, (self.y + 6.5) * renderScale, (self.width - 1) * renderScale, (self.height - 1) * renderScale)

		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.rectangle("line", (self.x + 6.5) * renderScale, (self.y + 6.5) * renderScale, (self.width - 1) * renderScale, (self.height - 1) * renderScale)

		for _, j in ipairs(Maze.rooms) do
			if j.explored then
				love.graphics.setColor(0.2, 0.2, 0.2)
				love.graphics.rectangle("fill", self.x + 6 + j.x * self.blockWidth, self.y + 6 + j.y * self.blockHeight, self.blockWidth, self.blockHeight)
				love.graphics.setColor(1, 1, 1)
				love.graphics.setLineStyle("rough")

				if j.path[1] == 0 then
					love.graphics.line(self.x + 6 + j.x * self.blockWidth, self.y + 6 + j.y * self.blockHeight, self.x + 6 + j.x * self.blockWidth + self.blockWidth, self.y + 6 + j.y * self.blockHeight)
				end

				if j.path[2] == 0 then
					love.graphics.line(self.x + 6 + j.x * self.blockWidth + self.blockWidth, self.y + 6 + j.y * self.blockHeight, self.x + 6 + j.x * self.blockWidth + self.blockWidth, self.y + 6 + j.y * self.blockHeight + self.blockHeight)
				end

				if j.path[3] == 0 then
					love.graphics.line(self.x + 5.5 + j.x * self.blockWidth, self.y + 5.5 + j.y * self.blockHeight + self.blockHeight, self.x + 5.5 + j.x * self.blockWidth + self.blockWidth, self.y + 5.5 + j.y * self.blockHeight + self.blockHeight)
				end

				if j.path[4] == 0 then
					love.graphics.line(self.x + 6 + j.x * self.blockWidth, self.y + 6 + j.y * self.blockHeight, self.x + 6 + j.x * self.blockWidth, self.y + 6 + j.y * self.blockHeight + self.blockHeight)
				end
			else

			end
		end
		love.graphics.pop()

		playerNormalizedX = Player.x / (Maze.width * Maze.tileSize * Maze.roomSize) * 640 * (self.width / 648)
		playerNormalizedY = Player.y / (Maze.height * Maze.tileSize * Maze.roomSize) * 360 * (self.height / 364)
		love.graphics.setColor(0, 1, 0)
		love.graphics.points(self.x + 6 + playerNormalizedX + 1, self.y + 6 + playerNormalizedY + 1)
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(self.frame, self.x, self.y, 0, 1)
	end

	return self
end

return minimap
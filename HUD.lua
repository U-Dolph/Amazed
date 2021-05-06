local HUD = {}

function HUD:new()
	local self = {}

	self.timer = Timer.new()
	self.objectiveFont = love.graphics.newFont("ast/pixelmix.ttf", 8)

	self.minimap = Minimap:new(518, 10, 100, 100)

	self.healthbar = {
		frameImage = love.graphics.newImage("gfx/healthbar2.png"),
		fillImage = love.graphics.newImage("gfx/healthbarFill.png"),
		x = 518,
		y = 127,
		value = 100
	}

	function self:render()
		self.minimap:render()

		love.graphics.setScissor(self.healthbar.x, self.healthbar.y + 1, self.healthbar.fillImage:getWidth() * player.health / player.maxHealth, 8)
		love.graphics.draw(self.healthbar.fillImage, self.healthbar.x, self.healthbar.y + 1)
		love.graphics.setScissor()

		love.graphics.draw(self.healthbar.frameImage, self.healthbar.x, self.healthbar.y)

		local yCoord = 150
		for i, j in ipairs(player.inventory) do
			if j.id == ITEM_TYPES.key then
				love.graphics.draw(tilemap, j.image, 640 - 16 - 8, yCoord, 0, 1, 1, j.renderCenter.x, j.renderCenter.y)
			end
			yCoord = yCoord + 16
		end
	end

	function self:renderLarge()
		local totalRooms, exploredRooms = self.minimap:renderLargeMap()

		love.graphics.setColor(1, 1, 1)
		local renderY = 20

		love.graphics.setFont(self.objectiveFont)
		love.graphics.printf("- MAIN OBJECTIVES -", 5, 5, 140, "center")

		for i, j in ipairs(game.objectives) do
			if j.type == "main" then
				love.graphics.print(j.text, 5, renderY)

				if j.completed then
					love.graphics.setColor(1, 0, 0)
					love.graphics.line(3, renderY + 6, self.objectiveFont:getWidth(j.text) + 6, renderY + 6)
					love.graphics.setColor(1, 1, 1)
				end

				renderY = renderY + 12
			end
		end

		renderY = renderY + 7
		love.graphics.printf("- OPTIONAL OBJECTIVES -", 5, renderY, 140, "center")
		renderY = renderY + 15
		for i, j in ipairs(game.objectives) do
			if j.type == "optional" then
				love.graphics.print(j.text, 5, renderY)

				if j.completed then
					love.graphics.setColor(1, 0, 0)
					love.graphics.line(3, renderY + 6, self.objectiveFont:getWidth(j.text) + 6, renderY + 6)
					love.graphics.setColor(1, 1, 1)
				end

				renderY = renderY + 12
			end
		end

		if totalRooms == exploredRooms then game.objectives[3].completed = true end
		if player.killCount >= game.totalEnemies then game.objectives[4].completed = true end
	end

	return self
end

return HUD
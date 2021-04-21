local HUD = {}

function HUD:new()
	local self = {}

	self.timer = Timer.new()

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
	end

	return self
end

return HUD
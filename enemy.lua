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

	function self:render()
		if self.state == "explosion" then
			self.animations[self.state]:draw(smallExplosionImage, self.x, self.y, 0, 1, 1, 8, 8)
		else
			self.animations[self.state]:draw(animationImage, self.x, self.y, 0, self.direction, 1, 9, 8)
		end

		love.graphics.setColor(0, 1, 0)
		love.graphics.rectangle("fill", self.x - 8, self.y - 10, math.max(16 * self.health / self.maxHealth, 0), 3)
		love.graphics.setColor(1,1,1,1)
	end

	function getCurrentRoom()
		for _, j in ipairs(Maze.rooms) do
			if self.x >= j.renderX and self.x <= j.renderX + j.w and self.y >= j.renderY and self.y <= j.renderY + j.h then
				self.currentRoom = j
			end
		end
	end

	return self
end

return enemy
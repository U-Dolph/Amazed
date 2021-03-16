local player = {}

function player:new(_x, _y)
	local self = {}

	self.x = _x
	self.y = _y

	local grid = anim8.newGrid(16, 32, animationImage:getWidth(), animationImage:getHeight())
	self.idleAnimation = anim8.newAnimation(grid('9-12', 4), 0.10)
	self.runAnimation = anim8.newAnimation(grid('12-16', 4), 0.10)
	self.currentAnimation = self.idleAnimation
	self.isIdle = true
	self.direction = 1

	self.footCollider = world:newRectangleCollider(self.x - 6, self.y + 6, 12, 3)
	self.footCollider:setLinearDamping(5)
	self.footCollider:setFixedRotation(true)
	self.footCollider:setMass(self.footCollider:getMass() / 3)

	function self:update(dt)
		self.isIdle = true

		if love.keyboard.isDown("w") then
			--self.y = self.y - 192 * dt
			self.footCollider:applyForce(0, -20)
			self.isIdle = false

		elseif love.keyboard.isDown("s") then
			--self.y = self.y + 192 * dt
			self.footCollider:applyForce(0, 20)
			self.isIdle = false
		end

		if love.keyboard.isDown("a") then
			--self.x = self.x - 192 * dt
			self.footCollider:applyForce(-20, 0)
			self.isIdle = false
			self.direction = -1

		elseif love.keyboard.isDown("d") then
			--self.x = self.x + 192 * dt
			self.footCollider:applyForce(20, 0)
			self.isIdle = false
			self.direction = 1
		end

		self.x = self.footCollider:getX()
		self.y = self.footCollider:getY() - 6

		if self.isIdle then
			self.currentAnimation = self.idleAnimation
			self.idleAnimation:update(dt)
		else
			self.currentAnimation = self.runAnimation
			self.runAnimation:update(dt)
		end
	end

	function self:render()
		love.graphics.setColor(1, 1, 1, 1)
		--love.graphics.rectangle("fill", self.x, self.y, 16, 16)

		self.currentAnimation:draw(animationImage, self.x, self.y, 0, self.direction, 1, 8, 24)
	end

	return self
end

return player
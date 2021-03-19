local player = {}

function player:new(_x, _y)
	local self = {}

	self.x = _x
	self.y = _y

	local grid = anim8.newGrid(16, 32, animationImage:getWidth(), animationImage:getHeight())
	self.idleAnimation = anim8.newAnimation(grid('9-12', 4), 0.10)
	self.runAnimation = anim8.newAnimation(grid('12-16', 4), 0.10)
	self.dashAnimation = anim8.newAnimation(grid(14,4, 17,4, 15,4), 0.10)
	self.currentAnimation = self.idleAnimation

	local smokeAnimation = love.graphics.newImage("gfx/smoke.png")
	local smokeGrid = anim8.newGrid(32, 32, smokeAnimation:getWidth(), smokeAnimation:getHeight())
	self.smokeAnimation = anim8.newAnimation(smokeGrid('1-9', 1), 0.05, false)
	self.dashPositions = {}
	self.timer = Timer.new()
	self.canDash = true
	self.canDodge = true

	self.sword = {
		image = love.graphics.newImage("gfx/sword.png"),
		angle = 0.6 * math.pi
	}

	self.state = "idle"
	self.direction = 1

	self.footCollider = world:newRectangleCollider(self.x - 6, self.y + 6, 12, 3)
	self.footCollider:setLinearDamping(5)
	self.footCollider:setFixedRotation(true)
	self.footCollider:setMass(self.footCollider:getMass() / 3)

	self.light = lighter:addLight(self.x, self.y, 360, 1, 1, 1)

	function self:update(dt)
		if self.state ~= "dashing" then self.state = "idle" end
		self.timer:update(dt)

		if self.state ~= "dashing" then
			if love.keyboard.isDown("w") then
				self.footCollider:applyForce(0, -20)
				self.state = "running"

			elseif love.keyboard.isDown("s") then
				self.footCollider:applyForce(0, 20)
				self.state = "running"
			end

			if love.keyboard.isDown("a") then
				self.footCollider:applyForce(-20, 0)
				self.state = "running"
				self.direction = -1

			elseif love.keyboard.isDown("d") then
				self.footCollider:applyForce(20, 0)
				self.state = "running"
				self.direction = 1
			end
		end

		self.x = self.footCollider:getX()
		self.y = self.footCollider:getY() - 6

		if self.state == "idle" then
			self.currentAnimation = self.idleAnimation
			self.idleAnimation:update(dt)

		elseif self.state == "running" then
			self.currentAnimation = self.runAnimation
			self.runAnimation:update(dt)

		elseif self.state == "dashing" then
			self.currentAnimation = self.dashAnimation
			self.dashAnimation:update(dt)
		end

		for i, j in ipairs(self.dashPositions) do
			j.anim:update(dt)
			j.lifetime = j.lifetime - dt

			if j.lifetime <= 0 then table.remove(self.dashPositions, i) end
		end

		lighter:updateLight(self.light, self.x, self.y)
	end

	function self:getKeypress(_key)
		local mx, my = love.mouse.getPosition()
		mx, my = cam:toWorld(mx / renderScale, my / renderScale)
		local angle = math.atan2(my - self.y, mx - self.x)

		if _key == "space" and self.canDash then
			self.footCollider:applyLinearImpulse(math.cos(angle) * 15, math.sin(angle) * 15)
			table.insert(self.dashPositions, {x = self.x, y = self.y, anim = self.smokeAnimation:clone(), lifetime = 0.45})
			self.canDash = false
			self.timer:after(0.75, function() self.canDash = true end)
			self.timer:after(0.3, function() self.state = "idle" end)
			self.state = "dashing"
			self.dashAnimation:gotoFrame(1)

			self.direction = mx > self.x and 1 or -1

		elseif _key == "lshift" and self.canDodge then
			self.footCollider:setLinearVelocity(0, 0)
			self.footCollider:applyLinearImpulse(-math.cos(angle) * 7, -math.sin(angle) * 7)
			table.insert(self.dashPositions, {x = self.x, y = self.y, anim = self.smokeAnimation:clone(), lifetime = 0.45, scale = 0.25})
			self.canDodge = false
			self.timer:after(0.5, function() self.canDodge = true end)
		end
	end

	function self:render()
		love.graphics.setColor(1, 1, 1, 1)

		for i, j in ipairs(self.dashPositions) do
			j.anim:draw(smokeAnimation, j.x, j.y, 0, j.scale or 1, j.scale or 1, 16, 16)
		end

		love.graphics.draw(self.sword.image, self.x - 5 * self.direction, self.y + 4, self.sword.angle * -self.direction, 1, 1, 5, 15)
		self.currentAnimation:draw(animationImage, self.x, self.y, 0, self.direction, 1, 8, 24)
	end

	return self
end

return player
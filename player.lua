local player = {}

function player:new()
	local self = {}

	self.x = 0
	self.y = 0

	local grid 		= anim8.newGrid(16, 32, animationImage:getWidth(), animationImage:getHeight())
	local smokeGrid = anim8.newGrid(32, 32, smokeImage:getWidth(), smokeImage:getHeight())

	self.animations = {
		["idle"] = anim8.newAnimation(grid('9-12', 4), 0.10),
		["running"] = anim8.newAnimation(grid('12-16', 4), 0.10),
		["dashing"] = anim8.newAnimation(grid(14,4, 17,4, 15,4), 0.10)
	}

	self.smokeAnimation = anim8.newAnimation(smokeGrid('1-9', 1), 0.05, 'pauseAtEnd')

	self.dashPositions = {}

	self.timer = Timer.new()

	self.canDash = true
	self.canDodge = true
	self.canAttack = true

	self.currentFrame = 0

	self.health = 100
	self.maxHealth = 100
	self.power = 50
	self.moveSpeed = 20
	self.invicible = false

	self.state = "idle"
	self.direction = 1

	self.currentRoom = nil

	self.sword = {
		image = love.graphics.newImage("gfx/sword.png"),
		angle = 0.15 * math.pi,
		xOffset = 5,
		yOffset = 2,
		isDownSwinging = false,

		animationOffsets = {
			["idle"] = {2, 1, 0, 1},
			["running"] = {1, 3, 4, 3, 2},
			["dashing"] = {4, 4, 3}
		}
	}

	self.footCollider = World:newRectangleCollider(self.x - 6, self.y + 6, 12, 3)
	self.footCollider:setLinearDamping(5)
	self.footCollider:setFixedRotation(true)
	self.footCollider:setMass(self.footCollider:getMass() / 3)
	self.footCollider:setCollisionClass("PlayerFoot")

	self.light = lightWorld:addLight(self.x, self.y, 360, 1, 1, 1)

	function self:update(dt)
		if self.state ~= "dashing" then self.state = "idle" end
		self.timer:update(dt)
		self:getCurrentRoom()

		if self.state ~= "dashing" then
			if love.keyboard.isDown("w") then
				self.footCollider:applyForce(0, -self.moveSpeed)
				self.state = "running"

			elseif love.keyboard.isDown("s") then
				self.footCollider:applyForce(0, self.moveSpeed)
				self.state = "running"
			end

			if love.keyboard.isDown("a") then
				self.footCollider:applyForce(-self.moveSpeed, 0)
				self.state = "running"
				self.direction = -1

			elseif love.keyboard.isDown("d") then
				self.footCollider:applyForce(self.moveSpeed, 0)
				self.state = "running"
				self.direction = 1
			end
		end

		self.currentFrame = self.animations[self.state]:update(dt)

		self.x = self.footCollider:getX()
		self.y = self.footCollider:getY() - 6

		for i, j in ipairs(self.dashPositions) do
			j.anim:update(dt)
			j.lifetime = j.lifetime - dt

			if j.lifetime <= 0 then table.remove(self.dashPositions, i) end
		end

		if self.footCollider:enter("EnemyFoot") and not self.invicible and self.state ~= "dashing" then
			local collision_data = self.footCollider:getEnterCollisionData('EnemyFoot')
    		local enemy = collision_data.collider:getObject()

			angle = lume.angle(self.x, self.y, enemy.x, enemy.y)
			self.health = self.health - 10
			self.invicible = true

			self.timer:after(0.5, function () self.invicible = false end)

			self.footCollider:applyLinearImpulse(math.cos(angle) * -5, math.sin(angle) * -5)
		end

		lightWorld:updateLight(self.light, self.x, self.y)
	end

	function self:getKeypress(_key)
		local mx, my = love.mouse.getPosition()
		mx, my = cam:toWorld(mx / renderScale, my / renderScale)
		local angle = math.atan2(my - self.y, mx - self.x)

		if _key == "space" and self.canDash then
			self.footCollider:applyLinearImpulse(math.cos(angle) * 15, math.sin(angle) * 15)

			table.insert(self.dashPositions, {x = self.x, y = self.y, anim = self.smokeAnimation:clone(), lifetime = 0.45})

			self.direction = mx > self.x and 1 or -1
			self.canDash = false
			self.canAttack = false
			self.state = "dashing"

			self.animations[self.state]:gotoFrame(1)

			self.timer:after(0.75, function() self.canDash = true end)
			self.timer:after(0.3, function()
				self.state = "idle"
				self.timer:tween(0.1, self.sword, {angle = 0.15 * math.pi}, "out-cubic", function ()
					self.canAttack = true
				end)
			end)

			self.timer:tween(0.05, self.sword, {angle = 0.5 * math.pi}, "out-cubic")

		elseif _key == "lshift" and self.canDodge then
			self.footCollider:setLinearVelocity(0, 0)
			self.footCollider:applyLinearImpulse(-math.cos(angle) * 7, -math.sin(angle) * 7)
			table.insert(self.dashPositions, {x = self.x, y = self.y, anim = self.smokeAnimation:clone(), lifetime = 0.45, scale = 0.25})
			self.canDodge = false
			self.timer:after(0.5, function() self.canDodge = true end)

			self.direction = mx > self.x and 1 or -1
		end
	end

	function self:getMousepresses(_x, _y, _button)
		_x, _y = cam:toWorld(_x / renderScale, _y / renderScale)

		if _button == 1 and self.canAttack then
			self.direction = _x > self.x and 1 or -1
			self.canAttack = false
			self.sword.isDownSwinging = true
			self.timer:tween(0.08, self.sword, {angle = 0.5 * math.pi, xOffset = 10, yOffset = 5}, "out-cubic", function()
				self.sword.isDownSwinging = false
				self.timer:tween(0.05, self.sword, {angle = 0.15 * math.pi, xOffset = 5, yOffset = 2}, "in-linear")
			end)

			self.timer:after(0.2, function() self.canAttack = true end)

			local colliders = world:queryRectangleArea(self.x + math.min(self.direction, 0) * 21, self.y - 8, 21, 18, {"EnemyFoot"})
			for _, collider in ipairs(colliders) do
				angle = lume.angle(self.x, self.y, collider:getX(), collider:getY())
				collider:applyLinearImpulse(math.cos(angle) * 15, math.sin(angle) * 15)
				local enemy = collider:getObject()
				enemy:takeDamage(self.power)
			end
		end
	end

	function self:render()
		love.graphics.setColor(1, 1, 1, 1)

		for _, j in ipairs(self.dashPositions) do
			j.anim:draw(smokeImage, j.x, j.y, 0, j.scale or 1, j.scale or 1, 16, 16)
		end

		love.graphics.draw(self.sword.image, self.x + self.sword.xOffset * self.direction, self.y + self.sword.yOffset - self.sword.animationOffsets[self.state][self.currentFrame], self.sword.angle * self.direction, 1, 1, 5, 15)
		self.animations[self.state]:draw(animationImage, self.x, self.y, 0, self.direction, 1, 8, 24)

		--love.graphics.rectangle("line", self.x + math.min(self.direction, 0) * 21, self.y - 8, 21, 18)
	end

	function self:getCurrentRoom(_maze)
		local RoomHorizontalIndex = math.ceil(self.x / (maze.roomSize * maze.tileSize))
		local RoomVerticalIndex = math.floor(self.y / (maze.roomSize * maze.tileSize))
		self.currentRoom = maze.rooms[RoomVerticalIndex * maze.width + RoomHorizontalIndex]
		--print(RoomHorizontalIndex, RoomVerticalIndex)
	end

	function self:setPosition(_x, _y)
		self.x = _x
		self.y = _y
	end

	return self
end

return player
local player = {}

function player:new()
	local self = {}

	self.x = 0
	self.y = 0

	local grid 		= anim8.newGrid(16, 32, animationImage:getWidth(), animationImage:getHeight())
	local smokeGrid = anim8.newGrid(32, 32, smokeImage:getWidth(), smokeImage:getHeight())
	local swingGrid = anim8.newGrid(64, 64, swingImage:getWidth(), swingImage:getHeight())

	self.animations = {
		["idle"] = anim8.newAnimation(grid('9-12', 4), 0.10),
		["running"] = anim8.newAnimation(grid('12-16', 4), 0.10),
		["dashing"] = anim8.newAnimation(grid(14,4, 17,4, 15,4), 0.10)
	}

	self.smokeAnimation = anim8.newAnimation(smokeGrid('1-9', 1), 0.05, 'pauseAtEnd')
	self.swingAnimation = anim8.newAnimation(swingGrid('1-10', 1), 0.02, 'pauseAtEnd')

	self.dashPositions = {}
	self.swingPositions = {}

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
	self.defense = 20

	self.inventory = {}

	self.killCount = 0
	self.dealtDamage = 0
	self.receivedDamage = 0

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
	self.footCollider:setObject(self)

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

		for i, j in ipairs(self.swingPositions) do
			j.anim:update(dt)
			j.lifetime = j.lifetime - dt

			if j.lifetime <= 0 then table.remove(self.swingPositions, i) end
		end

		local mx, my = love.mouse.getPosition()
		mx, my = playerCam:toWorld(mx / renderScale, my / renderScale)

		if not self.sword.isDownSwinging then
			self.sword.angle = lume.angle(self.x, self.y, mx, my) - math.pi / 2
		end
		self.sword.yOffset = math.sin(self.sword.angle - math.pi / 2) * 5 + 2
		self.sword.xOffset = math.cos(self.sword.angle - math.pi / 2) * 5

		if self.footCollider:enter('Item') then
			local collision_data = self.footCollider:getEnterCollisionData('Item')
			local itemPickedUp = collision_data.collider:getObject()
			itemPickedUp:pickUp()
		end

		lightWorld:updateLight(self.light, self.x, self.y)
	end

	function self:dash()
		local mx, my = love.mouse.getPosition()
		mx, my = playerCam:toWorld(mx / renderScale, my / renderScale)
		local angle = math.atan2(my - self.y, mx - self.x)

		if self.canDash then
			self.footCollider:applyLinearImpulse(math.cos(angle) * 15, math.sin(angle) * 15)

			table.insert(self.dashPositions, {x = self.x, y = self.y, anim = self.smokeAnimation:clone(), lifetime = 0.45})

			self.direction = mx > self.x and 1 or -1
			self.canDash = false
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
		end
	end

	function self:attack(mx, my)
		mx, my = playerCam:toWorld(mx / renderScale, my / renderScale)
		local _angle = lume.angle(self.x, self.y, mx, my)

		if self.canAttack then
			self.direction = mx > self.x and 1 or -1
			self.canAttack = false

			self.sword.isDownSwinging = true

			self.timer:tween(0.15, self.sword, {angle = _angle + 1 + math.pi / 2}, "out-cubic", function()
				self.sword.isDownSwinging = false
			end)

			self.timer:after(0.2, function() self.canAttack = true end)

			table.insert(self.swingPositions, {x = self.x + math.cos(_angle) * 24, y = self.y + math.sin(_angle) * 24, angle = _angle, anim = self.swingAnimation:clone(), lifetime = 0.20})

			local colliders = World:queryCircleArea(self.x + math.cos(_angle) * 24, self.y + math.sin(_angle) * 24, 28, {"EnemyFoot"})
			for _, collider in ipairs(colliders) do
				local enemy = collider:getObject()
				enemy:takeDamage(self.power)

				if not enemy.isAttacking then
					enemy:noticePlayer()
				end
			end
		end
	end

	function self:takeDamage(value)
		if not self.invicible and self.health > 0 then
			local damage = math.max(1, (value - self.defense) + love.math.random(-4, 4))
			popupHandler:addElement(damage, self.x - 32, self.y - 18, {1, 0.5, 0})
			self.health = self.health - damage
			self.invicible = true

			self.timer:after(0.3, function ()
				self.invicible = false
			end)

			self.receivedDamage = self.receivedDamage + damage
		end

		if self.health <= 0 then
			Gamestate.switch(gameover, "failure")
		end
	end

	function self:render()
		love.graphics.setColor(1, 1, 1, 1)

		for _, j in ipairs(self.dashPositions) do
			j.anim:draw(smokeImage, j.x, j.y, 0, j.scale or 1, j.scale or 1, 16, 16)
		end

		for _, j in ipairs(self.swingPositions) do
			j.anim:draw(swingImage, j.x, j.y, j.angle, j.scale or 1, j.scale or 1, 32, 32)
		end

		love.graphics.draw(self.sword.image, self.x + self.sword.xOffset, self.y + self.sword.yOffset - self.sword.animationOffsets[self.state][self.currentFrame], self.sword.angle, 1, 1, 5, 15)
		self.animations[self.state]:draw(animationImage, self.x, self.y, 0, self.direction, 1, 8, 24)

		if self.currentRoom.node == maze.endNode and lume.distance(self.x, self.y, self.currentRoom.renderX + maze.roomSize/2 * maze.tileSize, self.currentRoom.renderY) < 30 then
			love.graphics.rectangle("fill", self.currentRoom.renderX + maze.roomSize/2 * maze.tileSize - 6, self.currentRoom.renderY, 12, 12, 3)
			love.graphics.setFont(popupHandler.font)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.print("E", self.currentRoom.renderX + maze.roomSize/2 * maze.tileSize - 3, self.currentRoom.renderY + 2)
			love.graphics.setColor(1, 1, 1)
		end
	end

	function self:getCurrentRoom()
		local RoomHorizontalIndex = math.ceil(self.x / (maze.roomSize * maze.tileSize))
		local RoomVerticalIndex = math.floor(self.y / (maze.roomSize * maze.tileSize))
		self.currentRoom = maze.rooms[RoomVerticalIndex * maze.width + RoomHorizontalIndex]
		--print(RoomHorizontalIndex, RoomVerticalIndex)
	end

	function self:setPosition(_x, _y)
		self.x = _x
		self.y = _y

		self.footCollider:setPosition(self.x, self.y)
		--self.footCollider = World:newRectangleCollider(self.x - 6, self.y + 6, 12, 3)
	end

	return self
end

return player
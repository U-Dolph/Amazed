local smallEnemy = {}

function smallEnemy:new(_x, _y)
	local self = enemy:new(_x, _y)

	local grid = anim8.newGrid(16, 16, animationImage:getWidth(), animationImage:getHeight())
	local explosionGrid = anim8.newGrid(16, 16, smallExplosionImage:getWidth(), smallExplosionImage:getHeight())
	local rnd = love.math.random(2, 4)
	self.speed = 15

	self.animations = {
		["idle"] = anim8.newAnimation(grid('24-27', rnd), 0.10),
		["running"] = anim8.newAnimation(grid('27-31', rnd), 0.10),
		["explosion"] = anim8.newAnimation(explosionGrid('1-8', 1), 0.1)
	}

	--[[self.timer:every(0.1, function ()
		self.currentRoom = getCurrentRoom(self)
	end)]]

	self.timer:every(1, function ()
		if self.isAttacking and self.alive then
			self.path = self:findPath(Player)
		end
	end)

	function self:update(dt)
		local xCoord, yCoord = cam:toScreen(self.x, self.y)

		self.timer:update(dt)
		self.animations[self.state]:update(dt)
		self.currentRoom = self:getCurrentRoom()

		if self.health > 0 then
			if xCoord > 0 - 16 + 100 and xCoord < 640 - 100 and yCoord > 0 - 16 + 100 and yCoord < 360 - 100 then
				--self.isAttacking = true
				if not self.footCollider then self:createCollider() end

				if #self.path > 0 then
					self.path[1][1] = Player.x
					self.path[1][2] = Player.y
				end

				self.x = self.footCollider:getX()
				self.y = self.footCollider:getY() - 6

				self.bodyCollider:setPosition(self.x, self.y + 2)

				if self.bodyCollider:enter('PlayerFoot') and Player.state == "dashing" and not self.invicible then
					self.invicible = true
					self.health = self.health - 50

					self.timer:after(0.3, function () self.invicible = false end)

					angle = lume.angle(self.x, self.y, Player.x, Player.y)
					self.footCollider:applyLinearImpulse(math.cos(angle) * -15, math.sin(angle) * -15)
				end

			else
				if self.footCollider then
					self.footCollider:destroy()
					self.bodyCollider:destroy()
					self.footCollider = nil
					self.bodyCollider = nil
				end

				self.isAttacking = false
				self.path = {}
			end
		end

		if self.health <= 0 then
			if self.state ~= "explosion" then
				self.state = "explosion"
				self.footCollider:destroy()
				self.bodyCollider:destroy()
				self.timer:after(0.8, function() self.alive = false end)
			end
		end
	end

	function self:createCollider()
		self.footCollider = world:newRectangleCollider(self.x - 6, self.y + 4.5, 12, 3)
		self.footCollider:setLinearDamping(5)
		self.footCollider:setFixedRotation(true)
		self.footCollider:setCollisionClass("EnemyFoot")
		self.footCollider:setObject(self)

		self.bodyCollider = world:newRectangleCollider(self.x, self.y - 5, 12, 11)
		self.bodyCollider:setFixedRotation(true)
		self.bodyCollider:setCollisionClass("EnemyBody")
		self.bodyCollider:setObject(self)
	end

	function self:takeDamage(value)
		self.health =self.health - value
	end

	return self
end

return smallEnemy
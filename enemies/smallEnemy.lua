local smallEnemy = {}

function smallEnemy:new(_x, _y)
	local self = Enemy:new(_x, _y)

	local grid = anim8.newGrid(16, 16, animationImage:getWidth(), animationImage:getHeight())
	local explosionGrid = anim8.newGrid(16, 16, smallExplosionImage:getWidth(), smallExplosionImage:getHeight())
	local rnd = love.math.random(2, 4)
	self.speed = 25
	self.power = 35
	self.defense = 15

	self.animations = {
		["idle"] = anim8.newAnimation(grid('24-27', rnd), 0.10),
		["running"] = anim8.newAnimation(grid('27-31', rnd), 0.10),
		["explosion"] = anim8.newAnimation(explosionGrid('1-8', 1), 0.1),
		["attacking"] = anim8.newAnimation(grid('27-31', rnd), 0.10),
	}

	--[[self.timer:every(1, function ()
		if self.isAttacking and self.health > 0 and self.currentRoom.visible then
			self.path = self:findPath(player)
		end
	end)]]

	function self:update(dt)
		self.timer:update(dt)
		self.animations[self.state]:update(dt)
		self.currentRoom = self:getCurrentRoom()

		if self.health > 0 then
			if self.currentRoom.visible then
				if not self.footCollider then self:createCollider() end

				self.path = self:findPath(player)

				self.path[1][1] = player.x
				self.path[1][2] = player.y
				self.path[#self.path] = {self.path[#self.path][1], self.path[#self.path][2], self.x, self.y}

				self.x = self.footCollider:getX()
				self.y = self.footCollider:getY() - 6

				self.bodyCollider:setPosition(self.x, self.y + 2)

				local function worldRayCastCallback(fixture, x, y, xn, yn, fraction)
					if fixture == player.footCollider.fixture and not self.isAttacking then
						self:noticePlayer()
					end

					return 0
				end

				for i = 0, 18 do
					World:rayCast(self.x, self.y, self.x + math.cos(math.pi/18 * i - math.pi/2) * 100 * self.direction, self.y + math.sin(math.pi/18 * i - math.pi/2) * 100, worldRayCastCallback)
				end


				if self.isAttacking and self.state ~= "attacking" then
					self:move()
				end

				

				if self.isAttacking then
					self.direction = player.x > self.x and 1 or -1

					if self.playerPrevKnownRoom ~= player.currentRoom or self.prevKnownRoom ~= self.currentRoom then
						self.playerPrevKnownRoom = player.currentRoom
						self.prevKnownRoom = self.currentRoom
						self.path = self:findPath(player)
					end

					if lume.distance(self.x, self.y, player.x, player.y) < 50 then
						if self.canAttack then self:attack() end
					end
				end

				if self.bodyCollider:enter('PlayerFoot') and player.state == "dashing" then	
					self:takeDamage(player.power)
					if not self.isAttacking then
						self:noticePlayer()
					end
				end

				if self.bodyCollider:enter('PlayerFoot') and self.state == "attacking" and not player.invicible then
					player:takeDamage(self.power)
					angle = lume.angle(self.x, self.y, player.x, player.y)
					player.footCollider:applyLinearImpulse(math.cos(angle) * 5, math.sin(angle) * 5)
				end
			else
				if self.footCollider then
					self.footCollider:destroy()
					self.bodyCollider:destroy()
					self.footCollider = nil
					self.bodyCollider = nil
				end

				self.path = {}
			end

		elseif self.health <= 0 then
			if self.attackHandler then self.timer:cancel(self.attackHandler) end

			if self.state ~= "explosion" then
				self.state = "explosion"
				if self.footCollider and not self.footCollider:isDestroyed() then self.footCollider:destroy() end
				if self.bodyCollider and not self.bodyCollider:isDestroyed() then self.bodyCollider:destroy() end
				self.footCollider = nil
				self.bodyCollider = nil
				self.timer:after(0.8, function() self.alive = false end)
			end
		end
	end

	function self:createCollider()
		self.footCollider = World:newRectangleCollider(self.x - 6, self.y + 4.5, 12, 3)
		self.footCollider:setLinearDamping(5)
		self.footCollider:setFixedRotation(true)
		self.footCollider:setCollisionClass("EnemyFoot")
		self.footCollider:setObject(self)

		self.bodyCollider = World:newRectangleCollider(self.x, self.y - 5, 12, 11)
		self.bodyCollider:setFixedRotation(true)
		self.bodyCollider:setCollisionClass("EnemyBody")
		self.bodyCollider:setObject(self)
	end

	function self:attack()
		self.canAttack = false
		self.canMove = false

		popupHandler:addElement("!", self.x, self.y - 18, {1, 1, 0})

		self.attackHandler = self.timer:after(0.5, function ()
			local _angle = lume.angle(self.x, self.y, player.x, player.y)
			self.state = "attacking"

			if self.footCollider then self.footCollider:applyLinearImpulse(math.cos(_angle) * 30, math.sin(_angle) * 30) end
			self.timer:after(1, function ()
				self.canAttack = true
			end)
			self.timer:after(0.2, function ()
				self.state = "idle"
				self.canMove = true
			end)
		end)
	end

	return self
end

return smallEnemy
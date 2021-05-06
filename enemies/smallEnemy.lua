local smallEnemy = {}

function smallEnemy:new(_x, _y)
	local self = Enemy:new(_x, _y)

	local grid = anim8.newGrid(16, 16, animationImage:getWidth(), animationImage:getHeight())
	local explosionGrid = anim8.newGrid(16, 16, smallExplosionImage:getWidth(), smallExplosionImage:getHeight())
	local rnd = love.math.random(2, 4)

	self.speed = 50
	self.power = 35
	self.defense = 15

	self.animations = {
		["idle"] = anim8.newAnimation(grid('24-27', rnd), 0.10),
		["running"] = anim8.newAnimation(grid('27-31', rnd), 0.10),
		["explosion"] = anim8.newAnimation(explosionGrid('1-8', 1), 0.1),
		["attacking"] = anim8.newAnimation(grid('27-31', rnd), 0.10),
	}

	self.noticeSound = Audio.Effects.smallEnemyNotice
	self.hitSound = Audio.Effects.smallEnemyHit

	function self:update(dt)
		self.timer:update(dt)
		self.animations[self.state]:update(dt)
		self.currentRoom = self:getCurrentRoom()

		if self.health > 0 then
			if self.currentRoom.visible then
				if not self.footCollider then self:createCollider() end

				self.x = self.footCollider:getX()
				self.y = self.footCollider:getY() - 6

				self.bodyCollider:setPosition(self.x, self.y + 2)

				if not self.isAttacking then self:lookAround() end

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

					if # self.path > 0 then
						self.path[1][1] = player.x
						self.path[1][2] = player.y
						self.path[#self.path] = {self.path[#self.path][1], self.path[#self.path][2], self.x, self.y}
					end

					if lume.distance(self.x, self.y, player.x, player.y) < 50 then
						if self.canAttack then self:attack() end
					end
				end

				if self.bodyCollider:enter('PlayerFoot') then
					if player.state == "dashing" then self:takeDamage(player.power) end
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
				if self.footCollider then self.footCollider:destroy() end
				if self.bodyCollider then self.bodyCollider:destroy() end
				self.footCollider = nil
				self.bodyCollider = nil
				self.timer:after(0.8, function() self.alive = false player.killCount = player.killCount + 1 end)
			end
		end
	end

	function self:createCollider()
		self.footCollider = World:newRectangleCollider(self.x - 6, self.y + 4.5, 12, 3)
		self.footCollider:setLinearDamping(10)
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

		popupHandler:addElement("!", self.x - 32, self.y - 18, {1, 1, 0})

		self.attackHandler = self.timer:after(0.5, function ()
			local _angle = lume.angle(self.x, self.y, player.x, player.y)
			self.state = "attacking"

			if self.footCollider then self.footCollider:applyLinearImpulse(math.cos(_angle) * 45, math.sin(_angle) * 45) end
			self.timer:after(1, 	function () self.canAttack 	= true end)
			self.timer:after(0.2, 	function () self.state 		= "idle" end)
			self.timer:after(0.75, 	function () self.canMove 	= true end)
		end)
	end

	return self
end

return smallEnemy
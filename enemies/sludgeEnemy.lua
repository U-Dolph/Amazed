local sludgeEnemy = {}

function sludgeEnemy:new(_x, _y)
	local self = Enemy:new(_x, _y)

	local grid = anim8.newGrid(16, 16, animationImage:getWidth(), animationImage:getHeight())
	local explosionGrid = anim8.newGrid(16, 16, smallExplosionImage:getWidth(), smallExplosionImage:getHeight())
	local rnd = love.math.random(0, 1)

	self.speed = 65
	self.power = 55
	self.defense = 25

	--tostring(24 + rnd * 4 .. '-' .. 25 + rnd * 4)

	self.animations = {
		["idle"] = anim8.newAnimation(grid(tostring(24 + rnd * 4 .. '-' .. 25 + rnd * 4), 8, 27 + rnd * 4, 8), 0.10),
		["running"] = anim8.newAnimation(grid(tostring(24 + rnd * 4 .. '-' .. 27 + rnd * 4), 8), 0.10),
		["explosion"] = anim8.newAnimation(explosionGrid('1-8', 1), 0.1),
		["attacking"] = anim8.newAnimation(grid(tostring(25 + rnd * 4 .. '-' .. 27 + rnd * 4), 8), 0.10)
	}

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

				if self.isAttacking then
					self.direction = player.x > self.x and 1 or -1

					if self.playerPrevKnownRoom ~= player.currentRoom or self.prevKnownRoom ~= self.currentRoom then
						self.playerPrevKnownRoom = player.currentRoom
						self.prevKnownRoom = self.currentRoom
						self.path = self:findPath(player)
					end

					self.path[1][1] = player.x
					self.path[1][2] = player.y
					self.path[#self.path] = {self.path[#self.path][1], self.path[#self.path][2], self.x, self.y}

					if lume.distance(self.x, self.y, player.x, player.y) < 20 then
						if self.canAttack then self:attack() end
					end

					if self.state ~= "attacking" then
						self:move()
					end
				else
					self:lookAround()
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
				player.killCount = player.killCount + 1
				self.state = "explosion"
				if self.footCollider then self.footCollider:destroy() end
				if self.bodyCollider then self.bodyCollider:destroy() end
				self.footCollider = nil
				self.bodyCollider = nil
				self.timer:after(0.8, function() self.alive = false end)
			end
		end
	end

	function self:createCollider()
		self.footCollider = World:newRectangleCollider(self.x - 8, self.y + 4.5, 16, 3)
		self.footCollider:setLinearDamping(10)
		self.footCollider:setFixedRotation(true)
		self.footCollider:setCollisionClass("EnemyFoot")
		self.footCollider:setObject(self)

		self.bodyCollider = World:newRectangleCollider(self.x, self.y - 5, 16, 11)
		self.bodyCollider:setFixedRotation(true)
		self.bodyCollider:setCollisionClass("EnemyBody")
		self.bodyCollider:setObject(self)
	end

	function self:attack()
		self.canAttack = false
		self.canMove = false

		popupHandler:addElement("!", self.x - 32, self.y - 18, {1, 1, 0})

		self.attackHandler = self.timer:after(0.3, function ()
			local _angle = lume.angle(self.x, self.y, player.x, player.y)
			self.state = "attacking"

			local colliders = World:queryRectangleArea(self.x + math.min(self.direction, 0) * 20, self.y - 12, 20, 32, {"PlayerFoot"})
			for _, collider in ipairs(colliders) do
				local _player = collider:getObject()
				_player:takeDamage(self.power)
				angle = lume.angle(self.x, self.y, player.x, player.y)
				player.footCollider:applyLinearImpulse(math.cos(angle) * 10, math.sin(angle) * 10)
			end

			self.timer:after(0.6, 	function () self.canAttack 	= true end)
			self.timer:after(0.3, 	function () self.state 		= "idle" end)
			self.timer:after(0.3, 	function () self.canMove 	= true end)
		end)
	end

	return self
end

return sludgeEnemy
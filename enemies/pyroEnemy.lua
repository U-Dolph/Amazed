local pyroEnemy = {}

function pyroEnemy:new(_x, _y)
	local self = Enemy:new(_x, _y)

    local grid = anim8.newGrid(16, 32, animationImage:getWidth(), animationImage:getHeight())
	local explosionGrid = anim8.newGrid(16, 16, smallExplosionImage:getWidth(), smallExplosionImage:getHeight())
    local attackGrid = anim8.newGrid(48, 48, animationImage:getWidth(), animationImage:getHeight())

    self.speed = 100
	self.power = 75
	self.defense = 5
    self.verticalAnimOffset = 16

    self.animations = {
		["idle"] = anim8.newAnimation(grid('24-27', 8), 0.10),
		["running"] = anim8.newAnimation(grid('27-31', 8), 0.10),
		["explosion"] = anim8.newAnimation(explosionGrid('1-8', 1), 0.1),
		["attacking"] = anim8.newAnimation(attackGrid('1-18', 11), 0.05),
	}

    self.noticeSound = Audio.Effects.smallEnemyNotice
	self.hitSound = Audio.Effects.smallEnemyHit
	self.deathSound = Audio.Effects.smallEnemyDeath

    function self:update(dt)
		self.timer:update(dt)
		self.animations[self.state]:update(dt)
		self.currentRoom = self:getCurrentRoom()

		if self.health > 0 then
			if self.currentRoom.visible then
				if not self.footCollider then self:createCollider() end

				self.x = self.footCollider:getX()
				self.y = self.footCollider:getY() - 6

				self.bodyCollider:setPosition(self.x, self.y + 2 - 2)

				if not self.isAttacking then self:lookAround() end

				if self.isAttacking then
                    if self.state ~= "attacking" then self:move() self.horizontalAnimOffset = 0 end

					self.direction = player.x > self.x and 1 or -1

					if self.playerPrevKnownRoom ~= player.currentRoom or self.prevKnownRoom ~= self.currentRoom then
						self.playerPrevKnownRoom = player.currentRoom
						self.prevKnownRoom = self.currentRoom
						self.path = self:findPath(player)
					end

					if #self.path > 0 then
						self.path[1][1] = player.x
						self.path[1][2] = player.y
						self.path[#self.path] = {self.path[#self.path][1], self.path[#self.path][2], self.x, self.y}
					end

                    if lume.distance(self.x, self.y, player.x, player.y) < 30 then
						if self.canAttack then self:attack() end
					end
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

		self.bodyCollider = World:newRectangleCollider(self.x, self.y - 5, 12, 13)
		self.bodyCollider:setFixedRotation(true)
		self.bodyCollider:setCollisionClass("EnemyBody")
		self.bodyCollider:setObject(self)
	end

	function self:attack()
		self.canAttack = false
		self.canMove = false

		popupHandler:addElement("!", self.x - 32, self.y - 18, {1, 1, 0})

		self.attackHandler = self.timer:after(0.25, function ()
			local _angle = lume.angle(self.x, self.y, player.x, player.y)
			self.state = "attacking"
            self.horizontalAnimOffset = 24 - 9
            self.invicible = true
            Audio.Effects.pyroEnemyClick:play()
            self.timer:after(0.3, function ()
                Audio.Effects.pyroEnemyBlast:play()
            end)

			self.timer:after(8 * 0.05, 	function ()
                local colliders = World:queryCircleArea(self.x, self.y, 48, {"PlayerFoot"})
                for _, collider in ipairs(colliders) do
                    local entity = collider:getObject()
                    entity:takeDamage(self.power)
                    entity.footCollider:applyLinearImpulse(math.cos(_angle) * 20, math.sin(_angle) * 20)
                end
            end)
			self.timer:after(0.9, 	function () self.health = 0 player.killCount = math.max(0, player.killCount - 1) end)
		end)
	end

	return self
end

return pyroEnemy
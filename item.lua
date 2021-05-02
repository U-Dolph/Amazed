ITEM_TYPES = {
	healthPotion = {ID = 1, heals = 20}
}

local item = {}

function item:new(_x, _y, _id)
	local self = {}

	self.x = _x
	self.y = _y

	self.image = nil
	self.id = _id
	self.display = false
	self.collider = nil

	self.pickedUp = false

	function self:update(dt)
	end

	function self:render()
		if self.display and not self.pickedUp then
			love.graphics.draw(animationImage, self.image, self.collider:getX(), self.collider:getY(), 0, 1, 1, 8, 10)
		end
	end

	function self:setImage()
		if self.id == ITEM_TYPES.healthPotion then self.image = healthPotionImage end
	end

	function self:drop()
		self:setImage()
		self.collider = World:newCircleCollider(self.x, self.y, 6)
		self.collider:setLinearDamping(3)
		local angle = love.math.random(180, 360) / 180 * -math.pi
		self.collider:applyLinearImpulse(math.cos(angle) * 10, math.sin(angle) * 10)
		self.collider:setCollisionClass("Item")
		self.display = true

		self.collider:setObject(self)
	end

	function self:pickUp()
		if self.id == ITEM_TYPES.healthPotion then
			if player.health ~= player.maxHealth then
				self.pickedUp = true
				self.collider:destroy()
				self.display = false

				print(self.display)

				local healAmount = math.min(ITEM_TYPES.healthPotion.heals, player.maxHealth - player.health)
				player.health = player.health + healAmount
				popupHandler:addElement("+" .. healAmount .. " HP", player.x - 32, player.y - 18, {0, 1, 0})
			else
				popupHandler:addElement("MAX HP!", player.x - 32, player.y - 18, {0, 1, 1})
			end
		end
	end

	return self
end

return item
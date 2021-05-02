ITEM_TYPES = {
	healthPotion = {ID = 1, heals = 20},
	key = {ID = 2}
}

local item = {}

function item:new(_x, _y, _id)
	local self = {}

	self.x = _x
	self.y = _y

	self.renderCenter = {x = 0, y = 0}

	self.image = nil
	self.id = _id
	self.display = false
	self.collider = nil

	self.pickedUp = false

	function self:update(dt)
	end

	function self:render()
		if self.display and not self.pickedUp then
			if self.id == ITEM_TYPES.healthPotion then
				love.graphics.draw(animationImage, self.image, self.collider:getX(), self.collider:getY(), 0, 1, 1, self.renderCenter.x, self.renderCenter.y)
			elseif self.id == ITEM_TYPES.key then
				love.graphics.draw(tilemap, self.image, self.collider:getX(), self.collider:getY(), 0, 1, 1, self.renderCenter.x, self.renderCenter.y)
			end
		end
	end

	function self:setImage()
		if self.id == ITEM_TYPES.healthPotion then
			self.image = healthPotionImage
			self.renderCenter = {x = 8, y = 10}
		elseif self.id == ITEM_TYPES.key then
			self.image = keyImage
			self.renderCenter = {x = 9, y = 9}
		end
	end

	function self:createCollider()
		if self.id == ITEM_TYPES.healthPotion then self.collider = World:newCircleCollider(self.x, self.y, 6)
		elseif self.id == ITEM_TYPES.key then self.collider = World:newRectangleCollider(self.x - 5.5, self.y - 4, 11, 8) end
	end

	function self:drop()
		self:setImage()
		self:createCollider()

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

				local healAmount = math.min(ITEM_TYPES.healthPotion.heals, player.maxHealth - player.health)
				player.health = player.health + healAmount
				popupHandler:addElement("+" .. healAmount .. " HP", player.x - 32, player.y - 18, {0, 1, 0})
			else
				popupHandler:addElement("MAX HP!", player.x - 32, player.y - 18, {0, 1, 1})
			end

		elseif self.id == ITEM_TYPES.key then
			self.pickedUp = true
			self.collider:destroy()
			self.display = false
			popupHandler:addElement("Found 1 key", player.x - 32, player.y - 18, {1, 1, 0})

			table.insert(player.inventory, self)
		end

		table.sort(player.inventory, function (a, b)
			return a.id.ID > b.id.ID
		end)
	end

	return self
end

return item
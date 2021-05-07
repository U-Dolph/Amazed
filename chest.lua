local chest = {}

function chest:new(_x, _y)
	local self = {}

	self.x = _x
	self.y = _y

	self.currentRoom = nil
	self.image = chestImages[1]
	self.collider = nil
	self.opened = false

	self.items = {}

	function self:update(dt)
		if #self.items == 0 then self.items = self:fillChest() end

		self.currentRoom = self:getCurrentRoom()

		if self.currentRoom.visible and not self.collider then
			self.collider = World:newRectangleCollider(self.x, self.y - 6, 16, 14)
			self.collider:setCollisionClass("Chest")
			self.collider:setType("static")

		elseif not self.currentRoom.visible and self.collider then
			self.collider:destroy()
			self.collider = nil
		end

		for i, j in ipairs (self.items) do
			j:update(dt)

			if j.pickedUp then
				table.remove(self.items, i)
			end
		end
	end

	function self:render()
		love.graphics.draw(animationImage, self.image, self.x, self.y, 0, 1, 1, 0, 8)

		if lume.distance(self.x + 8, self.y, player.x, player.y) < 30 and not self.opened then
			love.graphics.rectangle("fill", self.x + 2, self.y - 4 - 8 - 4, 12, 12, 3)
			love.graphics.setFont(popupHandler.font)
			love.graphics.setColor(0, 0, 0, 1)
			love.graphics.print("E", self.x + 5, self.y + 9 - 20 - 4)
			love.graphics.setColor(1, 1, 1)
		end

		for i, j in ipairs(self.items) do
			j:render()
		end
	end

	function self:getCurrentRoom()
		local RoomHorizontalIndex 	= math.ceil(self.x / (maze.roomSize * maze.tileSize))
		local RoomVerticalIndex 	= math.floor(self.y / (maze.roomSize * maze.tileSize))
		return maze.rooms[RoomVerticalIndex * maze.width + RoomHorizontalIndex]
	end

	function self:fillChest()
		local items = {}

		table.insert(items, item:new(self.x + 8, self.y + 12, ITEM_TYPES.healthPotion))

		return items
	end

	function self:open()
		self.opened = true
		self.image = chestImages[2]
		Audio.Effects.chestOpen:play()

		for i, j in ipairs(self.items) do
			j:drop()
		end
	end

	return self
end

return chest
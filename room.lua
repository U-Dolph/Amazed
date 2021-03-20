local room = {}

function room:new(_x, _y, _tileSize, _roomSize)
	local self = {}

	self.x = _x
	self.y = _y
	self.size = _roomSize
	self.tileSize = _tileSize
	self.w = self.tileSize * self.size
	self.h = self.tileSize * self.size

	self.renderX = self.x * self.w
	self.renderY = self.y * self.h

	self.visited = false
	self.previsited = love.math.noise(self.x / 10 + Maze.noiseOffsetX, self.y / 10 + Maze.noiseOffsetY) > 0.85
	self.path = {0, 0, 0, 0}
	self.isNode = true
	self.node = nil

	self.tilemap = {}
	self.colliders = {}

	self.explored = false

	function self:render()
		if self.visited then
			love.graphics.setColor(1, 1, 1, 1)

			for _, j in ipairs(self.tilemap) do
				if j.floorImage then
					love.graphics.draw(tilemap, j.floorImage, self.renderX + j.x, self.renderY + j.y)
				end

				love.graphics.setColor(1,1,1,1)
			end

			love.graphics.setColor(1, 1, 1, 0.2)
			--love.graphics.rectangle("line", self.renderX, self.renderY, self.w, self.h)
			love.graphics.setColor(1,1,1,1)

			--if self.path[1] == 0 and not self.previsited then love.graphics.line(self.renderX, self.renderY, self.renderX + self.w, self.renderY) end
			--if self.path[2] == 0 and not self.previsited then love.graphics.line(self.renderX + self.w, self.renderY, self.renderX + self.w, self.renderY + self.h) end
			--if self.path[3] == 0 and not self.previsited then love.graphics.line(self.renderX, self.renderY + self.h, self.renderX + self.w, self.renderY + self.h) end
			--if self.path[4] == 0 and not self.previsited then love.graphics.line(self.renderX, self.renderY, self.renderX, self.renderY + self.h) end
		end
	end

	function self:createTilemap()
		for y = 0, self.size - 1 do
			for x = 0, self.size - 1 do
				table.insert(self.tilemap, {floorImage = nil, wallImage = nil, x = x * 16, y = y * 16})
				--*FLOOR PLACEMENT
				self.tilemap[#self.tilemap].floorImage = floorImages[love.math.random(#floorImages)]

				--*BASE WALL PLACEMENT
				--?Rooms top row
				if y == 0 then
					--?Check if there is a northern wall
					if self.path[1] == 0 then
						--?Check if left upper corner is closed
						if self.path[4] == 0 and x == 0 then
							self.tilemap[#self.tilemap].floorImage = wallLeftImages[love.math.random(#wallLeftImages)]
						--?Check if right upper corner is closed
						elseif self.path[2] == 0 and x == self.size - 1 then
							self.tilemap[#self.tilemap].floorImage = wallRightImages[love.math.random(#wallRightImages)]
						--?Default wall texture
						else
							self.tilemap[#self.tilemap].floorImage = wallTopImages[love.math.random(#wallTopImages)]
						end
					--?Fill in a missing corner if needed
					elseif self.path[4] == 0 and x == 0 then
						self.tilemap[#self.tilemap].floorImage = wallLeftImages[love.math.random(#wallLeftImages)]
					elseif self.path[2] == 0 and x == self.size - 1 then
						self.tilemap[#self.tilemap].floorImage = wallRightImages[love.math.random(#wallRightImages)]
					end
				--?Rooms bottom row
				elseif y == self.size - 1 then
					--Check if there is a wall
					if self.path[3] == 0 then
						--Check if left upper corner is closed
						if self.path[4] == 0 and x == 0 then
							self.tilemap[#self.tilemap].floorImage = wallLeftInnerCornerImage
						--Check if right upper corner is closed
						elseif self.path[2] == 0 and x == self.size - 1 then
							self.tilemap[#self.tilemap].floorImage = wallRightInnerCornerImage
						--Default wall texture
						else
							self.tilemap[#self.tilemap].floorImage = wallBottomImages[love.math.random(#wallBottomImages)]
						end
					--Fill in a missing corner if needed
					elseif self.path[4] == 0 and x == 0 then
						self.tilemap[#self.tilemap].floorImage = wallLeftImages[love.math.random(#wallLeftImages)]
					elseif self.path[2] == 0 and x == self.size - 1 then
						self.tilemap[#self.tilemap].floorImage = wallRightImages[love.math.random(#wallRightImages)]
					end
				else
					--Rooms left collumn
					if x == 0 then
						if self.path[4] == 0 then
							self.tilemap[#self.tilemap].floorImage = wallLeftImages[love.math.random(#wallLeftImages)]
						end
					--Rooms right collumn
					elseif x == self.size - 1 then
						if self.path[2] == 0 then
							self.tilemap[#self.tilemap].floorImage = wallRightImages[love.math.random(#wallRightImages)]
						end
					end
				end

				--*CORNER CHECKING
				local neighbours = {
					Maze.rooms[Maze:getIndex(1, -1, self)], --NE-neighbour
					Maze.rooms[Maze:getIndex(1, 1, self)], --SE-neighbour
					Maze.rooms[Maze:getIndex(-1, 1, self)], --SW-neighbour
					Maze.rooms[Maze:getIndex(-1, -1, self)], --NW-neighbour
				}

				--Top of the walls
				if y == 0 then
					--*VERTICALS (╔╗)
					--Right Top side of the walls end
					if x == self.size - 1 and self.path[2] == 0 and self.path[1] == 1 and neighbours[1] and neighbours[1].path[4] == 1 and neighbours[1].path[3] == 1 then
						self.tilemap[#self.tilemap].floorImage = wallRightOuterCornerImages[love.math.random(#wallRightOuterCornerImages)]
					end

					--Left Top side of the walls end
					if x == 0 and self.path[4] == 0 and self.path[1] == 1 and neighbours[4] and neighbours[4].path[2] == 1 and neighbours[4].path[3] == 1 then
						self.tilemap[#self.tilemap].floorImage = wallLefttOuterCornerImages[love.math.random(#wallLefttOuterCornerImages)]
					end

					--*HORIZONTALS (──╝, ╚──)
					--Right corner of the walls
					if x == self.size - 1 and self.path[1] == 1 and self.path[2] == 1 and neighbours[1] and neighbours[1].path[4] == 0 and neighbours[1].path[3] == 0 then
						self.tilemap[#self.tilemap].floorImage = wallTopImages[love.math.random(#wallTopImages)]
					end

					--Left corner of the walls
					if x == 0 and self.path[1] == 1 and self.path[4] == 1 and neighbours[4] and neighbours[4].path[2] == 0 and neighbours[4].path[3] == 0 then
						self.tilemap[#self.tilemap].floorImage = wallTopImages[love.math.random(#wallTopImages)]
					end

				--Bottom of the walls
				elseif y == self.size - 1 then
					--*VERTICALS (╚╝)
					--Right Bottom side of the walls end
					if x == self.size - 1 and self.path[2] == 0 and self.path[3] == 1 and neighbours[2] and neighbours[2].path[4] == 1 and neighbours[2].path[1] == 1 then
						self.tilemap[#self.tilemap].floorImage = wallTopImages[love.math.random(#wallTopImages)]
					end

					--Left Bottom side of the walls end
					if x == 0 and self.path[4] == 0 and self.path[3] == 1 and neighbours[3] and neighbours[3].path[2] == 1 and neighbours[3].path[1] == 1 then
						self.tilemap[#self.tilemap].floorImage = wallTopImages[love.math.random(#wallTopImages)]
					end

					--*HORIZONTALS (──╗, ╔──)
					--Right corner of the walls
					if x == self.size - 1 and self.path[2] == 1 and self.path[3] == 0 and neighbours[2] and neighbours[2].path[1] == 1 and neighbours[2].path[4] == 1 then
						self.tilemap[#self.tilemap].floorImage = wallLefttOuterCornerImages[love.math.random(#wallLefttOuterCornerImages)]
					end
					--Left corner of the walls
					if x == 0 and self.path[4] == 1 and self.path[3] == 0 and neighbours[3] and neighbours[3].path[1] == 1 and neighbours[3].path[2] == 1 then
						self.tilemap[#self.tilemap].floorImage = wallRightOuterCornerImages[love.math.random(#wallRightOuterCornerImages)]
					end

					if x == self.size - 1 and self.path[2] == 1 and self.path[3] == 1 and neighbours[2] and neighbours[2].path[1] == 0 and neighbours[2].path[4] == 0 then
						self.tilemap[#self.tilemap].floorImage = wallRightOuterCornerImages[love.math.random(#wallRightOuterCornerImages)]
					end

					if x == 0 and self.path[4] == 1 and self.path[3] == 1 and neighbours[3] and neighbours[3].path[1] == 0 and neighbours[3].path[2] == 0 then
						self.tilemap[#self.tilemap].floorImage = wallLefttOuterCornerImages[love.math.random(#wallLefttOuterCornerImages)]
					end
				end
			end
		end
	end

	function self:createColliders()
		if self.path[1] == 0 then
			table.insert(self.colliders, world:newRectangleCollider(
				self.renderX, self.renderY,
				self.w, self.tileSize
			))
			self.colliders[#self.colliders]:setType("static")
			self.colliders[#self.colliders]:setCollisionClass("Wall")
		end

		if self.path[3] == 0 then
			table.insert(self.colliders, world:newRectangleCollider(
				self.renderX, self.renderY + self.h - self.tileSize,
				self.w, self.tileSize
			))
			self.colliders[#self.colliders]:setType("static")
			self.colliders[#self.colliders]:setCollisionClass("Wall")
		end

		if self.path[2] == 0 then
			table.insert(self.colliders, world:newRectangleCollider(
				self.renderX + self.w - self.tileSize, self.renderY,
				self.tileSize, self.h
			))
			self.colliders[#self.colliders]:setType("static")
			self.colliders[#self.colliders]:setCollisionClass("Wall")
		end

		if self.path[4] == 0 then
			table.insert(self.colliders, world:newRectangleCollider(
				self.renderX, self.renderY,
				self.tileSize, self.h
			))
			self.colliders[#self.colliders]:setType("static")
			self.colliders[#self.colliders]:setCollisionClass("Wall")
		end

		--*Missing corner hitboxes
		local neighbours = {
			Maze.rooms[Maze:getIndex(1, -1, self)], --NE-neighbour
			Maze.rooms[Maze:getIndex(1, 1, self)], --SE-neighbour
			Maze.rooms[Maze:getIndex(-1, 1, self)], --SW-neighbour
			Maze.rooms[Maze:getIndex(-1, -1, self)], --NW-neighbour
		}

		--?Top Right
		if self.path[1] == 1 and self.path[2] == 1 and neighbours[1] and neighbours[1].path[4] == 0 and neighbours[1].path[3] == 0 then
			table.insert(self.colliders, world:newRectangleCollider(
				self.renderX + self.w - self.tileSize, self.renderY,
				self.tileSize, self.tileSize
			))
			self.colliders[#self.colliders]:setType("static")
			self.colliders[#self.colliders]:setCollisionClass("Wall")
		end

		--?Bottom Right
		if self.path[2] == 1 and self.path[3] == 1 and neighbours[2] and neighbours[2].path[1] == 0 and neighbours[2].path[4] == 0 then
			table.insert(self.colliders, world:newRectangleCollider(
				self.renderX + self.w - self.tileSize, self.renderY + self.h - self.tileSize,
				self.tileSize, self.tileSize
			))
			self.colliders[#self.colliders]:setType("static")
			self.colliders[#self.colliders]:setCollisionClass("Wall")
		end

		--?Bottom Left
		if self.path[3] == 1 and self.path[4] == 1 and neighbours[3] and neighbours[3].path[1] == 0 and neighbours[3].path[2] == 0 then
			table.insert(self.colliders, world:newRectangleCollider(
				self.renderX, self.renderY + self.h - self.tileSize,
				self.tileSize, self.tileSize
			))
			self.colliders[#self.colliders]:setType("static")
			self.colliders[#self.colliders]:setCollisionClass("Wall")
		end

		--?Top Left
		if self.path[4] == 1 and self.path[1] == 1 and neighbours[4] and neighbours[4].path[2] == 0 and neighbours[4].path[3] == 0 then
			table.insert(self.colliders, world:newRectangleCollider(
				self.renderX, self.renderY,
				self.tileSize, self.tileSize
			))
			self.colliders[#self.colliders]:setType("static")
			self.colliders[#self.colliders]:setCollisionClass("Wall")
		end
	end

	function self:createShadowboxes()
		local neighbours = {
			Maze.rooms[Maze:getIndex(1, -1, self)], --NE-neighbour
			Maze.rooms[Maze:getIndex(1, 1, self)], --SE-neighbour
			Maze.rooms[Maze:getIndex(-1, 1, self)], --SW-neighbour
			Maze.rooms[Maze:getIndex(-1, -1, self)], --NW-neighbour
		}

		local widthModifier = {0, 0}
		if self.path[3] == 0 then
			if neighbours[2] and neighbours[2].path[1] == 1 and neighbours[2].path[4] == 1 and self.path[2] == 1 then
				widthModifier[2] = -7
			end

			if neighbours[3] and neighbours[3].path[1] == 1 and neighbours[3].path[2] == 1 and self.path[4] == 1 then
				widthModifier[1] = 7
			end

			lightWorld:addPolygon({
				self.renderX + widthModifier[1], self.renderY + self.h - 8,
				self.renderX + self.w + widthModifier[2], self.renderY + self.h - 8,
				self.renderX + self.w + widthModifier[2], self.renderY + self.h,
				self.renderX + widthModifier[1], self.renderY + self.h
			})
		end

		--*Order: Top, Bottom
		local heightModifier = {0, 0}
		if self.path[2] == 0 then
			if neighbours[1] and neighbours[1].path[4] == 1 and neighbours[1].path[3] == 1 and self.path[1] == 1 then
				heightModifier[1] = 8
			end

			if neighbours[2] and neighbours[2].path[4] == 1 and neighbours[2].path[1] == 1 and self.path[3] == 1 then
				heightModifier[2] = -16
			end

			lightWorld:addPolygon({
				self.renderX + self.w - self.tileSize + 7, self.renderY + heightModifier[1],
				self.renderX + self.w, self.renderY + heightModifier[1],
				self.renderX + self.w, self.renderY + self.h + heightModifier[2],
				self.renderX + self.w - self.tileSize + 7, self.renderY + self.h + heightModifier[2],
			})
		end

		heightModifier = {0, 0}
		if self.path[4] == 0 then
			if neighbours[4] and neighbours[4].path[2] == 1 and neighbours[4].path[3] == 1 and self.path[1] == 1 then
				heightModifier[1] = 8
			end

			if neighbours[3] and neighbours[3].path[2] == 1 and neighbours[3].path[1] == 1 and self.path[3] == 1 then
				heightModifier[2] = -16
			end

			lightWorld:addPolygon({
				self.renderX, self.renderY + heightModifier[1],
				self.renderX + 9, self.renderY + heightModifier[1],
				self.renderX + 9, self.renderY + self.h + heightModifier[2],
				self.renderX, self.renderY + self.h + heightModifier[2],
			})
		end

		--*PLACE MISSING CORNERS
		if self.path[2] == 1 and self.path[3] == 1 and neighbours[2] and neighbours[2].path[1] == 0 and neighbours[2].path[4] == 0 then
			lightWorld:addPolygon({
				self.renderX + self.w - 9, self.renderY + self.h - 8,
				self.renderX + self.w, self.renderY + self.h - 8,
				self.renderX + self.w, self.renderY + self.h,
				self.renderX + self.w - 9, self.renderY + self.h
			})
		end

		if self.path[4] == 1 and self.path[3] == 1 and neighbours[3] and neighbours[3].path[1] == 0 and neighbours[3].path[2] == 0 then
			lightWorld:addPolygon({
				self.renderX, self.renderY + self.h - 8,
				self.renderX + 9, self.renderY + self.h - 8,
				self.renderX + 9, self.renderY + self.h,
				self.renderX, self.renderY + self.h
			})
		end
	end

	return self
end

return room
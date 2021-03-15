local room = {}

function room:new(_x, _y, _w, _h)
	local self = {}

	self.x = _x
	self.y = _y
	self.w = _w or 1
	self.h = _h or 1

	self.renderX = self.x * self.w
	self.renderY = self.y * self.h

	self.visited = false
	self.previsited = love.math.noise(self.x / 10 + Maze.noiseOffsetX, self.y / 10 + Maze.noiseOffsetY) > 0.85
	self.path = {0, 0, 0, 0}
	self.isNode = true
	self.node = nil

	self.tilemap = {}

	function self:render()
		if self.visited then
			love.graphics.setColor(1, 1, 1, 1)

			for i, j in ipairs(self.tilemap) do
				--if (self.x + self.y) % 2 == 0 then love.graphics.setColor(1, 0.5, 0.5)
				--else love.graphics.setColor(0.5, 1, 0.5) end

				if j.floorImage then
					love.graphics.draw(tilemap, j.floorImage, self.renderX + j.x, self.renderY + j.y)
				end

				love.graphics.setColor(1,1,1,1)

				if j.wallImage then
					love.graphics.draw(tilemap, j.wallImage, self.renderX + j.x, self.renderY + j.y)
				end
			end

			--if self.path[1] == 0 and not self.previsited then love.graphics.line(self.renderX, self.renderY, self.renderX + self.w, self.renderY) end
			--if self.path[2] == 0 and not self.previsited then love.graphics.line(self.renderX + self.w, self.renderY, self.renderX + self.w, self.renderY + self.h) end
			--if self.path[3] == 0 and not self.previsited then love.graphics.line(self.renderX, self.renderY + self.h, self.renderX + self.w, self.renderY + self.h) end
			--if self.path[4] == 0 and not self.previsited then love.graphics.line(self.renderX, self.renderY, self.renderX, self.renderY + self.h) end
		end
	end

	function self:createTilemap()
		for y = 0, 15 do
			for x = 0, 15 do
				table.insert(self.tilemap, {floorImage = nil, wallImage = nil, x = x * 16, y = y * 16})
				--FLOOR PLACEMENT
				self.tilemap[#self.tilemap].floorImage = floorImages[love.math.random(#floorImages)]

				--BASE WALL PLACEMENT
				--Rooms top row
				if y == 0 then
					--Check if there is a northern wall
					if self.path[1] == 0 then
						--Check if left upper corner is closed
						if self.path[4] == 0 and x == 0 then
							self.tilemap[#self.tilemap].wallImage = wallLeftImages[love.math.random(#wallLeftImages)]
						--Check if right upper corner is closed
						elseif self.path[2] == 0 and x == 15 then
							self.tilemap[#self.tilemap].wallImage = wallRightImages[love.math.random(#wallRightImages)]
						--Default wall texture
						else
							self.tilemap[#self.tilemap].wallImage = wallTopImages[love.math.random(#wallTopImages)]
						end
					--Fill in a missing corner if needed
					elseif self.path[4] == 0 and x == 0 then
						self.tilemap[#self.tilemap].wallImage = wallLeftImages[love.math.random(#wallLeftImages)]
					elseif self.path[2] == 0 and x == 15 then
						self.tilemap[#self.tilemap].wallImage = wallRightImages[love.math.random(#wallRightImages)]
					end
				--Rooms bottom row
				elseif y == 15 then
					--Check if there is a wall
					if self.path[3] == 0 then
						--Check if left upper corner is closed
						if self.path[4] == 0 and x == 0 then
							self.tilemap[#self.tilemap].wallImage = wallLeftInnerCornerImage
						--Check if right upper corner is closed
						elseif self.path[2] == 0 and x == 15 then
							self.tilemap[#self.tilemap].wallImage = wallRightInnerCornerImage
						--Default wall texture
						else
							self.tilemap[#self.tilemap].wallImage = wallBottomImages[love.math.random(#wallBottomImages)]
						end
					--Fill in a missing corner if needed
					elseif self.path[4] == 0 and x == 0 then
						self.tilemap[#self.tilemap].wallImage = wallLeftImages[love.math.random(#wallLeftImages)]
					elseif self.path[2] == 0 and x == 15 then
						self.tilemap[#self.tilemap].wallImage = wallRightImages[love.math.random(#wallRightImages)]
					end
				else
					--Rooms left collumn
					if x == 0 then
						if self.path[4] == 0 then
							self.tilemap[#self.tilemap].wallImage = wallLeftImages[love.math.random(#wallLeftImages)]
						end
					--Rooms right collumn
					elseif x == 15 then
						if self.path[2] == 0 then
							self.tilemap[#self.tilemap].wallImage = wallRightImages[love.math.random(#wallRightImages)]
						end
					end
				end

				--CORNER CHECKING
				local neighbours = {
					Maze.rooms[Maze:getIndex(1, -1, self)], --NE-neighbour
					Maze.rooms[Maze:getIndex(1, 1, self)], --SE-neighbour
					Maze.rooms[Maze:getIndex(-1, 1, self)], --SW-neighbour
					Maze.rooms[Maze:getIndex(-1, -1, self)], --NW-neighbour
				}

				--Top of the walls
				if y == 0 then
					--VERTICALS (╔╗)
					--Right Top side of the walls end
					if x == 15 and self.path[2] == 0 and self.path[1] == 1 and neighbours[1] and neighbours[1].path[4] == 1 and neighbours[1].path[3] == 1 then
						self.tilemap[#self.tilemap].wallImage = wallRightOuterCornerImages[love.math.random(#wallRightOuterCornerImages)]
					end

					--Left Top side of the walls end
					if x == 0 and self.path[4] == 0 and self.path[1] == 1 and neighbours[4] and neighbours[4].path[2] == 1 and neighbours[4].path[3] == 1 then
						self.tilemap[#self.tilemap].wallImage = wallLefttOuterCornerImages[love.math.random(#wallLefttOuterCornerImages)]
					end

					--HORIZONTALS (──╝, ╚──)
					--Right corner of the walls
					if x == 15 and self.path[1] == 1 and self.path[2] == 1 and neighbours[1] and neighbours[1].path[4] == 0 and neighbours[1].path[3] == 0 then
						self.tilemap[#self.tilemap].wallImage = wallTopImages[love.math.random(#wallTopImages)]
					end

					--Left corner of the walls
					if x == 0 and self.path[1] == 1 and self.path[4] == 1 and neighbours[4] and neighbours[4].path[2] == 0 and neighbours[4].path[3] == 0 then
						self.tilemap[#self.tilemap].wallImage = wallTopImages[love.math.random(#wallTopImages)]
					end

				--Bottom of the walls
				elseif y == 15 then
					--VERTICALS (╚╝)
					--Right Bottom side of the walls end
					if x == 15 and self.path[2] == 0 and self.path[3] == 1 and neighbours[2] and neighbours[2].path[4] == 1 and neighbours[2].path[1] == 1 then
						self.tilemap[#self.tilemap].wallImage = wallTopImages[love.math.random(#wallTopImages)]
					end

					--Left Bottom side of the walls end
					if x == 0 and self.path[4] == 0 and self.path[3] == 1 and neighbours[3] and neighbours[3].path[2] == 1 and neighbours[3].path[1] == 1 then
						self.tilemap[#self.tilemap].wallImage = wallTopImages[love.math.random(#wallTopImages)]
					end

					--HORIZONTALS (──╗, ╔──)
					--Right corner of the walls
					if x == 15 and self.path[2] == 1 and self.path[3] == 0 and neighbours[2] and neighbours[2].path[1] == 1 and neighbours[2].path[4] == 1 then
						self.tilemap[#self.tilemap].wallImage = wallLefttOuterCornerImages[love.math.random(#wallLefttOuterCornerImages)]
					end
					--Left corner of the walls
					if x == 0 and self.path[4] == 1 and self.path[3] == 0 and neighbours[3] and neighbours[3].path[1] == 1 and neighbours[3].path[2] == 1 then
						self.tilemap[#self.tilemap].wallImage = wallRightOuterCornerImages[love.math.random(#wallRightOuterCornerImages)]
					end

					if x == 15 and self.path[2] == 1 and self.path[3] == 1 and neighbours[2] and neighbours[2].path[1] == 0 and neighbours[2].path[4] == 0 then
						self.tilemap[#self.tilemap].wallImage = wallRightOuterCornerImages[love.math.random(#wallRightOuterCornerImages)]
					end

					if x == 0 and self.path[4] == 1 and self.path[3] == 1 and neighbours[3] and neighbours[3].path[1] == 0 and neighbours[3].path[2] == 0 then
						self.tilemap[#self.tilemap].wallImage = wallLefttOuterCornerImages[love.math.random(#wallLefttOuterCornerImages)]
					end
				end
			end
		end
	end

	return self
end

return room
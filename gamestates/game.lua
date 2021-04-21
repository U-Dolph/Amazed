game = {}

function game:init()
    self.cursor = love.mouse.newCursor( "gfx/cursor.png", 11, 11)
	love.mouse.setCursor(self.cursor)
end

function game:enter()
	love.mouse.setCursor(self.cursor)

    --!KOREGA REQUIEM DA!--
    for _, j in ipairs(World:getBodies()) do j:destroy() end

	maze:createMaze()

    player = Player:new()
    player:setPosition(maze.startNode.renderX, maze.startNode.renderY)
    playerCam:setScale(1)

    self.enemies = {}
end

function game:update(dt)
    World:update(dt)
	maze:update(dt)
	player:update(dt)
	playerCam:setPosition(player.x, player.y)

    preDrawLights()
end

function game:draw()
    local entities = self:getEntitiesToRender()

    playerCam:draw(function(l,t,w,h)
        local roomsRendered = maze:render()

        for i, j in ipairs(entities) do
            j:render()
        end

        if doDrawColliders then World:draw() end
    end)

    love.graphics.setBlendMode("multiply", "premultiplied")
	if doDrawLight then love.graphics.draw(lightCanvas) end
	love.graphics.setBlendMode("alpha")

    hud:render()
end

function game:keypressed(key)
    if key == "space" then
        player:dash()
    end
end

function game:mousepressed(x, y, button)
    if button == 1 then
        player:attack(x, y)
    end
end

function game:leave()

end

function game:resume()

end

function game:getEntitiesToRender(excludePlayer)
	local entities = {}

	if not excludePlayer then table.insert(entities, player) end

	for i, j in ipairs(self.enemies) do
		if j.currentRoom.visible then
			table.insert(entities, j)
		end
	end

	table.sort(entities, function(a, b) return a.y < b.y end)

	return entities
end
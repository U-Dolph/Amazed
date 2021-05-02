game = {}

function game:init()
    self.cursor = love.mouse.newCursor( "gfx/cursor.png", 11, 11)
	love.mouse.setCursor(self.cursor)

    self.enemies = {}
end

function game:enter()
	love.mouse.setCursor(self.cursor)

    --!KOREGA REQUIEM DA!--
    for _, j in ipairs(World:getBodies()) do j:destroy() end

    lightWorld  = Lighter()
	maze:createMaze()
    player = Player:new()
    player:setPosition(maze.startNode.renderX, maze.startNode.renderY)
    playerCam:setScale(1)

    self.enemies = {}

    for i, j in ipairs(maze.rooms) do
        if j.isNode and love.math.random() > 0.5 then
            spawnEnemies(j.renderX, j.renderY)
        end
    end

    for _, j in ipairs (self.enemies) do
        j:update(0)
    end

    self.enterTime = os.clock()

    self.sessionTime = 0
end

function game:update(dt)
    World:update(dt)
	player:update(dt)
	maze:update(dt)
	playerCam:setPosition(player.x, player.y)
    self:updateEnemies(dt)
    popupHandler:update(dt)

    preDrawLights()
end

function game:draw()
    local entities = self:getEntitiesToRender()

    playerCam:draw(function(l,t,w,h)
        maze:render()

        for i, j in ipairs(entities) do
            j:render()
        end

        if doDrawColliders then World:draw() end
    end)

    love.graphics.setBlendMode("multiply", "premultiplied")
	if doDrawLight then love.graphics.draw(lightCanvas) end
	love.graphics.setBlendMode("alpha")

    popupHandler:render()

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
    self.sessionTime = math.floor(os.clock() - self.enterTime) .. " s"
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

function game:updateEnemies(dt)
    for i, j in ipairs (self.enemies) do
        j:update(dt)

		if not j.alive then table.remove(self.enemies, i) end
    end
end

function spawnEnemies(xCoord, yCoord)
    local randomX, randomY = xCoord + maze.tileSize * 2 + love.math.random((maze.roomSize * maze.tileSize) - maze.tileSize * 4), yCoord + maze.tileSize * 2 + love.math.random((maze.roomSize * maze.tileSize) - maze.tileSize * 4)
    table.insert(game.enemies, EnemyFactory.spawnEnemy(1, randomX, randomY))
    game.enemies[#game.enemies]:update(0)
end
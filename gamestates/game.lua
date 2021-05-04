game = {}

function game:init()
    self.cursor = love.mouse.newCursor( "gfx/cursor.png", 11, 11)
	love.mouse.setCursor(self.cursor)

    self.enemies = {}
    self.chests = {}
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
    self.chests = {}

    for _, j in ipairs(maze.rooms) do
        if j.isNode and love.math.random() > 0.5 and j.node ~= maze.startNode then
            spawnEnemies(j.renderX, j.renderY)
        end
    end

    for _, j in ipairs(maze.rooms) do
        local random = love.math.random()
        if j.isNode and random > 0.9 and j.path[1] == 0 and j.node ~= maze.endNode then
            table.insert(self.chests, Chest:new(j.renderX + 64, j.renderY + 16))
        end
    end

    placeKeys()

    for _, j in ipairs (self.enemies) do
        j:update(0)
    end

    self.enterTime = os.clock()

    self.sessionTime = 0

    self.totalEnemies = #self.enemies
end

function game:update(dt)
    World:update(dt)
	player:update(dt)
	maze:update(dt)
	playerCam:setPosition(player.x, player.y)
    self:updateEnemies(dt)
    self:updateChests(dt)
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

    if love.keyboard.isDown("tab") then
        hud:renderLarge()
    else
        hud:render()
    end
end

function game:keypressed(key)
    if key == "space" then
        player:dash()
    end

    if key == "e" then
        for i, j in ipairs(self.chests) do
            if lume.distance(j.x + 8, j.y, player.x, player.y) < 30 and not j.opened then
                j:open()
            end
        end

        if player.currentRoom.node == maze.endNode then
            if lume.distance(player.currentRoom.renderX + maze.roomSize/2 * maze.tileSize, player.currentRoom.renderY, player.x, player.y) < 30 then
                local gatheredKeys = 0

                for i, j in ipairs(player.inventory) do
                    if j.id == ITEM_TYPES.key then gatheredKeys = gatheredKeys + 1 end
                end

                if gatheredKeys >= 3 then
                    Gamestate.switch(gameover, "success")
                else
                    popupHandler:addElement("Need " .. 3 - gatheredKeys .. " more " .. (3 - gatheredKeys == 1 and " key!" or " keys!"), player.currentRoom.renderX + maze.roomSize/2 * maze.tileSize, player.currentRoom.renderY + 8, {1, 0, 1})
                end
            end
        end
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

    for i, j in ipairs(self.chests) do
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

function game:updateChests(dt)
    for _, j in ipairs (self.chests) do
        j:update(dt)
    end
end

function spawnEnemies(xCoord, yCoord)
    local randomX, randomY = xCoord + maze.tileSize * 2 + love.math.random((maze.roomSize * maze.tileSize) - maze.tileSize * 4), yCoord + maze.tileSize * 2 + love.math.random((maze.roomSize * maze.tileSize) - maze.tileSize * 4)

    local selectFrom = {}

    for i, j in pairs(ENEMY_TYPES) do
        for k = 1, j.weight do
            table.insert(selectFrom, j)
        end
    end

    local rolled = selectFrom[love.math.random(1, #selectFrom)]

    table.insert(game.enemies, EnemyFactory.spawnEnemy(rolled, randomX, randomY))
    game.enemies[#game.enemies]:update(0)
end

function placeKeys()
    local keysLeft = 3

    while keysLeft > 0 do
        local selectedChest = game.chests[love.math.random(1, #game.chests)]
        local isValid = true

        for i, j in ipairs(selectedChest.items) do
            if j.id == ITEM_TYPES.key then isValid = false end
        end

        if isValid then
            table.insert(selectedChest.items, item:new(selectedChest.x + 8, selectedChest.y + 12, ITEM_TYPES.key))
            keysLeft = keysLeft - 1
        end
    end
end
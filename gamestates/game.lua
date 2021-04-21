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

    self.enemies = {}
end

function game:update(dt)
    World:update(dt)
	maze:update(dt)
	player:update(dt)
	playerCam:setPosition(player.x, player.y)
end

function game:draw()
    love.graphics.print("gec")
end

function game:keypressed()
    
end

function game:leave()
    
end

function game:resume()
    
end
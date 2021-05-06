menu = {}

function menu:init()
    self.title = love.graphics.newImage("gfx/title2.png")
    self.menufont = love.graphics.newFont("ast/alagard.ttf", 32)

    maze:createMaze(true)

    playerCam:setPosition((15 * 16 * 8 + 640) / 2, (15 * 16 * 8 + 360) / 2)
    playerCam:setScale(2)

    self.moonshine = require "lib/moonshine"
    self.blurEffect = moonshine(640, 360, moonshine.effects.gaussianblur).chain(moonshine.effects.desaturate)
    self.blurEffect.gaussianblur.sigma = 5
    self.blurEffect.desaturate.strength = 0.5

    self.menuItems = {
        {displayText = "START", x = 320, y = 180, sizeModifier = 1.5, command = "Gamestate.switch(game)"},
        {displayText = "SETTINGS", x = 320, y = 220, sizeModifier = 1, command = "print('settings')"},
        {displayText = "LEADERBOARD", x = 320, y = 260, sizeModifier = 1, command = "Gamestate.switch(leaderboard)"},
        {displayText = "QUIT", x = 320, y = 300, sizeModifier = 1, command = "love.event.quit(0)"}
    }

    self.selected = 1
end

function menu:enter(previousState)

end

function menu:update(dt)
    local camX, camY = playerCam:getPosition()
    playerCam:setPosition(camX + (love.math.noise(math.cos(os.clock() / 10)) - 0.5) * 1, camY - (love.math.noise(os.clock() / 10) - 0.5) * 1)

    local mx, my = love.mouse.getPosition()

    for i, j in ipairs(self.menuItems) do
        if mx/renderScale > j.x - self.menufont:getWidth(j.displayText)/2 and mx/renderScale < j.x + self.menufont:getWidth(j.displayText)/2 and
        my/renderScale > j.y - self.menufont:getHeight(j.displayText)/2 and my/renderScale < j.y + self.menufont:getHeight(j.displayText)/2 then
            self.selected = i
        end

        if i == self.selected then
            j.sizeModifier = math.min(1.25, j.sizeModifier + 5 * dt)
        else
            j.sizeModifier = math.max(1, j.sizeModifier - 5 * dt)
        end
    end

    if input:pressed("down") then
        self.selected = math.min(#self.menuItems, self.selected + 1)
    elseif input:pressed("up") then
        self.selected = math.max(1, self.selected - 1)
    elseif input:pressed("action") then
        loadstring(self.menuItems[self.selected].command)()
    elseif input:pressed("back") then
        love.event.quit(0)
    end
end

function menu:draw()
    self.blurEffect(function ()
        playerCam:draw(function(l,t,w,h)
            maze:render()
        end)
    end)

    love.graphics.draw(self.title, 320, 20, 0, 1, 1, self.title:getWidth()/2)

    love.graphics.setFont(self.menufont)

    for i, j in ipairs(self.menuItems) do
        love.graphics.setColor(1, 1, 1, math.pow(j.sizeModifier / 1.25, 2))
        love.graphics.print(j.displayText, j.x, j.y, 0, j.sizeModifier, j.sizeModifier, self.menufont:getWidth(j.displayText)/2, self.menufont:getHeight(j.displayText)/2)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function menu:keypressed(key)

end

function menu:mousepressed(x, y, button)
    if button == 1 then
        x = x/renderScale
        y = y/renderScale

        if x > self.menuItems[self.selected].x - self.menufont:getWidth(self.menuItems[self.selected].displayText)/2 and x < self.menuItems[self.selected].x + self.menufont:getWidth(self.menuItems[self.selected].displayText)/2 and
        y > self.menuItems[self.selected].y - self.menufont:getHeight(self.menuItems[self.selected].displayText)/2 and y < self.menuItems[self.selected].y + self.menufont:getHeight(self.menuItems[self.selected].displayText)/2 then
            loadstring(self.menuItems[self.selected].command)()
        end
    end
end

function menu:leave()

end

function menu:resume()

end
menu = {}

function menu:init()
    self.title = love.graphics.newImage("gfx/title.png")
    self.menufont = love.graphics.newFont("ast/alagard.ttf", 32)

    self.backgroundMaze = maze:new(15, 15, 16, 8)
    self.backgroundMaze:createMaze(true)

    self.cam = gamera.new(-320, -180, 15 * 16 * 8 + 640, 15 * 16 * 8 + 360)
    self.cam:setWindow(0, 0, 640, 360)
    self.cam:setPosition((15 * 16 * 8 + 640) / 2, (15 * 16 * 8 + 360) / 2)
    self.cam:setScale(2)

    self.moonshine = require "lib/moonshine"
    self.blurEffect = moonshine(640, 360, moonshine.effects.gaussianblur).chain(moonshine.effects.desaturate)
    self.blurEffect.gaussianblur.sigma = 5
    self.blurEffect.desaturate.strength = 0.5

    self.menuItems = {
        {displayText = "START", x = 320, y = 180, sizeModifier = 1.5},
        {displayText = "SETTINGS", x = 320, y = 220, sizeModifier = 1},
        {displayText = "LEADERBOARD", x = 320, y = 260, sizeModifier = 1},
        {displayText = "QUIT", x = 320, y = 300, sizeModifier = 1}
    }

    self.selected = 1
end

function menu:enter(previousState)

end

function menu:update(dt)
    local camX, camY = self.cam:getPosition()
    self.cam:setPosition(camX + (love.math.noise(math.cos(os.clock() / 10)) - 0.5) * 1, camY - (love.math.noise(os.clock() / 10) - 0.5) * 1)

    for i, j in ipairs(self.menuItems) do
        if i == self.selected then
            j.sizeModifier = math.min(1.25, j.sizeModifier + 5 * dt)
        else
            j.sizeModifier = math.max(1, j.sizeModifier - 5 * dt)
        end
    end
end

function menu:draw()
    self.blurEffect(function ()
        self.cam:draw(function(l,t,w,h)
            self.backgroundMaze:render()
        end)
    end)

    love.graphics.draw(self.title, 320, 20, 0, 1/2, 1/2, self.title:getWidth()/2)

    love.graphics.setFont(self.menufont)

    for i, j in ipairs(self.menuItems) do
        love.graphics.setColor(1, 1, 1, math.pow(j.sizeModifier / 1.25, 2))
        love.graphics.print(j.displayText, j.x, j.y, 0, j.sizeModifier, j.sizeModifier, self.menufont:getWidth(j.displayText)/2, self.menufont:getHeight(j.displayText)/2)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function menu:keypressed(key)
    if key == 'w' then
        self.selected = math.max(1, self.selected - 1)
    elseif key == 's' then
        self.selected = math.min(#self.menuItems, self.selected + 1)
    end
end

function menu:leave()

end

function menu:resume()

end
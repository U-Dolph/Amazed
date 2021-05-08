intro = {}

function intro:init()
    self.video = love.graphics.newVideo("gfx/loveIntro.ogv")
end

function intro:enter()
    self.video:play()
end

function intro:update(dt)
    if not self.video:isPlaying() then
        Gamestate.switch(menu)
    end
end

function intro:draw()
    love.graphics.draw(self.video, 0, 0, 0, 640/1920)
end

function intro:leave()
    love.graphics.setDefaultFilter("nearest", "nearest")
end
leaderboard = {}

function leaderboard:init()
    self.frameImage = love.graphics.newImage("gfx/leaderboardBackground.png")
    self.font = love.graphics.newFont("ast/pixelmix.ttf", 16)
end

function leaderboard:enter()

end

function leaderboard:update(dt)
    local camX, camY = playerCam:getPosition()
    playerCam:setPosition(camX + (love.math.noise(math.cos(os.clock() / 10)) - 0.5) * 1, camY - (love.math.noise(os.clock() / 10) - 0.5) * 1)

    if input:pressed("back") then
        Gamestate.switch(menu)
    end
end

function leaderboard:draw()
    menu.blurEffect(function ()
        playerCam:draw(function(l,t,w,h)
            maze:render()
        end)
    end)

    love.graphics.draw(self.frameImage, 320, 180, 0, 1, 1, 186, 166)

    love.graphics.setColor(28/255, 35/255, 128/255)
    love.graphics.setFont(self.font)

    for i = 1, 10 do
        love.graphics.print(i .. ".", 320 - 186 + 60, 180 - 166 + 45 + (i - 1) * 26, 0, 1, 1, self.font:getWidth(i .. "."))
        love.graphics.print(Highscores[i] and Highscores[i] or "-", 320 + 186 - 40, 180 - 166 + 45 + (i - 1) * 26, 0, 1, 1, self.font:getWidth(Highscores[i] and Highscores[i] or "-"))
    end
end

function leaderboard:leave()

end

function leaderboard:resume()

end
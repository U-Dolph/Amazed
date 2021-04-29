gameover = {}

function gameover:init()
    self.quoteFont = love.graphics.newFont("ast/alagard.ttf", 32)
    self.printFont = love.graphics.newFont("ast/alagard.ttf", 16)

    self.quotes = {
        "Choked on a user's soul",
        "Used Alt-F4 on yourself",
        "Blue Screened",
        "NULL-TERMINATED!",
        "THAT'S GOTTA HURT!",
        "You have been reduced to atoms",
        "If you want to die again, then die. But I would recommend staying alive",
        "Tip: Don't die",
        "What's that noise? Oh wait, it's nothing. Your heart just stopped beating",
        "Practice makes perfect",
        "It was only a mistake",
        "'Wow, that was great!' - No one",
        "Death is only temporary. Victory is permanent!",
        "Another one bites the dust!",
        "Omae wa mou shindeiru"
    }

    self.currentText = self.quotes[love.math.random(1, #self.quotes)]

    self.timer = Timer.new()
    self.from = nil
end

function gameover:enter(from)
    self.currentText = self.quotes[love.math.random(1, #self.quotes)]
    self.from = from
end

function gameover:update(dt)

end

function gameover:draw()
    love.graphics.setColor(1, 0, 0)
    love.graphics.setFont(self.quoteFont)
    love.graphics.printf(self.currentText, 0, 80, 640, "center")
    love.graphics.setColor(1, 1, 1)

    love.graphics.setFont(self.printFont)
    love.graphics.print("Killed:", 220, 160)
    love.graphics.print(player.killCount, 420, 160, 0, 1, 1, self.printFont:getWidth(player.killCount))
    love.graphics.print("Damage dealt:", 220, 180)
    love.graphics.print(player.dealtDamage, 420, 180, 0, 1, 1, self.printFont:getWidth(player.dealtDamage))
    love.graphics.print("Damage received:", 220, 200)
    love.graphics.print(player.receivedDamage, 420, 200, 0, 1, 1, self.printFont:getWidth(player.receivedDamage))
    love.graphics.print("Time:", 220, 220)
    love.graphics.print(game.sessionTime, 420, 220, 0, 1, 1, self.printFont:getWidth(game.sessionTime))

    love.graphics.print("ESC - Return to menu", 10, 360 - 20)
    love.graphics.print("Space - Start new game", 640 - 10 - self.printFont:getWidth("Space - Start new game"), 360 - 20)
end

function gameover:keypressed(key)
    if key == "escape" then
        Gamestate.switch(menu)
    end

    if key == "space" then
        Gamestate.switch(game)
    end
end

function gameover:mousepressed(x, y, button)

end

function gameover:leave()

end

function gameover:resume()

end
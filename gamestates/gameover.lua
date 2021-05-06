gameover = {}

function gameover:init()
    self.quoteFont = love.graphics.newFont("ast/alagard.ttf", 32)
    self.printFont = love.graphics.newFont("ast/alagard.ttf", 16)

    self.failQuotes = {
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

    self.successQuotes = {
        "Was not that hard!",
        "What did take so long?",
        "I thought you would not make it"
    }

    self.currentText = self.failQuotes[love.math.random(1, #self.failQuotes)]
    self.textColor = {1, 1, 1}

    self.timer = Timer.new()
    self.from = nil
    self.won = false
end

function gameover:enter(from, ending)
    if ending == "failure" then
        self.currentText = self.failQuotes[love.math.random(1, #self.failQuotes)]
        self.textColor = {1, 0, 0}
        self.won = false
    elseif ending == "success" then
        self.currentText = self.successQuotes[love.math.random(1, #self.successQuotes)]
        self.textColor = {0, 0.5, 1}
        self.won = true
    end

    self.from = from

    self.exploredPercent = getExploredPercentage()
end

function gameover:update(dt)
    if input:pressed("back") then
        Gamestate.switch(menu)
    elseif input:pressed("action") then
        Gamestate.switch(game)
    end
end

function gameover:draw()
    love.graphics.setColor(self.textColor)
    love.graphics.setFont(self.quoteFont)
    love.graphics.printf(self.currentText, 0, 80, 640, "center")
    love.graphics.setColor(1, 1, 1)

    love.graphics.setFont(self.printFont)

    love.graphics.print("Killed:", 220, 160)
    love.graphics.print(player.killCount .. "/" .. self.from.totalEnemies, 420, 160, 0, 1, 1, self.printFont:getWidth(player.killCount .. "/" .. self.from.totalEnemies))
    love.graphics.print("(x100)", 425, 160)

    love.graphics.print("Damage dealt:", 220, 180)
    love.graphics.print(player.dealtDamage, 420, 180, 0, 1, 1, self.printFont:getWidth(player.dealtDamage))
    love.graphics.print("(x5)", 425, 180)

    love.graphics.print("Damage received:", 220, 200)
    love.graphics.print(player.receivedDamage, 420, 200, 0, 1, 1, self.printFont:getWidth(player.receivedDamage))
    love.graphics.print("(x-10)", 425, 200)

    love.graphics.print("Time:", 220, 220)
    love.graphics.print(game.sessionTime .. "s", 420, 220, 0, 1, 1, self.printFont:getWidth(game.sessionTime .. "s"))
    love.graphics.print(math.max(0, 1000 - game.sessionTime) * (self.won and 1 or 0), 425, 220)

    love.graphics.print("Explored:", 220, 240)
    love.graphics.print(self.exploredPercent, 420, 240, 0, 1, 1, self.printFont:getWidth(self.exploredPercent))
    love.graphics.print("(x20)", 425, 240)

    love.graphics.print("ESC - Return to menu", 10, 360 - 20)
    love.graphics.print("Space - Start new game", 640 - 10 - self.printFont:getWidth("Space - Start new game"), 360 - 20)
end

function gameover:keypressed(key)

end

function gameover:mousepressed(x, y, button)

end

function gameover:leave()

end

function gameover:resume()

end

function getExploredPercentage()
    local totalRooms = 0
    local exploredRooms = 0

    for i, j in ipairs(maze.rooms) do
        if j.visited then totalRooms = totalRooms + 1 end
        if j.explored then exploredRooms = exploredRooms + 1 end
    end

    return lume.round(exploredRooms/totalRooms * 100) .. "%"
end
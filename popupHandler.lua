popupHandler = {}
popupHandler.elements = {}
--popupHandler.font = love.graphics.newFont("ast/rainyhearts.ttf")
popupHandler.font = love.graphics.newFont("ast/pixelmix.ttf", 8)

function popupHandler:addElement(text, x, y, colorTable, lifetime, motionModifier)
    table.insert(self.elements, {displayText = text, x = lume.round(x), y = lume.round(y), color = colorTable, lifetime = lifetime or 0.5, motionModifier = motionModifier or 1})
end

function popupHandler:update(dt)
    for i, j in ipairs(self.elements) do
        j.lifetime = j.lifetime - dt

        j.y = j.y - j.motionModifier * dt * 20

        if j.lifetime <= 0 then table.remove(self.elements, i) end
    end
end

function popupHandler:render()
    love.graphics.setFont(self.font)
    for i, j in ipairs(self.elements) do
        local x, y = playerCam:toScreen(j.x, j.y)
        love.graphics.printf({j.color, j.displayText}, x, y, 64, "center")
    end
end
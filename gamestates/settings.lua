settings = {}

function settings:init()
    self.frameImage = love.graphics.newImage("gfx/settingsBackground.png")
    self.font = love.graphics.newFont("ast/pixelmix.ttf", 16)

    self.entries = {
        {text = "Master Volume:", value = SettingValues.MasterVolume},
        {text = "Music Volume:", value = SettingValues.MusicVolume},
        {text = "Effect Volume:", value = SettingValues.EffectVolume},
        {text = "VSync:", value = SettingValues.VSync},
        {text = "Fullscreen:", value = SettingValues.Fullscreen},
    }

    self.buttons = {
        {text = "<", x = 280, y = 65, fn = changeVolume, params = {1, -0.1}},
        {text = ">", x = 510, y = 65, fn = changeVolume, params = {1, 0.1}},

        {text = "<", x = 280, y = 95, fn = changeVolume, params = {2, -0.1}},
        {text = ">", x = 510, y = 95, fn = changeVolume, params = {2, 0.1}},

        {text = "<", x = 280, y = 125, fn = changeVolume, params = {3, -0.1}},
        {text = ">", x = 510, y = 125, fn = changeVolume, params = {3, 0.1}}
    }

    self.toggles = {
        {x = 300, y = 155, w = 16, fn = changeToggle, params = {4, nil}},
        {x = 300, y = 185, w = 16, fn = changeToggle, params = {5, nil}}
    }
end

function settings:enter()
end

function settings:update(dt)
    local camX, camY = playerCam:getPosition()
    playerCam:setPosition(camX + (love.math.noise(math.cos(os.clock() / 10)) - 0.5) * 1, camY - (love.math.noise(os.clock() / 10) - 0.5) * 1)

    if input:pressed("back") then
        Gamestate.pop()
    end
end

function settings:draw()
    menu.blurEffect(function ()
        playerCam:draw(function(l,t,w,h)
            maze:render()
        end)
    end)

    love.graphics.draw(self.frameImage, 320, 180, 0, 1, 1, 250, 166)

    love.graphics.setFont(self.font)
    love.graphics.setColor(28/255, 35/255, 128/255)

    for i, j in ipairs(self.entries) do
        love.graphics.print(tostring(j.text), 100, 35 + i * 30)

        if type(j.value) == "boolean" then
            love.graphics.setLineStyle("rough")
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", 300, 35 + i * 30, 16, 16)

            if j.value then
                love.graphics.line(300 + 1, 35 + i * 30 + 1, 300 + 16 - 1, 35 + i * 30 + 16 - 1)
                love.graphics.line(300 + 16 - 1, 35 + i * 30 + 1, 300 + 1, 35 + i * 30 + 16 - 1)
            end

            love.graphics.setLineWidth(1)
        else
            love.graphics.rectangle("fill", 300, 35 + i * 30 + 5, 200 * j.value, 8)
            --love.graphics.print(tostring(j.value), 400, 35 + i * 30)
        end
    end

    for i, j in ipairs(self.buttons) do
        love.graphics.print(tostring(j.text), j.x, j.y)
    end
end

function settings:leave()
    SettingValues = {
		MasterVolume 	= settings.entries[1].value,
		MusicVolume		= settings.entries[2].value,
		EffectVolume	= settings.entries[3].value,
		VSync			= settings.entries[4].value,
		Fullscreen		= settings.entries[5].value,
	}

    bitser.dumpLoveFile("settings.dat", SettingValues)
end

function settings:resume()

end

function settings:mousepressed(mx, my, button)
    mx, my = mx/renderScale, my/renderScale

    if button == 1 then
        for i, j in ipairs(self.buttons) do
            if mx >= j.x and mx <= j.x + self.font:getWidth(j.text) and my >= j.y and my <= j.y + self.font:getHeight(j.text) then
                j.fn(j.params[1], j.params[2])
            end
        end

        for i, j in ipairs(self.toggles) do
            if mx >= j.x and mx <= j.x + j.w and my >= j.y and my <= j.y + j.w then
                j.fn(j.params[1])
            end
        end
    end
end

function changeVolume(element, value)
    settings.entries[element].value = math.min(1, math.max(0, settings.entries[element].value + value))

    musicTag.volume = settings.entries[2].value * settings.entries[1].value
    sfxTag.volume = settings.entries[3].value * settings.entries[1].value
end

function changeToggle(element)
    settings.entries[element].value = not settings.entries[element].value

    love.window.setFullscreen(settings.entries[5].value)
	renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)
    love.window.setVSync(settings.entries[4].value)
end
require "mazeGenerator"

local TICK_RATE = 1 / 200
local MAX_FRAME_SKIP = 25

function love.load()
	sTime = os.clock()
	mazeWidth = 20
	mazeHeight = 20
	drawScale = math.floor(math.min((love.graphics.getWidth() - 20) / (mazeWidth + 1), (love.graphics.getHeight() - 20) / (mazeHeight + 1)))

	stuff = createMaze(mazeWidth, mazeHeight)

	timer = 0
	eTime = os.clock()
end

function love.update(dt)
	--updateMaze()
end

function love.draw()
	love.graphics.scale(drawScale)
	love.graphics.translate(1, 1)
	stuff.render(stuff, drawScale)

	love.graphics.setColor(1, 0, 0)
	love.graphics.print(eTime - sTime, love.graphics.getWidth() - 50, 50)
    love.graphics.reset()
end

function love.resize()
	drawScale = math.floor(math.min((love.graphics.getWidth()) / (mazeWidth + 1), (love.graphics.getHeight()) / (mazeHeight + 1)))
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end

	if key == "f5" then
		love.event.quit("restart")
	end

	if key == "f1" then
		love.load()
	end

	if key == "space" then
		stuff = createMaze(mazeWidth, mazeHeight)
	end
end

--[[function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end

    local lag = 0.0

    -- Main loop time.
    return function()
        -- Process events.
        if love.event then
            love.event.pump()
            for name, a,b,c,d,e,f in love.event.poll() do
                if name == "quit" then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a,b,c,d,e,f)
            end
        end

        -- Cap number of Frames that can be skipped so lag doesn't accumulate
        if love.timer then lag = math.min(lag + love.timer.step(), TICK_RATE * MAX_FRAME_SKIP) end

        while lag >= TICK_RATE do
            if love.update then love.update(TICK_RATE) end
            lag = lag - TICK_RATE
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            if love.draw then love.draw() end
            love.graphics.present()
        end

        -- Even though we limit tick rate and not frame rate, we might want to cap framerate at 1000 frame rate as mentioned https://love2d.org/forums/viewtopic.php?f=4&t=76998&p=198629&hilit=love.timer.sleep#p160881
        --if love.timer then love.timer.sleep(0.001) end
    end
end]]
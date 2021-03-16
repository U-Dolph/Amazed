windfield = require "lib/windfield"
anim8 = require "lib/anim8"
Camera = require "lib/camera"

player = require "player"
maze = require "maze"

mazeWidth = 20
mazeHeight = 20

renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	tilemap = love.graphics.newImage("gfx/Dungeon_Tileset.png")
	animationImage = love.graphics.newImage("gfx/0x72_DungeonTilesetII_v1.3.png")

	floorImages = {
		love.graphics.newQuad(96, 0, 16, 16, tilemap),
		love.graphics.newQuad(112, 0, 16, 16, tilemap),
		love.graphics.newQuad(128, 0, 16, 16, tilemap),
		love.graphics.newQuad(144, 0, 16, 16, tilemap),
		love.graphics.newQuad(96, 16, 16, 16, tilemap),
		love.graphics.newQuad(112, 16, 16, 16, tilemap),
		love.graphics.newQuad(128, 16, 16, 16, tilemap),
		love.graphics.newQuad(144, 16, 16, 16, tilemap),
		love.graphics.newQuad(96, 32, 16, 16, tilemap),
		love.graphics.newQuad(112, 32, 16, 16, tilemap),
		love.graphics.newQuad(128, 32, 16, 16, tilemap),
		love.graphics.newQuad(144, 32, 16, 16, tilemap)
	}
	floorAtTopWallImages = {
		love.graphics.newQuad(32, 16, 16, 16, tilemap),
		love.graphics.newQuad(48, 16, 16, 16, tilemap)
	}
	floorAtTopLeftCornerImage = love.graphics.newQuad(16, 16, 16, 16, tilemap)
	floorAtTopRightCornerImage = love.graphics.newQuad(64, 16, 16, 16, tilemap)
	wallTopImages = {
		love.graphics.newQuad(16, 0, 16, 16, tilemap),
		love.graphics.newQuad(32, 0, 16, 16, tilemap),
		love.graphics.newQuad(48, 0, 16, 16, tilemap)
	}

	wallBottomImages = {
		love.graphics.newQuad(16, 64, 16, 16, tilemap),
		love.graphics.newQuad(32, 64, 16, 16, tilemap)
	}

	wallLeftImages = {
		love.graphics.newQuad(0, 0, 16, 16, tilemap),
		love.graphics.newQuad(0, 16, 16, 16, tilemap)
	}
	wallLeftInnerCornerImage = love.graphics.newQuad(0, 64, 16, 16, tilemap)
	wallLefttOuterCornerImages = {
		love.graphics.newQuad(48, 80, 16, 16, tilemap),
		love.graphics.newQuad(80, 80, 16, 16, tilemap)
	}
	wallRightImages = {
		love.graphics.newQuad(80, 0, 16, 16, tilemap),
		love.graphics.newQuad(80, 16, 16, 16, tilemap)
	}
	wallRightInnerCornerImage = love.graphics.newQuad(80, 64, 16, 16, tilemap)
	wallRightOuterCornerImages = {
		love.graphics.newQuad(0, 80, 16, 16, tilemap),
		love.graphics.newQuad(64, 80, 16, 16, tilemap)
	}

	world = windfield.newWorld(0, 0, true)
	world:addCollisionClass('Wall', {ignores = {'Wall'}})
	world:setSleepingAllowed( true )

	Maze = maze:new(mazeWidth, mazeHeight)
	Maze:createMaze(16, 8)

	Player = player:new(Maze.startNode.renderX, Maze.startNode.renderY)

	camera = Camera(Player.x, Player.y, 640, 360)
	camera:setFollowLerp(0.2)
	--camera:setFollowLead(6)
	--camera:setFollowStyle('TOPDOWN_TIGHT')

	canvas = love.graphics.newCanvas(640, 360)

	doDrawColliders = true
end

function love.update(dt)
	world:update(dt)
	Player:update(dt)
	camera:update(dt)
	camera:follow(Player.x, Player.y)
end

function love.draw()
	love.graphics.setCanvas(canvas)
		love.graphics.clear()

		camera:attach()
			Maze:render()
			Player:render()
			if doDrawColliders then world:draw() end
		camera:detach()
	love.graphics.reset()

	love.graphics.draw(canvas, math.floor(love.graphics.getWidth()/2), math.floor(love.graphics.getHeight()/2), 0, renderScale, renderScale, math.floor(canvas:getWidth()/2), math.floor(canvas:getHeight()/2))

	love.graphics.print(love.timer.getFPS(), 10, 10)
end

function love.resize()
	--camera.scale = math.min(love.graphics.getHeight() / 360, love.graphics.getWidth() / 640)
	renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)
	--camera.x, camera.y = Player.x, Player.y
end

function love.wheelmoved(_, y)

end

function love.mousemoved(x, y, dx, dy)
	--[[
		if love.mouse.isDown(1) then
		camera.x = camera.x - dx / camera.scale
		camera.y = camera.y - dy / camera.scale
	end]]

	--print(camera.x, camera.y)
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

	if key == "f" then
		love.window.setFullscreen(not love.window.getFullscreen())
		renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)
	end

	if key == "f2" then
		doDrawColliders = not doDrawColliders
	end

	if key == "space" then
		Maze:createMaze(16, 12)
	end
end

--[[ 
 *fixed timestep
function love.run()
    if love.math then love.math.setRandomSeed(os.time()) end
    if love.load then love.load(arg) end
    if love.timer then love.timer.step() end

    local dt = 0
    local fixed_dt = 1/144
    local accumulator = 0

    while true do
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            if love.update then love.update(fixed_dt) end
            accumulator = accumulator - fixed_dt
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            if love.draw then love.draw() end
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.0001) end
    end
end]]

-- 1 / Ticks Per Second
local TICK_RATE = 1 / 144

-- How many Frames are allowed to be skipped at once due to lag (no "spiral of death")
local MAX_FRAME_SKIP = 10

-- No configurable framerate cap currently, either max frames CPU can handle (up to 1000), or vsync'd if conf.lua

function love.run()
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
        if love.timer then love.timer.sleep(0.001) end
    end
end
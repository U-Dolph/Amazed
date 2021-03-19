Timer 		= require "lib/timer"
Lighter 	= require 'lib/lighter'
windfield 	= require "lib/windfield"
anim8 		= require "lib/anim8"
gamera 		= require 'lib/gamera'

player 	= require "player"
maze 	= require "maze"
minimap = require "minimap"

mazeWidth = 30
mazeHeight = 30

renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")

	cursor = love.mouse.newCursor( "gfx/cursor.png", 11, 11)
	love.mouse.setCursor(cursor)

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
	world:setSleepingAllowed(true)

	lighter = Lighter()

	cam = gamera.new(-320, -180, mazeWidth * 16 * 8 + 640, mazeHeight * 16 * 8 + 360)
	cam:setWindow(0, 0, 640, 360)

	Maze = maze:new(mazeWidth, mazeHeight, 16, 8)
	Maze:createMaze()

	Player = player:new(Maze.startNode.renderX, Maze.startNode.renderY)

	Minimap = minimap:new(518, 10, 100, 100)

	canvas = love.graphics.newCanvas(640, 360)
	lightCanvas = love.graphics.newCanvas(640, 360)

	doDrawColliders = false
end

function love.update(dt)
	world:update(dt)
	Maze:update(dt)
	Player:update(dt)
	cam:setPosition(Player.x, Player.y)

	preDrawLights()
end

function love.draw()
	love.graphics.setCanvas({canvas, stencil = true})
		love.graphics.clear()

		cam:draw(function(l,t,w,h)
			Maze:render()
			Player:render()
			if doDrawColliders then world:draw() end
		end)

		love.graphics.setBlendMode("multiply", "premultiplied")
		love.graphics.draw(lightCanvas)
		love.graphics.setBlendMode("alpha")
		Minimap:render()
	love.graphics.reset()

	love.graphics.draw(canvas, math.floor(love.graphics.getWidth()/2), math.floor(love.graphics.getHeight()/2), 0, renderScale, renderScale, math.floor(canvas:getWidth()/2), math.floor(canvas:getHeight()/2))

	love.graphics.print("FPS:" .. love.timer.getFPS(), 10, 10)
	love.graphics.print("Body Count: " .. world:getBodyCount( ), 10, 30)
end

function love.resize()
	renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)
end

function love.wheelmoved(_, y)

end

function love.mousemoved(x, y, dx, dy)
end

function love.keypressed(key)
	Player:getKeypress(key)

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

	if key == "v" then
		love.window.setVSync(love.window.getVSync() == 0 and 1 or 0)
	end

	if key == "f2" then
		doDrawColliders = not doDrawColliders
	end
end

function preDrawLights()
	love.graphics.setCanvas({ lightCanvas, stencil = true})
	love.graphics.clear(0.0, 0.0, 0.0) -- Global illumination level
	local tX, tY = cam:getPosition()
	tX = tX - 320
	tY = tY - 180
	love.graphics.translate(-tX, -tY)
	lighter:drawLights()
	love.graphics.setCanvas()
	love.graphics.reset()
end
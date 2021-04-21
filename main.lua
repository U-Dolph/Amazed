moonshine 	= require "lib.moonshine"
Gamestate 	= require "lib.gamestate"
lume 		= require "lib.lume"
lurker 		= require "lib.lurker"
Timer 		= require "lib.timer"
Lighter		= require 'lib.lighter'
windfield 	= require "lib.windfield"
anim8 		= require "lib.anim8"
gamera 		= require 'lib.gamera'

Player 		= require "player"
MazeGen 	= require "maze"
Minimap 	= require "minimap"
HUD 		= require "HUD"
Enemy 		= require "enemies.enemy"
SmallEnemy 	= require "enemies.smallEnemy"

--*GAMESTATES*--
require "gamestates.menu"
require "gamestates.game"

mazeWidth = 20
mazeHeight = 20

renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)

_ROOMDEPTH = 3

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	loadSpritesheet()

	World = windfield.newWorld(0, 0, true)
	World:addCollisionClass('Wall', {ignores = {'Wall'}})
	World:addCollisionClass('EnemyFoot')
	World:addCollisionClass('PlayerFoot')
	World:addCollisionClass('EnemyBody', {ignores = {'Wall', 'EnemyFoot', 'EnemyBody', 'PlayerFoot'}})

	lightWorld  = Lighter()
	lightCanvas = love.graphics.newCanvas(640, 360)

	playerCam = gamera.new(-320, -180, mazeWidth * 16 * 8 + 640, mazeHeight * 16 * 8 + 360)
	playerCam:setWindow(0, 0, 640, 360)

	maze = MazeGen:new(mazeWidth, mazeHeight, 16, 8)

	player = Player:new()
	hud = HUD:new()

	Gamestate.registerEvents{'keypressed', 'mousepressed'}
	Gamestate.switch(menu)

	canvas = love.graphics.newCanvas(640, 360)

	--[[
	doDrawColliders = false
	doDrawLight = true
	spawnEnemies()
	]]
end

function love.update(dt)
	lurker.update()
	Gamestate.update(dt)
	--[[
	local entities = getEntitiesToRender(true)

	for i, j in ipairs(Enemies) do
		j:update(dt)

		if j.health <= 0 then
			if j.state ~= "explosion" then
				j.state = "explosion"
				j.footCollider:destroy()
				j.bodyCollider:destroy()
				j.timer:after(0.8, function() j.alive = false end)
			end
		end

		if not j.alive then table.remove(Enemies, i) end
	end

	preDrawLights()
	]]
end

function love.draw()
	--local roomsRendered = 0
	--local entities = getEntitiesToRender()
	love.graphics.setCanvas({canvas, stencil = true})
		love.graphics.clear()
		Gamestate.draw()
	love.graphics.reset()

	love.graphics.draw(canvas, math.floor(love.graphics.getWidth()/2), math.floor(love.graphics.getHeight()/2), 0, renderScale, renderScale, math.floor(canvas:getWidth()/2), math.floor(canvas:getHeight()/2))

	love.graphics.print("FPS:" .. love.timer.getFPS(), 10, 10)
	--[[love.graphics.print("Body Count: " .. world:getBodyCount( ), 10, 30)
	love.graphics.print("Rooms rendered: " .. roomsRendered, 10, 50)
	love.graphics.print("Entities rendered: " .. #entities, 10, 70)
	love.graphics.print("Render depth: " .. _ROOMDEPTH, 10, 90)
	]]
end

function love.resize()
	renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)
end

function love.mousepressed(x, y, button)
	--Player:getMousepresses(x, y, button)
end

function love.wheelmoved(x, y)
	--_ROOMDEPTH = _ROOMDEPTH + y
end

function love.keypressed(key)
	--Player:getKeypress(key)

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

	if key == "l" then
		doDrawLight = not doDrawLight
	end

	if key == "f2" then
		doDrawColliders = not doDrawColliders
	end

	--*FOR DEBUG ONLY*--
	if key == "kp+" then
		playerCam:setScale(playerCam:getScale() + 0.1)
	elseif key == "kp-" then
		playerCam:setScale(playerCam:getScale() - 0.1)
	end
end

function preDrawLights()
	love.graphics.setCanvas({ lightCanvas, stencil = true})
	love.graphics.clear(0.0, 0.0, 0.0) -- Global illumination level
	local tX, tY = playerCam:getPosition()
	local scale = playerCam:getScale()
	tX = tX * scale - 320
	tY = tY * scale - 180
	love.graphics.translate(-tX, -tY)
	love.graphics.scale(scale)
	lightWorld:drawLights()
	love.graphics.setCanvas()
	love.graphics.reset()
end

function loadSpritesheet()
	tilemap = love.graphics.newImage("gfx/Dungeon_Tileset.png")
	animationImage = love.graphics.newImage("gfx/0x72_DungeonTilesetII_v1.3.png")
	smokeImage = love.graphics.newImage("gfx/smoke.png")
	smallExplosionImage = love.graphics.newImage("gfx/explosion-small.png")

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

	exitImages = {
		love.graphics.newQuad(96, 48, 16, 16, tilemap),
		love.graphics.newQuad(112, 48, 16, 16, tilemap)
	}
end

function spawnEnemies()
	for _, j in ipairs(maze.rooms) do
		if love.math.random() > 0.5 and j.isNode then

			for _ = 1, love.math.random(1, 2) do
				--table.insert(Enemies, smallEnemy:new(j.renderX + j.tileSize * 2 + love.math.random(j.w - j.tileSize * 4), j.renderY + j.tileSize * 2 + love.math.random(j.h - j.tileSize * 4)))
				--Enemies[#Enemies]:update(0)
			end
		end
	end
end
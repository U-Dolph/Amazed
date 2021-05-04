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
SludgeEnemy = require "enemies.sludgeEnemy"
Chest 		= require "chest"
item 		= require "item"

require "enemyFactory"
require "popupHandler"

--*GAMESTATES*--
require "gamestates.menu"
require "gamestates.game"
require "gamestates.gameover"

mazeWidth = 20
mazeHeight = 20

renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)

_ROOMDEPTH = 3
doDrawLight = true

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	loadSpritesheet()

	World = windfield.newWorld(0, 0, true)
	World:addCollisionClass('Wall', {ignores = {'Wall'}})
	World:addCollisionClass('EnemyFoot')
	World:addCollisionClass('PlayerFoot')
	World:addCollisionClass('EnemyBody', {ignores = {'Wall', 'EnemyFoot', 'EnemyBody', 'PlayerFoot'}})
	World:addCollisionClass('Chest', {ignores = {'Wall', "EnemyBody"}})
	World:addCollisionClass('Item', {ignores = {'Chest', "EnemyBody", "EnemyFoot", "PlayerFoot"}})
	World:setQueryDebugDrawing(true)

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
end

function love.update(dt)
	lurker.update()
	Gamestate.update(dt)
end

function love.draw()
	love.graphics.setCanvas({canvas, stencil = true})
		love.graphics.clear()
		Gamestate.draw()
	love.graphics.reset()

	love.graphics.draw(canvas, math.floor(love.graphics.getWidth()/2), math.floor(love.graphics.getHeight()/2), 0, renderScale, renderScale, math.floor(canvas:getWidth()/2), math.floor(canvas:getHeight()/2))

	love.graphics.print("FPS:" .. love.timer.getFPS(), 10, 10)
	love.graphics.print("Body Count: " .. World:getBodyCount( ), 10, 30)
	love.graphics.print("Render depth: " .. _ROOMDEPTH, 10, 50)
	love.graphics.print(tostring(player.invicible), 10, 70)
end

function love.resize()
	renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)
end

function love.wheelmoved(x, y)
	_ROOMDEPTH = _ROOMDEPTH + y
end

function love.keypressed(key)
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
	swingImage = love.graphics.newImage("gfx/swing02.png")
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

	chestImages = {
		love.graphics.newQuad(19 * 16, 18 * 16, 16, 16, animationImage),
		love.graphics.newQuad(21 * 16, 18 * 16, 16, 16, animationImage)
	}

	healthPotionImage = love.graphics.newQuad(18 * 16, 14 * 16, 16, 16, animationImage)
	keyImage = love.graphics.newQuad(9 * 16, 9 * 16, 16, 16, tilemap)
end
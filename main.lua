bitser = require "lib/bitser"
baton 		= require "lib.baton"
ripple 		= require "lib.ripple"
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
require "inputContainer"

--*GAMESTATES*--
require "gamestates.menu"
require "gamestates.game"
require "gamestates.gameover"
require "gamestates.leaderboard"
require "gamestates.settings"

mazeWidth = 20
mazeHeight = 20

renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)

_ROOMDEPTH = 3
doDrawLight = true

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	loadSpritesheet()
	Audio = loadAudio()

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

	MusicsToPlay = lume.shuffle(Audio.Musics)

	MusicPicked = love.math.random(1, #MusicsToPlay)
	CurrentlyPlaying = MusicsToPlay[MusicPicked]:play()

	cursor = love.mouse.newCursor("gfx/cursor.png", 11, 11)
	love.mouse.setCursor(cursor)

	Highscores = {}
	loadHighscores()

	SettingValues = {
		MasterVolume 	= 1.0,
		MusicVolume		= 0.5,
		EffectVolume	= 0.3,
		VSync			= true,
		Fullscreen		= false,
	}
	loadSettings()
end

function love.update(dt)
	lurker.update()
	Gamestate.update(dt)
	input:update()

	if CurrentlyPlaying:isStopped() then
		table.remove(MusicsToPlay, MusicPicked)

		if #MusicsToPlay == 0 then
			MusicsToPlay = lume.shuffle(Audio.Musics)
		end

		MusicPicked = love.math.random(1, #MusicsToPlay)
		CurrentlyPlaying = MusicsToPlay[MusicPicked]:play()
	end
end

function love.draw()
	love.graphics.setCanvas({canvas, stencil = true})
		love.graphics.clear()
		Gamestate.draw()
	love.graphics.reset()

	love.graphics.draw(canvas, math.floor(love.graphics.getWidth()/2), math.floor(love.graphics.getHeight()/2), 0, renderScale, renderScale, math.floor(canvas:getWidth()/2), math.floor(canvas:getHeight()/2))

	love.graphics.print("FPS:" .. love.timer.getFPS(), 10, 10)
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

	if key == "f1" and Gamestate.current() == game then
		Gamestate.switch(game)
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

function loadAudio()
	musicTag = ripple.newTag()
	sfxTag = ripple.newTag()

	local Audio = {}
	Audio.Musics = {
		ripple.newSound(love.audio.newSource("sfx/The Creature 1.ogg", "stream"), {tags = {musicTag}}),
		ripple.newSound(love.audio.newSource("sfx/The Creature 2.ogg", "stream"), {tags = {musicTag}}),
		ripple.newSound(love.audio.newSource("sfx/The Creature 3.ogg", "stream"), {tags = {musicTag}}),
		ripple.newSound(love.audio.newSource("sfx/The Creature 4.ogg", "stream"), {tags = {musicTag}}),
		ripple.newSound(love.audio.newSource("sfx/The Creature 5.ogg", "stream"), {tags = {musicTag}})
	}

	Audio.Effects = {
		swordSwing 			= ripple.newSound(love.audio.newSource("sfx/swing2.ogg", "static"), {tags = {sfxTag}}),
		smallEnemyNotice 	= ripple.newSound(love.audio.newSource("sfx/smallEnemyNotice.ogg", "static"), {tags = {sfxTag}}),
		smallEnemyHit		= ripple.newSound(love.audio.newSource("sfx/smallEnemyHit.ogg", "static"), {tags = {sfxTag}}),
		sludgeEnemyNotice 	= ripple.newSound(love.audio.newSource("sfx/sludgeEnemyNotice.ogg", "static"), {tags = {sfxTag}}),
		sludgeEnemyHit		= ripple.newSound(love.audio.newSource("sfx/sludgeEnemyHit.ogg", "static"), {tags = {sfxTag}}),
		potionPickup		= ripple.newSound(love.audio.newSource("sfx/bottle.ogg", "static"), {tags = {sfxTag}}),
		keyPickup			= ripple.newSound(love.audio.newSource("sfx/keyPickup.ogg", "static"), {tags = {sfxTag}}),
	}

	--music.volume = 0.0
	--sfx.volume = .3

	return Audio
end

function loadHighscores()
	if love.filesystem.getInfo("scores.dat") then
		Highscores = bitser.loadLoveFile("scores.dat")
	else
		bitser.dumpLoveFile("scores.dat", Highscores)
	end
end

function loadSettings()
	if love.filesystem.getInfo("settings.dat") then
		SettingValues = bitser.loadLoveFile("settings.dat")
	else
		bitser.dumpLoveFile("settings.dat", SettingValues)
	end

	musicTag.volume = SettingValues.MusicVolume * SettingValues.MasterVolume
    sfxTag.volume = SettingValues.EffectVolume * SettingValues.MasterVolume

    love.window.setFullscreen(SettingValues.Fullscreen)
    love.window.setVSync(SettingValues.VSync)
	renderScale = math.min(love.graphics.getWidth() / 640, love.graphics.getHeight() / 360)
end
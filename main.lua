require "mazeGenerator"

mazeWidth = 20
mazeHeight = 20
drawScale = math.floor(math.min((love.graphics.getWidth() - 20) / (mazeWidth + 1), (love.graphics.getHeight() - 20) / (mazeHeight + 1)))
Scale = 1
OffsetX = 0
OffsetY = 0

function love.load()
	stuff = createMaze(mazeWidth, mazeHeight)
	love.graphics.setDefaultFilter("nearest", "nearest")

	timer = 0

	img = love.graphics.newImage("gfx/0x72_DungeonTilesetII_v1.3.png")

	floor = love.graphics.newQuad(16, 64, 16, 16, img:getDimensions())

	wallLeft = love.graphics.newQuad(16, 128, 16, 16, img:getDimensions())
	wallLeftCorner = love.graphics.newQuad(32, 128, 16, 16, img:getDimensions())

	wallRight = love.graphics.newQuad(0, 128, 16, 16, img:getDimensions())
	wallRightCorner = love.graphics.newQuad(48, 128, 16, 16, img:getDimensions())

	wallTop = love.graphics.newQuad(16, 16, 16, 16, img:getDimensions())

	tilemap = {}

	for y = 0, mazeHeight - 1 do
		for x = 0, mazeWidth - 1 do
			local room = {tiles = {}, x = x * 16 * 16, y = y * 16 * 16}
			table.insert(tilemap, room)
		end
	end

	for i, j in ipairs(tilemap) do
		if not stuff.rooms[i].previsited then
			for k = 0, 15 do
				for l = 0, 15 do
					table.insert(j.tiles, {floorImage = floor, wallImage = nil, x = j.x + l * 16, y = j.y + k * 16})
				end
			end
		end

		for k, l in ipairs(j.tiles) do
			if stuff.rooms[i].path[1] == 0 and l.y == j.y then
				l.wallImage = wallTop
			end

			if stuff.rooms[i].path[4] == 0 and l.x == j.x then
				l.wallImage = wallLeft

				if stuff.rooms[i].path[1] == 0 and j.x == l.x and j.y == l.y then
					l.wallImage = wallLeftCorner
				end
			end

			if stuff.rooms[i].path[2] == 0 and l.x == j.x + 16 * 15 then
				l.wallImage = wallRight

				if stuff.rooms[i].path[1] == 0 and l.x == j.x + 16 * 15 and l.y == j.y then
					l.wallImage = wallRightCorner
				end
			end
		end
	end
end

function love.update(dt)

end

function love.draw()
	love.graphics.scale(drawScale)
	love.graphics.translate(1, 1)

	stuff.render(stuff, drawScale)
	love.graphics.reset()

	love.graphics.scale(Scale)
	love.graphics.translate(OffsetX, OffsetY)
	--[[for i, j in ipairs(tilemap) do
		for k, l in ipairs(j.tiles) do
			love.graphics.draw(img, l.floorImage, l.x, l.y)
			if l.wallImage then
				love.graphics.draw(img, l.wallImage, l.x, l.y)
			end
		end
	end]]

	love.graphics.reset()
end

function love.resize()
	drawScale = math.floor(math.min((love.graphics.getWidth()) / (mazeWidth + 1), (love.graphics.getHeight()) / (mazeHeight + 1)))
end

function love.wheelmoved(x, y)
	Scale = math.max(Scale + y / 20, 0.05)
end

function love.mousemoved(x, y, dx, dy)
	if love.mouse.isDown(1) then
		OffsetX = OffsetX + dx / Scale
		OffsetY = OffsetY + dy / Scale
	end
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
require "mazeGenerator"

mazeWidth = 20
mazeHeight = 20
drawScale = math.floor(math.min((love.graphics.getWidth() - 20) / (mazeWidth + 1), (love.graphics.getHeight() - 20) / (mazeHeight + 1)))

function love.load()
	stuff = createMaze(mazeWidth, mazeHeight)

	timer = 0
end

function love.update(dt)

end

function love.draw()
	love.graphics.scale(drawScale)
	love.graphics.translate(1, 1)

	stuff.render(stuff, drawScale)
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
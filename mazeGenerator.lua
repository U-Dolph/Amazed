local width, height = nil, nil
local stack = {}
local startNode = nil
local endNode = nil
local maze = {
    rooms = {},
    nodes = {},
    render = function(self, _scale)
        love.graphics.setColor(1, 1, 1)
        local _lW = 1/_scale
        love.graphics.setLineWidth(_lW)
        love.graphics.rectangle("line", 0 + _lW / 2, 0 + _lW / 2, width, height)

        for i, j in ipairs(self.rooms) do
            local mx, my = love.mouse.getPosition()

            if mx >= j.x * _scale + _scale and mx < j.x * _scale + _scale + _scale and my >= j.y * _scale + _scale and my < j.y * _scale + _scale + _scale then
                if endNode ~= self.nodes[i] and love.mouse.isDown(2) then
                    endNode = self.nodes[i]
                end

                if startNode ~= self.nodes[i] and love.mouse.isDown(1) then
                    startNode = self.nodes[i]
                    solvePath()
                end
            end

            if j.path[2] == 0 then love.graphics.line(j.x + 1 + _lW / 2, j.y + _lW / 2, j.x + 1 + _lW / 2, j.y + 1 + _lW / 2) end
            if j.path[3] == 0 then love.graphics.line(j.x + _lW / 2, j.y + 1 + _lW / 2, j.x + 1 + _lW / 2, j.y + 1 + _lW / 2) end
        end

        for _, j in ipairs(self.nodes) do
            love.graphics.setColor(1, 1, 1, 0.5)

            love.graphics.circle("line", j.x + 0.5, j.y + 0.5, 0.10)

            if j == startNode then
                love.graphics.setColor(0, 1, 0)
                love.graphics.circle("fill", j.x + 0.5, j.y + 0.5, 0.15, 20)
            end

            if j == endNode then
                love.graphics.setColor(1, 0, 0)
                love.graphics.circle("fill", j.x + 0.5, j.y + 0.5, 0.15, 20)
            end
        end

        love.graphics.setColor(1, 0, 0)
        local tempNode = endNode

        while tempNode.parent do
            love.graphics.line(tempNode.x + 0.5 + _lW / 2, tempNode.y + 0.5 + _lW / 2, tempNode.parent.x + 0.5 + _lW / 2, tempNode.parent.y + 0.5 + _lW / 2)
            tempNode = tempNode.parent
        end
    end
}

local function initMaze(_w, _h)
    width, height = _w, _h

    maze.rooms = {}
    maze.nodes = {}

    for y = 0, _h - 1 do
        for x = 0, _w - 1 do
            table.insert(maze.rooms, {x = x, y = y, visited = false, path = {0, 0, 0, 0}})
            table.insert(maze.nodes, {x = x, y = y, visited = false, neighbours = {}, parent = nil, globalScore = nil, localScore = nil})
        end
    end

    table.insert(stack, maze.rooms[1])
    maze.rooms[1].visited = true
end

local function getIndex(_modX, _modY, _element)
    if not _element then _element = stack[#stack] end
    return (_element.y + _modY) * width + (_element.x + _modX) + 1
end


local function getNeighbours(_element)
    local neighbours = {}

    if _element.y > 0 and not           maze.rooms[getIndex(0, -1, _element)].visited then table.insert(neighbours, 0) end
    if _element.x < width - 1 and not   maze.rooms[getIndex(1, 0, _element)].visited then table.insert(neighbours, 1) end
    if _element.y < height - 1 and not  maze.rooms[getIndex(0, 1, _element)].visited then table.insert(neighbours, 2) end
    if _element.x > 0 and not           maze.rooms[getIndex(-1, 0, _element)].visited then table.insert(neighbours, 3) end

    return neighbours
end

local function manageNodes()
    for i, j in ipairs(maze.rooms) do
        if j.path[2] == 1 then table.insert(maze.nodes[i].neighbours, maze.nodes[getIndex(1, 0, j)]) end
        if j.path[4] == 1 then table.insert(maze.nodes[i].neighbours, maze.nodes[getIndex(-1, 0, j)]) end
        if j.path[1] == 1 then table.insert(maze.nodes[i].neighbours, maze.nodes[getIndex(0, -1, j)]) end
        if j.path[3] == 1 then table.insert(maze.nodes[i].neighbours, maze.nodes[getIndex(0, 1, j)]) end
    end

    startNode = maze.nodes[1]
    endNode = maze.nodes[#maze.nodes]
end

function solvePath()
    for i, j in ipairs(maze.nodes) do
        j.visited = false
        j.globalScore = math.huge
        j.localScore = math.huge
        j.parent = nil
    end

    local function distance(a, b)
        return math.sqrt(math.pow(a.x - b.x, 2) + math.pow(a.y - b.y, 2))
    end

    local function heuristic(a, b)
        return distance(a, b)
    end

    local currentNode = startNode
    currentNode.localScore = 0
    currentNode.globalScore = heuristic(startNode, endNode)

    notTestedList = {}
    table.insert(notTestedList, startNode)

    while #notTestedList > 0 do
        table.sort(notTestedList, function (a, b) return a.globalScore < b.globalScore end)

        while #notTestedList > 0 and notTestedList[#notTestedList].visited do
            table.remove(notTestedList)
        end

        if #notTestedList == 0 then return end

        currentNode = notTestedList[#notTestedList]
        currentNode.visited = true

        for i, j in ipairs(currentNode.neighbours) do
            if not j.visited then table.insert(notTestedList, j) end

            lowerGoal = currentNode.localScore + distance(currentNode, j)

            if lowerGoal < j.localScore then
                j.parent = currentNode
                j.localScore = lowerGoal
                j.globalScore = j.localScore + heuristic(j, endNode)
            end
        end
    end
end

function createMaze(_w, _h)
    initMaze(_w, _h)

    while #stack > 0 do
        local neighbours = getNeighbours(stack[#stack])

        if #neighbours > 0 then
            local nextDir = neighbours[love.math.random(1, #neighbours)]

            if nextDir == 0 then
                maze.rooms[getIndex(0, 0)].path[1] = 1
                maze.rooms[getIndex(0, -1)].path[3] = 1

                table.insert(stack, maze.rooms[getIndex(0, -1)])
            elseif nextDir == 1 then
                maze.rooms[getIndex(0, 0)].path[2] = 1
                maze.rooms[getIndex(1, 0)].path[4] = 1

                table.insert(stack, maze.rooms[getIndex(1, 0)])
            elseif nextDir == 2 then
                maze.rooms[getIndex(0, 0)].path[3] = 1
                maze.rooms[getIndex(0, 1)].path[1] = 1

                table.insert(stack, maze.rooms[getIndex(0, 1)])
            elseif nextDir == 3 then
                maze.rooms[getIndex(0, 0)].path[4] = 1
                maze.rooms[getIndex(-1, 0)].path[2] = 1

                table.insert(stack, maze.rooms[getIndex(-1, 0)])
            end

            maze.rooms[getIndex(0, 0)].visited = true
        else
            table.remove(stack)
        end
    end

    manageNodes()
    solvePath()

    return maze
end

function updateMaze()
    if #stack > 0 then
        local neighbours = getNeighbours(stack[#stack])

        if #neighbours > 0 then
            local nextDir = neighbours[love.math.random(1, #neighbours)]

            if nextDir == 0 then
                maze.rooms[getIndex(0, 0)].path[1] = 1
                maze.rooms[getIndex(0, -1)].path[3] = 1

                table.insert(stack, maze.rooms[getIndex(0, -1)])
            elseif nextDir == 1 then
                maze.rooms[getIndex(0, 0)].path[2] = 1
                maze.rooms[getIndex(1, 0)].path[4] = 1

                table.insert(stack, maze.rooms[getIndex(1, 0)])
            elseif nextDir == 2 then
                maze.rooms[getIndex(0, 0)].path[3] = 1
                maze.rooms[getIndex(0, 1)].path[1] = 1

                table.insert(stack, maze.rooms[getIndex(0, 1)])
            elseif nextDir == 3 then
                maze.rooms[getIndex(0, 0)].path[4] = 1
                maze.rooms[getIndex(-1, 0)].path[2] = 1

                table.insert(stack, maze.rooms[getIndex(-1, 0)])
            end

            maze.rooms[getIndex(0, 0)].visited = true
        else
            table.remove(stack)
        end
    end
end
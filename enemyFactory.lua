EnemyFactory = {}

function EnemyFactory.spawnEnemy(enemyType, xCoord, yCoord)
    if enemyType == 1 then
        return SmallEnemy:new(xCoord, yCoord)
    end
end
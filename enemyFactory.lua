ENEMY_TYPES = {
    SmallEnemy = {ID = 1, weight = 6},
    SludgeEnemy = {ID = 2, weight = 3},
    PyroEnemy = {ID = 3, weight = 1},
}

EnemyFactory = {}

function EnemyFactory.spawnEnemy(enemyType, xCoord, yCoord)
    if enemyType == ENEMY_TYPES.SmallEnemy then
        return SmallEnemy:new(xCoord, yCoord)
    elseif enemyType == ENEMY_TYPES.SludgeEnemy then
        return SludgeEnemy:new(xCoord, yCoord)
    elseif enemyType == ENEMY_TYPES.PyroEnemy then
        return PyroEnemy:new(xCoord, yCoord)
    end
end
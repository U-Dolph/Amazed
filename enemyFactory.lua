ENEMY_TYPES = {
    SmallEnemy = {ID = 1, weight = 10},
    SludgeEnemy = {ID = 2, weight = 20}
}

EnemyFactory = {}

function EnemyFactory.spawnEnemy(enemyType, xCoord, yCoord)
    if enemyType == ENEMY_TYPES.SmallEnemy then
        return SmallEnemy:new(xCoord, yCoord)
    elseif enemyType == ENEMY_TYPES.SludgeEnemy then
        return SludgeEnemy:new(xCoord, yCoord)
    end
end
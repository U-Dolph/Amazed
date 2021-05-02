ENEMY_TYPES = {
    SmallEnemy = 1
}

EnemyFactory = {}

function EnemyFactory.spawnEnemy(enemyType, xCoord, yCoord)
    if enemyType == ENEMY_TYPES.SmallEnemy then
        return SmallEnemy:new(xCoord, yCoord)
    end
end
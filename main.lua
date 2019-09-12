require "controlpanel"

function love.load()
    mainFont = love.graphics.newFont(32)
    smallFont = love.graphics.newFont(24)
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    time = 0
    player = {x = 0, y = 0, 
            speed = 10, thrust = 10, heading = 0, rudder = 0}
    -- posx = 0
    -- posy = 0
    -- thrust = 0
    -- speed = 0
    -- heading = 0
    -- rudder = 0
    enemy = {x = love.math.random() * 1000 - 500, y = love.math.random() * 500 + 1000, 
            speed = 10, thrust = 10, heading = 180, rudder = 0}
    lastKnownEnemySighting = {x = enemy.x, y = enemy.y, speed = enemy.speed, heading = enemy.heading, time=time}
end


function love.update(dt)
    time = time + dt
    framerate = 1/dt
    depth = 100 + 100 * math.sin(time/20)
    floor = 190 + 20 * math.cos(time/4)

    checkKeyboard(dt)
    moveSubmarine(dt, player)
    moveSubmarine(dt, enemy)
    enemyAi(dy, enemy, player)

    -- We will decrease the variable by 1/s if any of the wasd keys is pressed. 
end

function enemyAi(dy, enemy, player)
    enemy.throttle = 5
    enemy.rudder = 0.5
end


function love.draw()
    love.graphics.printf("X", 10, 10, 100, "left")
    love.graphics.printf(math.floor(player.x*10)/10, 30, 10, 100, "left")
    love.graphics.printf("Y", 130, 10, 100, "left")
    love.graphics.printf(math.floor(player.y*10)/10, 160, 10, 100, "left")
    love.graphics.printf("X", 10, 40, 100, "left")
    love.graphics.printf(math.floor(enemy.x*10)/10, 30, 40, 100, "left")
    love.graphics.printf("Y", 130, 40, 100, "left")
    love.graphics.printf(math.floor(enemy.y*10)/10, 160, 40, 100, "left")
    love.graphics.printf(math.floor(framerate*10)/10, 500, 10, 100, "left")
    drawControlPanel()
    drawSpeed(player.speed)
    drawThrust(player.thrust)
    drawDepth(depth)
    drawFloor(depth, floor)
    drawPlayer()
    -- Rotated map
    drawCompass(player.heading, player.x, player.y)
    drawGrid(player)
    drawEnemy(enemy, lastKnownEnemySighting, player)
    -- drawEnemy(time/19, 100 * math.sin(time/4) + width/3, 100 * math.cos(time/4) + height/3)
    -- drawEnemy(time/19, 100 * math.cos(time/3) + 2*width/3, 100 * math.cos(time/4) + 2*height/3)
end

function moveSubmarine(dt, submarine)
    if (submarine.speed < submarine.thrust) and submarine.thrust > 0 then
        submarine.speed = submarine.speed + (submarine.thrust-submarine.speed) * dt * 0.1
    end
    if (submarine.speed > submarine.thrust) and submarine.thrust < 0 then
        submarine.speed = submarine.speed - (submarine.speed-submarine.thrust) * dt * 0.1
    end
    if (submarine.speed > submarine.thrust) and submarine.thrust > 0 then
        submarine.speed = submarine.speed - (submarine.speed - submarine.thrust) * submarine.speed * 0.1 * dt
    end
    if (submarine.speed < submarine.thrust) and submarine.thrust < 0 then
        submarine.speed = submarine.speed + (submarine.speed - submarine.thrust) * submarine.speed * 0.1 * dt
    end

    submarine.x = submarine.x + math.sin(submarine.heading) * submarine.speed * dt * 5
    submarine.y = submarine.y + math.cos(submarine.heading) * submarine.speed * dt * 5
    submarine.heading = submarine.heading + math.min(submarine.speed * submarine.rudder * dt * 0.01, 1);
end

function checkKeyboard(dt)
    if love.keyboard.isDown("up", "w") and player.thrust < 20 then
        player.thrust = player.thrust + dt * 3
        fullstop = false
        if (player.thrust > 20) then 
            player.thrust = 20
        end
    end
    if love.keyboard.isDown('down', 's') and (player.thrust > 0 or fullstop) then
        player.thrust = player.thrust - dt * 3
        if not fullstop and player.thrust < 0 then 
            player.thrust = 0
        end
        if fullstop and player.thrust < -20 then 
            player.thrust = -20
        end
    end
    if not love.keyboard.isDown('down', 's') and player.thrust == 0 then
        fullstop = true
    end
    if love.keyboard.isDown("right", "d") and player.rudder > -1 then
        player.rudder = player.rudder - dt * 0.3
        if (player.rudder < -1) then 
            player.rudder = -1
        end
    end
    if love.keyboard.isDown('left', 'a') and player.rudder < 1 then
        player.rudder = player.rudder + dt * 0.3
        if (player.rudder > 1) then 
            player.rudder = 1
        end
    end

end


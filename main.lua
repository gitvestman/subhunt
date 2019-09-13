require "controlpanel"

function love.load()
    mainFont = love.graphics.newFont(32)
    smallFont = love.graphics.newFont(24)
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    sonarSound = love.audio.newSource("12677__peter-gross__sonar-pings.ogg", "static")
    torpedoSound = love.audio.newSource("327990__bymax__processed-swish-swoosh-whoosh.wav", "static")
    explosionSound = love.audio.newSource("147873__zesoundresearchinc__depthbomb-04.wav", "static")
    time = 0
    player = {x = 0, y = 0, 
            speed = 10, thrust = 10, heading = 0, rudder = 0}
    enemy = {x = love.math.random() * 1500 - 750, y = love.math.random() * 500 + 1200, 
            speed = 10, thrust = 10, heading = 180, rudder = 0, dead = false, strategy = 1, countdown = 0}
    -- lastKnownEnemySighting = {x = enemy.x, y = enemy.y, speed = enemy.speed, heading = enemy.heading, time=time}
    sonar = {active = true, time = time}
    sonarSound:play()
    torpedo = {active = false}
    displayScale = height/4000
end


function love.update(dt)
    time = time + dt
    framerate = 1/dt
    depth = 100 + 20 * math.sin(time/40)
    floor = 180 + 10 * math.cos(time/10)

    checkKeyboard(dt)
    moveSubmarine(dt, player)
    moveSubmarine(dt, enemy)
    enemyAi(dt, enemy, player)
    if (enemy.dead) then
        spawnNewEnemy()
    end

    -- We will decrease the variable by 1/s if any of the wasd keys is pressed. 
end

function spawnNewEnemy()
    angle = love.math.random() * 360
    enemy = {x = player.x + math.sin(angle) * 1200, y = player.y + math.cos(angle) * 1200, 
            speed = 10, thrust = 10, heading = 180-angle, rudder = 0, dead = false, countdown = 5}
    enemy.strategy = math.floor(love.math.random()*10)    
end

function enemyAi(dt, enemy, player)
    if bit.band(enemy.strategy, 0x01) then -- stealth
        if (enemy.thrust > 5) then
            enemy.thrust = enemy.thrust - dt/2
        end
    else
        if (enemy.thrust < 20) then
            enemy.thrust = enemy.thrust + dt/2
        end
    end
    if bit.band(enemy.strategy, 0x01) then -- flee
        enemyangle = math.atan2(enemy.y - player.y, enemy.x - player.x)
    else
    end
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
    enemyangle = math.deg(math.atan2(enemy.x - player.x, enemy.y - player.y))
    love.graphics.printf("A", 10, 80, 100, "left")
    love.graphics.printf(math.floor(enemyangle*10)/10, 30, 80, 100, "left")
    love.graphics.printf("B", 130, 80, 100, "left")
    love.graphics.printf(math.floor(enemy.heading*10)/10, 160, 80, 100, "left")
    love.graphics.printf(math.floor(framerate*10)/10, 500, 10, 100, "left")
    drawControlPanel()
    drawSpeed(player.speed)
    drawThrust(player.thrust)
    drawDepth(depth)
    drawFloor(depth, floor)
    drawPlayer()
    -- Rotated map
    drawCompass(player.heading, player.x, player.y)
    drawStencil()
        drawGrid(player)
        drawEnemy()
        drawSonar(enemy, player)
        drawTorpedo(enemy, player)
    endStencil()
    -- drawEnemy(time/19, 100 * math.sin(time/4) + width/3, 100 * math.cos(time/4) + height/3)
    -- drawEnemy(time/19, 100 * math.cos(time/3) + 2*width/3, 100 * math.cos(time/4) + 2*height/3)
end


function moveSubmarine(dt, submarine)
    if (math.abs(submarine.speed) < math.abs(submarine.thrust)) then
        submarine.speed = submarine.speed + (submarine.thrust-submarine.speed) * dt * 0.1
    end
    -- if (submarine.speed > submarine.thrust) and submarine.thrust < 0 then
    --     submarine.speed = submarine.speed - (submarine.speed-submarine.thrust) * dt * 0.1
    -- end
    if (math.abs(submarine.speed) > math.abs(submarine.thrust)) then
        submarine.speed = submarine.speed * (1 - 0.05 * dt)
    end
    -- if (submarine.speed < submarine.thrust) and submarine.thrust < 0 then
    --     submarine.speed = submarine.speed + (submarine.speed - submarine.thrust) * submarine.speed * 0.1 * dt
    -- end

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
    if love.keyboard.isDown('q') and not sonar.active then
        sonar = {active = true, time = time}
        sonarSound:play()
    end
    if love.keyboard.isDown('e','space') and not torpedo.active then
        torpedo = {active = true, x = player.x, y = player.y, heading = player.heading, speed = 60, time = time}
        torpedoSound:play()
    end
end


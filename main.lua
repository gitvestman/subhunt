require "controlpanel"

function love.load()
    math.randomseed(1337)
    mainFont = love.graphics.newFont(36)
    smallFont = love.graphics.newFont(24)
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    sonarSound = love.audio.newSource("12677__peter-gross__sonar-pings.ogg", "static")
    torpedoSound = love.audio.newSource("327990__bymax__processed-swish-swoosh-whoosh.ogg", "static")
    explosionSound = love.audio.newSource("147873__zesoundresearchinc__depthbomb-04.ogg", "static")
    propellerSound = love.audio.newSource("260813__iccleste__echo-propeller.ogg", "static")
    propellerSound:setLooping(true)
    propellerSound:play()
    time = 0
    score = 0
    kills = 0
    level = 0
    displayScale = height/4000
    player = {x = 0, y = 0, 
            speed = 10, thrust = 10, heading = 0, rudder = 0, 
            torpedoloading = 0, torpedos = {} }
    enemy = {x = love.math.random() * 1500 - 750, y = love.math.random() * 500 + 1200, 
            speed = 10, thrust = 10, heading = 180, rudder = 0, dead = false, strategy = 1, countdown = 0, 
            torpedoloading = 0, torpedos = {}, time = time}
    explosions = {}
    player.lastKnown = {x = player.x, y = player.y, speed = player.speed, heading = player.heading, time=time}
    sonar = {active = false, time = time}
    -- sonarSound:play()
    map = love.graphics.newImage("World.jpg")
    targets = {{name = "Baltic Sea: Search and destroy", x = 645, y = 130},
        {name = "South China Sea: Search and destroy", x = 1030, y = 330},
        {name = "North Sea: Search and destroy", x = 580, y = 110},
        {name = "Persian Gulf: Search and destroy", x = 730, y = 300},
        {name = "Sulu Sea: Search and destroy", x = 1060, y = 360},
        {name = "Gulf of Mexico: Search and destroy", x = 240, y = 280}}
    showMap = true
end

function newLevel()
    level = level + 1
    player = {x = 0, y = 0, 
            speed = 10, thrust = 10, heading = 0, rudder = 0, 
            torpedoloading = 0, torpedos = {} }
    player.lastKnown = {x = player.x, y = player.y, speed = player.speed, heading = player.heading, time=time}
    showMap = true
    kills = 0
    spawnNewEnemy()
end

function love.update(dt)
    time = time + dt
    framerate = 1/dt
    depth = 100 + 20 * math.sin(time*player.speed/500)
    floor = 180 + 10 * math.cos(time*player.speed/100)    

    checkKeyboard(dt)

    if (showMap) then
        return
    end

    if (enemy.dead) then
        if enemy.countdown > 0 then
            enemy.countdown = enemy.countdown - dt
        else
            if (kills >= level) then 
                newLevel()
            else
                spawnNewEnemy()
            end
        end
    end
    if (player.dead) then
        if player.countdown > 0 then
            player.countdown = player.countdown - dt
        else
            GameOver()
        end
    else
        moveSubmarine(dt, player)
        moveSubmarine(dt, enemy)
        enemyAi(dt, enemy, player)
        propellerSound:setPitch(math.abs(player.thrust * 0.05) + 0.5)
        propellerSound:setVolume(math.max(math.abs(player.thrust * 0.05) - 0.25, 0))
    end
end

function GameOver()
end

function spawnNewEnemy()
    angle = love.math.random() * 180 - 90 + player.heading
    enemy = {x = player.x + math.sin(math.rad(angle)) * 1200, y = player.y + math.cos(math.rad(angle)) * 1200, 
            speed = 10, thrust = 10, heading = 180-angle, rudder = 0, dead = false, countdown = 5, 
            torpedoloading = 0, torpedos = {}, time = time}
    enemy.strategy = math.floor(love.math.random()*4)    
end

function enemyAi(dt, enemy, player)
    if (enemy.dead) then
        return
    end
    local calcx = player.lastKnown.x + math.sin(math.rad(player.lastKnown.heading)) * player.lastKnown.speed * (time - player.lastKnown.time) * 5
    local calcy = player.lastKnown.y + math.cos(math.rad(player.lastKnown.heading)) * player.lastKnown.speed * (time - player.lastKnown.time) * 5
    local enemydistance = math.sqrt((enemy.x - calcx)^2 + (enemy.y - calcy)^2)
    local enemyangle = math.deg(math.atan2(enemy.x - calcx, enemy.y - calcy))
    local enemyhitangle = math.deg(math.atan2(100, enemydistance)) + math.max(12 - level*2, 0)
    local differential = math.mod(enemyangle - enemy.heading - 180, 360)

    if enemydistance < 50 then
        createExplosion(player.x, player.y)
        createExplosion(enemy.x, enemy.y)
        enemy.dead = true
        player.dead = true
        player.countdown = 5
        enemy.countdown = 5
    end

    if math.abs(differential) < enemyhitangle and enemy.torpedoloading <= 0 and level > 1 and math.random() < level * 0.001 then
        fireTorpedo(enemy)
    end

    if bit.band(enemy.strategy, 0x01) and enemydistance < 1300 then -- stealth
        if (enemy.thrust > 5) then
            enemy.thrust = enemy.thrust - dt/2
        end
    else                            -- speed
        if (enemy.thrust < 20) then
            enemy.thrust = enemy.thrust + dt/2
        end
    end
    if bit.band(enemy.strategy, 0x02) and enemydistance < 1300 and enemydistance > 300 and math.abs(differential) < enemyhitangle + 30  then -- flee
        if (differential > 0) then 
            enemy.rudder = 1
        else
            enemy.rudder = -1
        end
    else                           -- fight
        if (differential > 0) then 
            enemy.rudder = -1
        else
            enemy.rudder = 1
        end
    end
    
end

function fireTorpedo(submarine)    
    torpedo = {x = submarine.x, y = submarine.y, heading = submarine.heading, speed = 50, time = time}
    submarine.lastKnown = {x = submarine.x, y = submarine.y, speed = submarine.speed, heading = submarine.heading, time=time}
    submarine.torpedos[#submarine.torpedos + 1] = torpedo
    submarine.torpedoloading = 6
    torpedoSound:play()
end

function drawMap()
    local scale = width/map:getWidth() * 3/4
    love.graphics.setColor(0.1, 0.3, 0.1) 
    love.graphics.rectangle("fill", width/8, height/8, 6*width/8, 3*height/4)
    love.graphics.setColor(0.1, 1.0, 0.1) 
    love.graphics.rectangle("line", width/8, height/8, 6*width/8, 3*height/4)
    love.graphics.draw(map, width/8, height/4, 0, scale)
    love.graphics.setFont(mainFont)
    love.graphics.printf("MISSION:", 3*width/8, height/8+10, 2*width/8, "center")
    love.graphics.setFont(smallFont)
    local target = targets[math.mod(level, #targets) + 1]
    love.graphics.printf(target.name, 2*width/8, height/8+50, 4*width/8, "center")
    local pulse = math.sin(time*5)/4 +0.75
    local colorpulse = math.sin(time*20)/4 +0.75
    love.graphics.setColor(0.1, 1.0*colorpulse, 0.1) 
    love.graphics.setLineWidth(3)
    local posx = target.x * scale + width/8
    local posy = target.y * scale + height/4
    love.graphics.line(posx-10*pulse, posy, posx-18*pulse-10, posy)
    love.graphics.line(posx+10*pulse, posy, posx+18*pulse+10, posy)
    love.graphics.line(posx, posy+10*pulse, posx, posy+18*pulse + 10)
    love.graphics.line(posx, posy-10*pulse, posx, posy-18*pulse-10)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0.1, 1.0, 0.1) 
end

function love.draw()
    -- love.graphics.printf("X", 10, 10, 100, "left")
    -- love.graphics.printf(math.floor(player.x*10)/10, 30, 10, 100, "left")
    -- love.graphics.printf("Y", 130, 10, 100, "left")
    -- love.graphics.printf(math.floor(player.y*10)/10, 160, 10, 100, "left")
    -- love.graphics.printf("X", 10, 40, 100, "left")
    -- love.graphics.printf(math.floor(enemy.x*10)/10, 30, 40, 100, "left")
    -- love.graphics.printf("Y", 130, 40, 100, "left")
    local enemydistance = math.sqrt((enemy.x - player.x)^2 + (enemy.y - player.x)^2)
    local enemyhitangle = math.deg(math.atan2(100, enemydistance))

    -- love.graphics.printf(math.floor(enemy.y*10)/10, 160, 40, 100, "left")
    -- enemyangle = math.deg(math.atan2(enemy.x - player.x, enemy.y - player.y))
    -- differential = math.mod(enemyangle - enemy.heading - 180, 360)
    love.graphics.printf("A", 10, 80, 100, "left")
    love.graphics.printf(math.floor(enemydistance*10)/10, 30, 80, 100, "left")
    love.graphics.printf("B", 130, 80, 100, "left")
    love.graphics.printf(math.floor(enemyhitangle*10)/10, 160, 80, 100, "left")
    -- love.graphics.printf("C", 260, 80, 100, "left")
    -- love.graphics.printf(math.floor(differential*10)/10, 290, 80, 100, "left")
    -- love.graphics.printf(math.floor(framerate*10)/10, 500, 10, 100, "left")
    love.graphics.printf("Score:", 5*width/6, 10, 100, "left")
    love.graphics.printf(score, 5*width/6 + 100, 10, 100, "left")
    drawControlPanel()
    drawSpeed(player.speed)
    drawThrust(player.thrust)
    drawDepth(depth)
    drawFloor(depth, floor)
    drawPlayer()
    -- Rotated map
    drawStencil(player.heading)
        drawCompass(player.heading, player.x, player.y)
        drawGrid(player)
        drawEnemy()
        drawSonar(enemy, player)
        drawTorpedo(player, enemy)
        drawTorpedo(enemy, player)
        drawExplosions()
    endStencil(player.heading)
    if (player.dead) then
        love.graphics.setFont(mainFont)
        love.graphics.printf("Game Over", width/2 - 150, 1*height/3, 300, "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to start over", width/2 - 150, 1*height/3 + 50, 300, "center")
    end
    if (showMap) then
        drawMap()
    end
    -- drawEnemy(time/19, 100 * math.sin(time/4) + width/3, 100 * math.cos(time/4) + height/3)
    -- drawEnemy(time/19, 100 * math.cos(time/3) + 2*width/3, 100 * math.cos(time/4) + 2*height/3)
end

function math.sign(x)
	return (x >= 0) and 1 or -1
end

function moveSubmarine(dt, submarine)    
    if (math.abs(submarine.speed) < math.abs(submarine.thrust)) then
        submarine.speed = submarine.speed + (submarine.thrust-submarine.speed) * dt * 0.1
    end
    if (math.abs(submarine.speed) > math.abs(submarine.thrust)) then
        submarine.speed = submarine.speed * (1 - 0.05 * dt)
    end

    submarine.x = submarine.x + math.sin(math.rad(submarine.heading)) * submarine.speed * dt * 5
    submarine.y = submarine.y + math.cos(math.rad(submarine.heading)) * submarine.speed * dt * 5
    submarine.heading = submarine.heading + (math.min(submarine.speed,15) + 2*math.sign(submarine.speed)) * submarine.rudder * dt * 0.7;

    if (submarine.torpedoloading > 0) then
        submarine.torpedoloading = submarine.torpedoloading - dt
    end
end

function checkKeyboard(dt)
    if (showMap and love.keyboard.isDown("space", "return")) and time > 1 then
        showMap = false;
        return
    end
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
    if love.keyboard.isDown('e','space') and player.torpedoloading <= 0 then
        fireTorpedo(player)
    end
    if love.keyboard.isDown('return') and player.dead then
        love.load()
    end
    if love.keyboard.isDown('o')  then
        enemy.strategy = 2
    end
    if love.keyboard.isDown('p')  then
        enemy.strategy = 0
    end
end


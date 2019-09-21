require "controlpanel"
require "highscore"
require "multiplayer"

function love.load()
    -- multiplayerAvailable = multiplayer.ping()
    -- player = {x = 0, y = 0, 
    --         speed = 10, thrust = 10, heading = 0, rudder = 0, 
    --         torpedoloading = 0, torpedos = {}, type = "player" }
    -- multiplayer.join()
    -- multiplayer.update()
    -- love.event.quit()
    love.math.setRandomSeed(1337)
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
    propellerSound:setVolume(0.5)
    time = 0
    score = 0
    kills = 0
    level = 1
    displayScale = height/4000
    player = {x = 0, y = 0, 
            speed = 10, thrust = 10, heading = 0, rudder = 0, 
            torpedoloading = 0, type = "player" }
    enemies = {{x = love.math.random() * 1500 - 750, y = love.math.random() * 500 + 1200, 
            speed = 10, thrust = 10, heading = 180, rudder = 0, dead = false, strategy = 1, 
            torpedoloading = 0, time = time, type = "enemy"}}
    torpedos = {}
    finalCountdown = 0
    explosions = {}
    player.lastKnown = {x = player.x, y = player.y, speed = player.speed, heading = player.heading, time=time}
    sonar = {active = false, time = time}
    -- sonarSound:play()
    map = love.graphics.newImage("World.png")
    targets = {{name = "Baltic Sea", x = 645, y = 130},
        {name = "South China Sea", x = 1030, y = 330},
        {name = "North Sea", x = 580, y = 110},
        {name = "Persian Gulf", x = 730, y = 300},
        {name = "Sulu Sea", x = 1060, y = 360},
        {name = "Gulf of Mexico", x = 240, y = 280}}
    showMap = true
    enemyTorpedo = false

    highscore.load()

    love.keyboard.setKeyRepeat(false)
end

function newLevel()
    level = level + 1
    print("newLevel: "..level)
    player = {x = 0, y = 0, 
            speed = 10, thrust = 10, heading = 0, rudder = 0, 
            torpedoloading = 0, type = "player" }
    player.lastKnown = {x = player.x, y = player.y, speed = player.speed, heading = player.heading, time=time}
    showMap = true
    kills = 0
    spawnNewEnemy()
end

function love.update(dt)
    time = time + dt
    framerate = 1/dt
    depth = 100 + 10 * math.sin(time*player.speed/500)
    floor = 180 + 10 * math.cos(player.x/200) + math.sin(player.y/200)

    if highscore.update(dt) then
        return 
    end
    checkKeyboard(dt)

    if (showMap) then
        return
    end

    for i=#enemies,1,-1 do
        if (enemies[i].dead) then
            table.remove(enemies, i)
        end
    end

    if #enemies == 0 and not player.dead then
        if finalCountdown > 0 then
            finalCountdown = finalCountdown - dt
        else
            if (kills >= level) then 
                newLevel()
            else
                if (math.mod(level, 2) == 1 and kills == level - 2) then
                    spawnNewEnemy()
                elseif (level > 5 and kills == level - 3) then
                    spawnNewEnemy()
                    spawnNewEnemy()
                end
                spawnNewEnemy()
            end
        end
    end
    if player.dead then
        propellerSound:stop()
        if finalCountdown > 0 then
            finalCountdown = finalCountdown - dt
        else
            GameOver()
        end
    else
        moveSubmarine(dt, player)
        for i, enemy in ipairs(enemies) do
            moveSubmarine(dt, enemy)
            enemyAi(dt, enemy, player)
        end
        propellerSound:setPitch(math.abs(player.thrust * 0.05) + 0.5)
        propellerSound:setVolume(math.max(math.abs(player.thrust * 0.05) - 0.25, 0))
    end
end

-- function love.textinput( text )
--     highscore.textinput(text)
-- end

function love.keypressed(key)
    if highscore.keypressed(key) then 
        return
    end
    if showMap and (key == "space" or key == "return") and time > 1 then
        showMap = false;
        return
    end
    if key == 'q' and not sonar.active then
        sonar = {active = true, time = time}
        sonarSound:play()
    end
    if (key == 'e' or key == 'space') and player.torpedoloading <= 0 then
        fireTorpedo(player)
    end
    if key == 'return' and player.dead then
        CheckHighScore()
        --love.load()
    end
    if key == "escape" then
        love.event.quit()
    end     
end

function GameOver()
    CheckHighScore()
end

function spawnNewEnemy()
    angle = love.math.random() * (90 * #enemies + level * 10) - 45 * #enemies + player.heading
    enemy = {x = player.x + math.sin(math.rad(angle)) * (1200 + #enemies*150), 
             y = player.y + math.cos(math.rad(angle)) * (1200 + #enemies*150), 
            speed = 7 + love.math.random(4), thrust = 10, heading = 180 - angle + 60 * (love.math.random(2) - 1.5) , rudder = 0, dead = false, countdown = 5, 
            torpedoloading = math.max(8 - level/2, 1), time = time, type = "enemy"}            
    enemy.strategy = math.floor(love.math.random()*4)    
    enemies[#enemies + 1] = enemy
end

function enemyAi(dt, enemy, player)
    if (showMap or enemy.dead) then
        return
    end
    local calcx = player.lastKnown.x + math.sin(math.rad(player.lastKnown.heading)) * player.lastKnown.speed * (time - player.lastKnown.time) * 5
    local calcy = player.lastKnown.y + math.cos(math.rad(player.lastKnown.heading)) * player.lastKnown.speed * (time - player.lastKnown.time) * 5
    local enemydistance = math.sqrt((enemy.x - calcx)^2 + (enemy.y - calcy)^2)
    local actualenemydistance = math.sqrt((enemy.x - player.x)^2 + (enemy.y - player.y)^2)
    local enemyangle = math.deg(math.atan2(enemy.x - calcx, enemy.y - calcy))
    local enemyhitangle = math.deg(math.atan2(100, enemydistance)) + math.max(12 - level*2, 0)
    local differential = math.mod(enemyangle - enemy.heading - 180, 360)

    if actualenemydistance < 50 then
        createExplosion(player.x, player.y)
        createExplosion(enemy.x, enemy.y)
        enemy.dead = true
        player.dead = true
        finalCountdown = 5
    end

    if math.abs(differential) < enemyhitangle and enemy.torpedoloading <= 0 and level > 1 then
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
    torpedo = {x = submarine.x, y = submarine.y, heading = submarine.heading, speed = 50, time = time, source = submarine}
    submarine.lastKnown = {x = submarine.x, y = submarine.y, speed = submarine.speed, heading = submarine.heading, time=time}
    torpedos[#torpedos + 1] = torpedo
    submarine.torpedoloading = 5
    if (submarine.type == "enemy") and level < 5 then
        submarine.torpedoloading = submarine.torpedoloading + (5 - level)
    end
    torpedoSound:play()
end

function drawMap()
    local scale = width/map:getWidth() * 3/4
    love.graphics.setColor(0.1, 0.3, 0.1) 
    love.graphics.rectangle("fill", width/8, height/8, 6*width/8, 3*height/4)
    love.graphics.setColor(0.1, 1.0, 0.1) 
    love.graphics.rectangle("line", width/8, height/8, 6*width/8, 3*height/4)
    love.graphics.draw(map, width/8, height/4, 0, scale)
    local target = targets[math.mod(level - 1, #targets) + 1]
    love.graphics.setFont(mainFont)
    love.graphics.printf("MISSION: "..target.name, 2*width/8, height/8+10, 4*width/8, "center")
    love.graphics.setFont(smallFont)
    love.graphics.printf("Search and destroy "..tostring(level).." vessels", 2*width/8, height/8+55, 4*width/8, "center")
    local pulse = (math.sin(time*5)/4 + 0.75) * 2
    local colorpulse = math.sin(time*20)/4 +0.75
    love.graphics.setColor(0.1, 1.0*colorpulse, 0.1) 
    love.graphics.setLineWidth(3)
    local posx = target.x * scale * map:getWidth()/1280 + width/8
    local posy = target.y * scale * map:getWidth()/1280 + height/4
    love.graphics.line(posx-10*pulse, posy, posx-18*pulse-10, posy)
    love.graphics.line(posx+10*pulse, posy, posx+18*pulse+10, posy)
    love.graphics.line(posx, posy+10*pulse, posx, posy+18*pulse + 10)
    love.graphics.line(posx, posy-10*pulse, posx, posy-18*pulse-10)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0.1, 1.0, 0.1) 
    love.graphics.printf("Press Enter to start", 3*width/8, 6.5*height/8, 2*width/8, "center")
end

gradient_shader = love.graphics.newShader([[
    extern number startpos = 0;
    vec4 effect ( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ) {
        vec4 pixel = Texel(texture, texture_coords );
        float factor = sin(startpos + 3*screen_coords.x/love_ScreenSize.x);
        return vec4(1.0, 0.1, 0.1, 0.15*factor);      
    }  
]])

function love.draw()
    -- love.graphics.printf("X", 10, 10, 100, "left")
    -- love.graphics.printf(math.floor(player.x*10)/10, 30, 10, 100, "left")
    -- love.graphics.printf("Y", 130, 10, 100, "left")
    -- love.graphics.printf(math.floor(player.y*10)/10, 160, 10, 100, "left")
    -- love.graphics.printf("X", 10, 40, 100, "left")
    -- love.graphics.printf(math.floor(enemy.x*10)/10, 30, 40, 100, "left")
    -- love.graphics.printf("Y", 130, 40, 100, "left")
    -- local enemydistance = math.sqrt((enemy.x - player.x)^2 + (enemy.y - player.x)^2)
    -- local enemyhitangle = math.deg(math.atan2(100, enemydistance))

    -- love.graphics.printf(math.floor(enemy.y*10)/10, 160, 40, 100, "left")
    -- enemyangle = math.deg(math.atan2(enemy.x - player.x, enemy.y - player.y))
    -- differential = math.mod(enemyangle - enemy.heading - 180, 360)
    -- love.graphics.printf("A", 10, 80, 100, "left")
    -- love.graphics.printf(math.floor(enemydistance*10)/10, 30, 80, 100, "left")
    -- love.graphics.printf("B", 130, 80, 100, "left")
    -- love.graphics.printf(math.floor(enemyhitangle*10)/10, 160, 80, 100, "left")
    -- love.graphics.printf("C", 260, 80, 100, "left")
    -- love.graphics.printf(math.floor(differential*10)/10, 290, 80, 100, "left")
    -- love.graphics.printf(math.floor(framerate*10)/10, 500, 10, 100, "left")
    love.graphics.printf("Score:", 5*width/6-30, 10, 150, "left")
    love.graphics.printf(score, 5*width/6 + 80, 10, 70, "right")
    love.graphics.printf("Remaining:", 5*width/6-30, 40, 150, "left")
    love.graphics.printf(level - kills, 5*width/6 + 80, 40, 70 , "right")
    drawControlPanel()
    drawSpeed(player.speed)
    drawThrust(player.thrust)
    drawDepth(depth)
    drawFloor(depth, floor)
    -- Rotated map
    drawStencil(player.heading)
        drawCompass(player.heading, player.x, player.y)
        drawGrid(player)
        drawSonar()
        -- drawTorpedo(player, enemies)
        -- for i, enemy in ipairs(enemies) do
        --     enemyTorpedo = drawTorpedo(enemy, {player})
        -- end
        enemyTorpedo = drawTorpedos(player, enemies)
        drawEnemies()
        drawExplosions()
    endStencil(player.heading)
    drawPlayer()
    if (player.dead and finalCountdown < 3) then
        love.graphics.setFont(mainFont)
        love.graphics.printf("Game Over", width/2 - 150, 1*height/3, 300, "center")
        love.graphics.setFont(smallFont)
        if (finalCountdown <= 0) then
            love.graphics.printf("Press Enter to start over", width/2 - 150, 1*height/3 + 50, 300, "center")
        end
    elseif #enemies == 0 and kills >= level and finalCountdown < 3 then
        love.graphics.setFont(mainFont)
        love.graphics.printf("Mission Completed", width/2 - 150, 1*height/3, 300, "center")
        love.graphics.setFont(smallFont)
    end
    if (showMap) then
        drawMap()
    end
    highscore.draw()
    if enemyTorpedo and #enemies > 0 then
        love.graphics.setColor(0.1, 0.3, 0.1) 
        gradient_shader:send("startpos",6*time)
        love.graphics.setShader(gradient_shader)
        love.graphics.rectangle("fill", 0, 0, width, height) 
        love.graphics.setShader()
        love.graphics.setColor(0.1, 1.0, 0.1) 
    end
end

function math.sign(x)
	return (x >= 0) and 1 or -1
end

function moveSubmarine(dt, submarine)    
    if (math.abs(submarine.speed) < math.abs(submarine.thrust)) then
        submarine.speed = submarine.speed + (submarine.thrust-submarine.speed) * dt * 0.15
    end
    if (math.abs(submarine.speed) > math.abs(submarine.thrust)) then
        submarine.speed = submarine.speed * (1 - 0.07 * dt)
    end

    submarine.x = submarine.x + math.sin(math.rad(submarine.heading)) * submarine.speed * dt * 5
    submarine.y = submarine.y + math.cos(math.rad(submarine.heading)) * submarine.speed * dt * 5
    submarine.heading = submarine.heading + (math.min(submarine.speed,15) + 2*math.sign(submarine.speed)) * submarine.rudder * dt * 1;

    if (submarine.torpedoloading > 0) then
        submarine.torpedoloading = submarine.torpedoloading - dt
    end
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
        player.rudder = player.rudder - dt * 0.4
        if (player.rudder < -1) then 
            player.rudder = -1
        end
    end
    if love.keyboard.isDown('left', 'a') and player.rudder < 1 then
        player.rudder = player.rudder + dt * 0.4
        if (player.rudder > 1) then 
            player.rudder = 1
        end
    end

end


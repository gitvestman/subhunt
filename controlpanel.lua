function drawControlPanel()
    displayRadius = math.min(0.4*height, 0.275*width)
    displayCenterX = width/2 + screenx
    displayCenterY = height - height/6 - displayRadius + screeny
    love.graphics.setFont(smallFont)
    love.graphics.setBackgroundColor(0.1, 0.2, 0.1) 
    world = love.physics.newWorld(0, 9.81*64, true)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0.05, 0.15, 0.05) 
    love.graphics.rectangle("fill", width/20 + screenx, height/6, 7*width/40, 4*height/6)
    love.graphics.setColor(0.0, 1.0, 0.0) 
    love.graphics.rectangle("line", width/20 + screenx, height/6, 7*width/40, 4*height/6)
    love.graphics.setColor(0.1, 0.3, 0.1) 
    love.graphics.rectangle("fill", width/20+1 + screenx, height/6 + 1.5 * lineheight, 7*width/40-2, 3*height/6+lineheight)
    love.graphics.setColor(0.1, 0.2, 0.1) 
    love.graphics.line(width/20 + 3.5*width/40 + screenx, height/6 + 1.5 * lineheight, width/20 + 3.5*width/40, 4*height/6 + 4.5 * lineheight)
    love.graphics.setColor(0.0, 1.0, 0.0) 
    love.graphics.print("Depth", width/20+10 + screenx, height/6 + lineheight/4, 0, 1)
    love.graphics.print("Floor", 5.5*width/40 + screenx, 5*height/6 - lineheight, 0, 1)
    love.graphics.setColor(0.05, 0.15, 0.05) 
    love.graphics.rectangle("fill", width - 9*width/40 + screenx, height/6, 7*width/40, 4*height/6)
    love.graphics.setColor(0.0, 1.0, 0.0) 
    love.graphics.rectangle("line", width - 9*width/40 + screenx, height/6, 7*width/40, 4*height/6)
    love.graphics.setColor(0.1, 0.3, 0.1) 
    love.graphics.rectangle("fill", width - 9*width/40 + 1 + screenx, height/6 + 1.5 * lineheight, 7*width/40 - 2, 3*height/6+lineheight)
    love.graphics.setColor(0.1, 0.2, 0.1) 
    love.graphics.line(34.5*width/40 + screenx, height/6 + 1.5 * lineheight, 34.5*width/40 + screenx, 4*height/6 + 4.5 * lineheight)
    love.graphics.setColor(0.0, 1.0, 0.0) 
    love.graphics.print("Speed", (width - 9*width/40) + 10 + screenx, height/6 + lineheight/4, 0, 1)
    love.graphics.print("Thrust", (width - 6*width/40) + 10 + screenx, 5*height/6 - lineheight, 0, 1)
    love.graphics.setFont(mainFont)
    local pulse = 1.0
    if level == 1 and time < 6 then 
        pulse = math.sin(time*9)/5 + 0.8
    end
    love.graphics.setColor(0.3, 1.0 * pulse, 0.3) 
    --love.graphics.setColor(0.5, 1.0, 0.5) 
    love.graphics.print("[F]", 38*width/40+4 + screenx, height/6 + 0.5*lineheight, 0, 1)
    love.graphics.print("[R]", 38*width/40+4 + screenx, 4*height/6 + 2*lineheight, 0, 1)
    love.graphics.setColor(0.1, 1.0, 0.1) 
    love.graphics.setFont(smallFont)
    love.graphics.line((width - 9*width/40) + 10 + screenx, height/2, (width - 9*width/40) + screenx, height/2)
    love.graphics.line(width/20 + screenx, height/2, width/20+10 + screenx, height/2)
    love.graphics.setColor(0.05, 0.15, 0.05) 
    love.graphics.rectangle("fill", 11*width/40 + screenx, lineheight - 2, width/8, lineheight * 2)
    love.graphics.setColor(0.0, 1.0, 0.0) 
    love.graphics.rectangle("line", 11*width/40 + screenx, lineheight - 2, width/8, lineheight * 2)
    love.graphics.printf("Sonar", 11*width/40 + screenx, lineheight * 1.4, width/8, "center")
    --love.graphics.print("Sonar", 10*width/40, height/6, 0, 1)
    love.graphics.setColor(0.05, 0.15, 0.05) 
    love.graphics.rectangle("fill", 24*width/40 + screenx, lineheight - 2, width/8, lineheight * 2)
    love.graphics.setColor(0.1, 1.0, 0.1) 
    if (player.torpedoloading > 0) then
        love.graphics.setColor(0.1, 1.0, 0.1, 0.4) 
        love.graphics.setLineWidth(lineheight*2)
        love.graphics.line(24*width/40 + width/48*(6 - player.torpedoloading) + screenx, lineheight * 2 - 2, 24*width/40 + width/8 + screenx, lineheight * 2 - 2)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(0.1, 0.7, 0.1) 
    end
    love.graphics.rectangle("line", 24*width/40 + screenx, lineheight - 2, width/8, lineheight * 2)
    love.graphics.printf("Torpedo", 24*width/40 + screenx, lineheight * 1.4, width/8, "center")
    --love.graphics.print("Torpedo", 24.5*width/40, height/6, 0, 1)
    love.graphics.setFont(mainFont)
    love.graphics.setColor(0.3, 1.0 * pulse, 0.3) 
    love.graphics.printf("[Left]", width/2 - 9*width/40 + screenx, 5*height/6 + lineheight, 4*width/40, "right")
    love.graphics.printf("[Right]", width/2 + 5*width/40 + screenx, 5*height/6 + lineheight, 4*width/40, "left")
    love.graphics.setColor(0.1, 1.0, 0.1) 
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0.1, 0.3, 0.1) 
    love.graphics.rectangle("fill", width/2 - 4*width/40 + screenx, 5*height/6 + lineheight, 8*width/40, 30)
    love.graphics.setColor(0.1, 0.2, 0.1) 
    love.graphics.line(width/2 + screenx, 5*height/6 + lineheight, width/2 + screenx, 5*height/6 + 70)
    love.graphics.setColor(0.1, 1.0, 0.1) 
    love.graphics.line(width/2 - player.rudder*5.5*height/40 + screenx, 5*height/6 + lineheight, width/2 - player.rudder*6*height/40 + screenx, 5*height/6 + 70)
    love.graphics.setColor(0.05, 0.1, 0.05) 
    love.graphics.circle("fill", displayCenterX, displayCenterY, displayRadius)
    love.graphics.setColor(0.0, 1.0, 0.0) 
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", displayCenterX, displayCenterY, displayRadius)
    love.graphics.setLineWidth(1)
    if showMap then
        love.graphics.setColor(0.05, 0.15, 0.05) 
        love.graphics.rectangle("fill", 10 + screenx, height - 5 * lineheight, 3*width/20, lineheight * 4)
        love.graphics.setColor(0.1, 1.0, 0.1) 
        love.graphics.rectangle("line", 10 + screenx, height - 5 * lineheight, 3*width/20, lineheight * 4)
        love.graphics.setFont(mainFont)
        love.graphics.printf("Ad\nConsent", 10 + 0.5*lineheight + screenx, height - 4.5 * lineheight, 2.5*width/20, "center")
    end
end

function drawSpeed(speed)
    drawMeter(speed, speed - 40, speed + 40, 5, (width - 9*width/40) + 15 + screenx, "left")
end

function drawThrust(thrust)
    xpos = 34.5*width/40 + screenx
    stealthy1 = math.max(height/6 + lineheight, (thrust - 6) * height/(8*5) + height/2)
    stealthy2 = math.min(5*height/6 - lineheight, (thrust + 6) * height/(8*5) + height/2)
    love.graphics.setColor(0.05, 0.15, 0.05) 
    love.graphics.rectangle("fill", xpos + 1, stealthy1 - 5, width/12 - 2, stealthy2 - stealthy1 + 5)
    love.graphics.setColor(0.1, 1.0, 0.1) 
    markings = { [15] = "full", [10] = "half", [5] = "stealth", [0] = "stop", [-5] = "stealth", [-10] = "half", [-15] = "full"}
    -- drawMeter(thrust, thrust - 40, thrust + 40, 5, (width - 6*width/40), "right")
    for i = math.floor((thrust - 40)/5)*5, math.floor((thrust + 40)/5)*5, 5 do
        y = (thrust - i) * height/(8*5) + height/2
        if y > height/6 + lineheight and y <  5*height/6 - lineheight then
            if (markings[i] ~= nil) then
                love.graphics.printf(markings[i], xpos, y-15, width/12, "center")
            end
        end
    end
end

function drawDepth(depth)
    drawMeter(depth, 1000, 0, -10, width/20 + 15 + screenx, "left")
end

function drawFloor(depth, floor)
    drawMeter(floor - depth, 0, 100, 10, 5.5*width/40 - 5 + screenx, "right")
end

function drawPlayer()
    if (player.dead) then
        love.graphics.line(displayCenterX-10, displayCenterY-10, displayCenterX+10, displayCenterY+10)
        love.graphics.line(displayCenterX-10, displayCenterY+10, displayCenterX+10, displayCenterY-10)
    else
        if (math.abs(player.thrust) > 6) then
            love.graphics.ellipse("fill", displayCenterX, displayCenterY, height/140, height/60)
            player.lastKnown = {x = player.x, y = player.y, speed = player.speed, heading = player.heading, time=time}
        else
            love.graphics.ellipse("line", displayCenterX, displayCenterY, height/140, height/60)
        end
    end
end

function drawMeter(value, min, max, step, xpos, align)
    for i = math.floor(min/step)*step, math.floor(max/step)*step, step do
        y = (value - i) * height/(8*step) + height/2
        if y > height/6 + 50 and y <  5*height/6 - 40 then
            love.graphics.printf(i, xpos, y-15, width/12, align)
        end
    end
end

local function myStencilFunction()
    love.graphics.circle("fill", displayCenterX, displayCenterY, displayRadius)
end

function drawStencil(rotation)
    love.graphics.stencil(myStencilFunction, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    love.graphics.translate(displayCenterX, displayCenterY)
    love.graphics.rotate(math.rad(rotation))
    love.graphics.translate(-displayCenterX, -displayCenterY)
end

function endStencil(rotation)
    love.graphics.translate(displayCenterX, displayCenterY)
    love.graphics.rotate(math.rad(-rotation))
    love.graphics.translate(-displayCenterX, -displayCenterY)
    love.graphics.setStencilTest()
end

function dashLine( p1, p2, dash, gap )
    local dy, dx = p2.y - p1.y, p2.x - p1.x
    local an, st = math.atan2( dy, dx ), dash + gap
    local len	 = math.sqrt( dx*dx + dy*dy )
    local nm	 = ( len - dash ) / st
    love.graphics.push()
        love.graphics.translate( p1.x, p1.y )
        love.graphics.rotate( an )
        for i = 0, nm do
          love.graphics.line( i * st, 0, i * st + dash, 0 )
        end
        love.graphics.line( nm * st, 0, nm * st + dash,0 )
    love.graphics.pop()
 end

function drawGrid(player)
    love.graphics.setColor(0.0, 0.5, 0.0) 
    local miny = math.floor((player.y + 2500)/1000)*1000
    local minx = math.floor((player.x + 2500)/1000)*1000
    local minyc = (player.y - miny) * displayScale + displayCenterY
    local minxc = (player.x - minx) * displayScale + displayCenterX
    for i = math.floor((player.y - 1500)/1000)*1000, math.floor((player.y+2000)/1000)*1000, 1000 do
        y = (player.y - i) * displayScale + height/2
        if y > displayCenterY - displayRadius and y <  displayCenterY + displayRadius then        
            dashLine({x=minxc, y=y}, {x=minxc + width, y=y}, 5, 5)
--            dashLine({x=width/2 - height/3, y=y}, {x=width/2 + height/3, y=y}, 10, 10)
        end
    end
    for i = math.floor((player.x - 1500)/1000)*1000, math.floor((player.x+2000)/1000)*1000, 1000 do
        x = (player.x - i) * displayScale + displayCenterX
        if x > displayCenterX - displayRadius and x <  displayCenterX + displayRadius then      
            dashLine({x=x, y=minyc}, {x=x, y=minyc + 1.2*height}, 5, 5)
        end
    end
    love.graphics.setColor(0.1, 1.0, 0.1) 
end

function drawCompass(rotation)
    -- love.graphics.translate(width/2, height/2)
    -- love.graphics.rotate(math.rad(rotation))
    -- love.graphics.translate(-width/2, -height/2)
    love.graphics.line(displayCenterX, displayCenterY - displayRadius, displayCenterX, displayCenterY - displayRadius+10)     
    love.graphics.line(displayCenterX, displayCenterY + displayRadius, displayCenterX, displayCenterY + displayRadius-10)     
    love.graphics.line(displayCenterX - displayRadius, displayCenterY, displayCenterX - displayRadius + 10, displayCenterY)     
    love.graphics.line(displayCenterX + displayRadius - 10, displayCenterY, displayCenterX + displayRadius, displayCenterY)     
    love.graphics.printf("N", displayCenterX - lineheight/4, displayCenterY - displayRadius + 10, 50, "left")
    love.graphics.printf("S", displayCenterX - lineheight/4, displayCenterY + displayRadius - lineheight - 10, 50, "left")
    love.graphics.printf("W", displayCenterX - displayRadius + 12, displayCenterY - lineheight/2, 50, "left")
    love.graphics.printf("E", displayCenterX + displayRadius - 0.5*lineheight - 10, displayCenterY - lineheight/2, 50, "left")
end

function drawSonar()
    if (sonar.active) then
        duration = time - sonar.time
        if (duration > 4) then
            sonar.active = false
            for i, enemy in ipairs(enemies) do
                if (enemy.dead) then 
                    return
                end
                local posx = (player.x - enemy.x) * displayScale + displayCenterX	
                local posy = (player.y - enemy.y) * displayScale + displayCenterY
                if checkOnDisplay(posx, posy) then
                    enemy.lastKnown = {x = enemy.x, y = enemy.y, speed = enemy.speed, heading = enemy.heading, time=time}
                end
            end
            player.lastKnown = {x = player.x, y = player.y, speed = player.speed, heading = player.heading, time=time}
        end
        love.graphics.setColor(0.0, 1.0, 0.0) 
        love.graphics.circle("line", displayCenterX, displayCenterY, math.fmod((time - sonar.time)/2, 1) * displayRadius)
    end
end

function drawExplosions()
    for i=1, #explosions do
        love.graphics.printf(math.floor(time - explosions[i].time*10)/10, 30, 80, 100, "left")
        if (time - explosions[i].time) < 2 then
            posx = (player.x - explosions[i].x) * displayScale + displayCenterX
            posy = (player.y - explosions[i].y) * displayScale + displayCenterY
            love.graphics.setColor(0.7, 0.3, 0.1) 
            love.graphics.circle("line", posx, posy, (time - explosions[i].time)*height/10)
            love.graphics.setColor(0.1, 1.0, 0.1) 
        end
    end
end

function createExplosion(x, y)
    explosionSound:play()
    explosion = {x = x, y = y, time = time}
    explosions[#explosions + 1] = explosion
end

function drawTorpedos()
    enemyTorpedo = false
    for i=#torpedos,1,-1 do
        --print("Torpedo:"..submarine.type..": "..tostring(torpedo.x)..":"..tostring(torpedo.speed))
        local torpedo = torpedos[i]
        if (time - torpedo.time > 15) then -- Torpedo time to live
            table.remove(torpedos, i)
        else
            calcx = torpedo.x + math.sin(math.rad(torpedo.heading)) * torpedo.speed * (time - torpedo.time) * 5
            calcy = torpedo.y + math.cos(math.rad(torpedo.heading)) * torpedo.speed * (time - torpedo.time) * 5
            local dx = calcx - player.x
            local dy = calcy - player.y
            if dx^2 + dy^2 < 3600 and torpedo.source ~= player then
                targetHit(torpedo, player, player.x, player.y, i)
            else 
                for j, target in ipairs(enemies) do                
                    local dx = calcx - target.x
                    local dy = calcy - target.y
                    if dx^2 + dy^2 < 3600 and torpedo.source ~= target then
                        targetHit(torpedo, target, target.x, target.y, i)
                    end
                end
            end
            for j=#torpedos,1,-1 do
                if j ~= i then
                    local torpedob = torpedos[j]
                    calcbx = torpedob.x + math.sin(math.rad(torpedob.heading)) * torpedob.speed * (time - torpedob.time) * 5
                    calcby = torpedob.y + math.cos(math.rad(torpedob.heading)) * torpedob.speed * (time - torpedob.time) * 5
                    local dx = calcx - calcbx
                    local dy = calcy - calcby
                    if dx^2 + dy^2 < 800 then    
                        torpedo.speed = 0
                        torpedob.speed = 0
                        torpedo.time = 99
                        torpedob.time = 99
                        createExplosion(calcx, calcy)
                    end
                end
            end

            posx = (player.x - calcx) * displayScale + displayCenterX
            posy = (player.y - calcy) * displayScale + displayCenterY

            if torpedo.speed > 0 and checkOnDisplay(posx, posy) then
                enemyTorpedo = enemyTorpedo or torpedo.source.type == "enemy"
                love.graphics.setColor(0.7, 0.3, 0.1) 
                love.graphics.circle("fill", posx, posy, height/150)
                love.graphics.setColor(0.1, 1.0, 0.1) 
            end
        end
    end
    return enemyTorpedo
end

function targetHit(torpedo, target, x, y, i)
    for j=1,#torpedos do
        print("Torpedo:"..tostring(j)..":"..torpedos[j].source.type)
    end
    print("Torpedo:"..torpedo.source.type..", Target:"..target.type..": "..#torpedos..";"..tostring(i))
    table.remove(torpedos, i)
    for j=1,#torpedos do
        print("Torpedo:"..tostring(j)..":"..torpedos[j].source.type)
    end
    torpedo.speed = 0
    createExplosion(x, y)
    target.dead = true
    finalCountdown = 5
    if (target.type == "enemy") then
        score = score + 50 + 10*level + math.ceil(5 * math.max(30 + level - time - target.time, 0))
        kills = kills + 1
        target.lastKnown = nil
    end
end

function drawDot(mode, x, y, r, h)
    posx = (player.x - x) * displayScale + displayCenterX
    posy = (player.y - y) * displayScale + displayCenterY
    if checkOnDisplay(posx, posy) then
        --love.graphics.circle(mode, posx, posy, r)
        love.graphics.translate(posx, posy)
        love.graphics.rotate(math.rad(180-h))
        love.graphics.translate(-posx, -posy)
        love.graphics.ellipse(mode, posx, posy, r/1.5, r)
        love.graphics.translate(posx, posy)
        love.graphics.rotate(-math.rad(180-h))
        love.graphics.translate(-posx, -posy)
    end
end

function drawEnemies()
    for i, enemy in ipairs(enemies) do
        if (enemy.dead) then
            return 
        end
        local pulse = math.sin(time*18)/4 + 0.75
        love.graphics.setColor(0.1, 1.0 * pulse, 0.1) 
        if enemy.thrust > 6 then

            drawDot("fill", enemy.x, enemy.y, height/100 * pulse/2 + height/90, enemy.heading)
            enemy.lastKnown = {x = enemy.x, y = enemy.y, speed = enemy.speed, heading = enemy.heading, time=time}

        elseif (enemy.lastKnown ~= nil) then   

            if (enemy.lastKnown.time - time > 15) then
                return
            end

            local pulse = math.cos((time-enemy.lastKnown.time)/30)/4 + 0.75
            love.graphics.setColor(0.1, 1.0 * pulse, 0.1) 
            drawDot("line", enemy.lastKnown.x, enemy.lastKnown.y, height/60, enemy.lastKnown.heading)

            calcx = enemy.lastKnown.x + math.sin(math.rad(enemy.lastKnown.heading)) * enemy.lastKnown.speed * (time - enemy.lastKnown.time) * 5
            calcy = enemy.lastKnown.y + math.cos(math.rad(enemy.lastKnown.heading)) * enemy.lastKnown.speed * (time - enemy.lastKnown.time) * 5

            pulse = math.cos((time-enemy.lastKnown.time)/15)/4 + 0.75
            love.graphics.setColor(0.1, 1.0 * pulse, 0.1) 
            drawDot("line", calcx, calcy, height/100 * pulse/2 + height/90, enemy.lastKnown.heading)

            cpx = (player.x - calcx) * displayScale + displayCenterX
            cpy = (player.y - calcy) * displayScale + displayCenterY       
            lpx = (player.x - enemy.lastKnown.x) * displayScale + displayCenterX
            lpy = (player.y - enemy.lastKnown.y) * displayScale + displayCenterY
            
            dashLine({x=lpx, y=lpy}, {x=cpx, y=cpy}, 10, 10)
        end
    end
    love.graphics.setColor(0.1, 1.0, 0.1) 
end

function checkOnDisplay(ax, ay)
    local dx = displayCenterX - ax
	local dy = displayCenterY - ay
	return dx^2 + dy^2 < ((displayRadius)^2)
end

function drawControlPanel()
    love.graphics.setFont(smallFont)
    love.graphics.setBackgroundColor(0.1, 0.2, 0.1) 
    world = love.physics.newWorld(0, 9.81*64, true)
    love.graphics.setColor(0.05, 0.1, 0.05) 
    love.graphics.circle("fill", width/2, height/2, height/3)
    love.graphics.setColor(0.0, 1.0, 0.0) 
    love.graphics.circle("line", width/2, height/2, height/3)
    love.graphics.rectangle("line", width/20, height/6, 7*width/40, 4*height/6)
    love.graphics.setColor(0.1, 0.3, 0.1) 
    love.graphics.rectangle("fill", width/20+1, height/6 + 1.5 * lineheight, 7*width/40-2, 3*height/6+lineheight)
    love.graphics.setColor(0.1, 0.2, 0.1) 
    love.graphics.line(width/20 + 3.5*width/40, height/6 + 1.5 * lineheight, width/20 + 3.5*width/40, 4*height/6 + 4.5 * lineheight)
    love.graphics.setColor(0.0, 1.0, 0.0) 
    love.graphics.print("Depth", width/20+10, height/6 + lineheight/4, 0, 1)
    love.graphics.print("Floor", 5.5*width/40, 5*height/6 - lineheight, 0, 1)
    love.graphics.rectangle("line", width - 9*width/40, height/6, 7*width/40, 4*height/6)
    love.graphics.setColor(0.1, 0.3, 0.1) 
    love.graphics.rectangle("fill", width - 9*width/40 + 1, height/6 + 1.5 * lineheight, 7*width/40 - 2, 3*height/6+lineheight)
    love.graphics.setColor(0.1, 0.2, 0.1) 
    love.graphics.line(43.5*width/40 - 9*width/40, height/6 + 1.5 * lineheight, 43.5*width/40 - 9*width/40, 4*height/6 + 4.5 * lineheight)
    love.graphics.setColor(0.0, 1.0, 0.0) 
    love.graphics.print("Speed", (width - 9*width/40) + 10, height/6 + lineheight/4, 0, 1)
    love.graphics.print("Thrust", (width - 6*width/40) + 10, 5*height/6 - lineheight, 0, 1)
    love.graphics.print("[F]", 38*width/40+4, height/6 + lineheight, 0, 1)
    love.graphics.print("[R]", 38*width/40+4, 4*height/6 + 1.5*lineheight, 0, 1)
    love.graphics.line((width - 9*width/40) + 10, height/2, (width - 9*width/40), height/2)
    love.graphics.line(width/20, height/2, width/20+10, height/2)
    love.graphics.rectangle("line", 10*width/40, height/6 - 1, lineheight*5, lineheight + 2)
    love.graphics.printf("Sonar", 10*width/40, height/6, lineheight*5, "center")
    --love.graphics.print("Sonar", 10*width/40, height/6, 0, 1)
    if (player.torpedoloading > 0) then
        love.graphics.setColor(0.1, 1.0, 0.1) 
        love.graphics.setLineWidth(2)
        love.graphics.line(25*width/40, height/6 + 30, 24.5*width/40 + width/50*(6 - player.torpedoloading), height/6 + 30)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(0.1, 0.7, 0.1) 
    end
    love.graphics.rectangle("line", 25*width/40, height/6 - 1, lineheight*5, lineheight + 2)
    love.graphics.printf("Torpedo", 25*width/40, height/6, lineheight*5, "center")
    --love.graphics.print("Torpedo", 24.5*width/40, height/6, 0, 1)
    love.graphics.setColor(0.1, 1.0, 0.1) 
    love.graphics.print("[L]", 14*width/40, 5*height/6 + lineheight, 0, 1)
    love.graphics.print("[R]", 24*width/40+15, 5*height/6 + lineheight, 0, 1)
    love.graphics.setColor(0.1, 0.3, 0.1) 
    love.graphics.rectangle("fill", width/2 - 4*width/40, 5*height/6 + lineheight, 8*width/40, 30)
    love.graphics.setColor(0.1, 0.2, 0.1) 
    love.graphics.line(width/2, 5*height/6 + lineheight, width/2, 5*height/6 + 70)
    love.graphics.setColor(0.1, 1.0, 0.1) 
    love.graphics.line(width/2 - player.rudder*5.4*height/40, 5*height/6 + lineheight, width/2 - player.rudder*5.4*height/40, 5*height/6 + 70)
end

function drawSpeed(speed)
    drawMeter(speed, speed - 40, speed + 40, 5, (width - 9*width/40) + 15, "left")
end

function drawThrust(thrust)
    drawMeter(thrust, thrust - 40, thrust + 40, 5, (width - 6*width/40), "right")
end

function drawDepth(depth)
    drawMeter(depth, 1000, 0, -10, width/20 + 15, "left")
end

function drawFloor(depth, floor)
    drawMeter(floor - depth, 0, 100, 10, 5.5*width/40 - 5, "right")
end

function drawPlayer()
    if (player.dead) then
        love.graphics.line(width/2-10, height/2-10, width/2+10, height/2+10)
        love.graphics.line(width/2-10, height/2+10, width/2+10, height/2-10)
    else
        if (math.abs(player.thrust) > 6) then
            love.graphics.ellipse("fill", width/2, height/2, height/150, height/70)
            player.lastKnown = {x = player.x, y = player.y, speed = player.speed, heading = player.heading, time=time}
        else
            love.graphics.ellipse("line", width/2, height/2, height/150, height/70)
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
    love.graphics.circle("fill", width/2, height/2, height/3)
end

function drawStencil(rotation)
    love.graphics.stencil(myStencilFunction, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
    love.graphics.translate(width/2, height/2)
    love.graphics.rotate(math.rad(rotation))
    love.graphics.translate(-width/2, -height/2)
end

function endStencil(rotation)
    love.graphics.translate(width/2, height/2)
    love.graphics.rotate(math.rad(-rotation))
    love.graphics.translate(-width/2, -height/2)
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
    local minyc = (player.y - miny) * displayScale + height/2
    local minxc = (player.x - minx) * displayScale + width/2
    for i = math.floor((player.y - 1500)/1000)*1000, math.floor((player.y+1500)/1000)*1000, 1000 do
        y = (player.y - i) * displayScale + height/2
        if y > height/6 and y <  5*height/6 then            
            dashLine({x=minxc, y=y}, {x=minxc + 4*height/3, y=y}, 5, 5)
--            dashLine({x=width/2 - height/3, y=y}, {x=width/2 + height/3, y=y}, 10, 10)
        end
    end
    for i = math.floor((player.x - 1500)/1000)*1000, math.floor((player.x+1500)/1000)*1000, 1000 do
        x = (player.x - i) * displayScale + width/2
        if x > width/6 and x <  5*width/6 then            
            dashLine({x=x, y=minyc}, {x=x, y=minyc + height}, 5, 5)
        end
    end
    love.graphics.setColor(0.1, 1.0, 0.1) 
end

function drawCompass(rotation)
    -- love.graphics.translate(width/2, height/2)
    -- love.graphics.rotate(math.rad(rotation))
    -- love.graphics.translate(-width/2, -height/2)
    love.graphics.line(width/2, height/6, width/2, height/6+10)     
    love.graphics.line(width/2, 5*height/6, width/2, 5*height/6-10)     
    love.graphics.line(width/2 - height/3, height/2, width/2 - height/3 + 10, height/2)     
    love.graphics.line(width/2 + height/3 - 10, height/2, width/2 + height/3, height/2)     
    love.graphics.printf("N", width/2 - lineheight/4, height/6 + 10, 50, "left")
    love.graphics.printf("S", width/2 - lineheight/4, 5*height/6 - lineheight - 10, 50, "left")
    love.graphics.printf("W", width/2 - height/3 + 12, height/2 - lineheight/2, 50, "left")
    love.graphics.printf("E", width/2 + height/3 - 0.5*lineheight - 10, height/2 - lineheight/2, 50, "left")
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
                local posx = (player.x - enemy.x) * displayScale + width/2	
                local posy = (player.y - enemy.y) * displayScale + height/2
                if checkOnDisplay(posx, posy) then
                    enemy.lastKnown = {x = enemy.x, y = enemy.y, speed = enemy.speed, heading = enemy.heading, time=time}
                end
            end
            player.lastKnown = {x = player.x, y = player.y, speed = player.speed, heading = player.heading, time=time}
        end
        love.graphics.setColor(0.0, 1.0, 0.0) 
        love.graphics.circle("line", width/2, height/2, math.fmod((time - sonar.time)/2, 1) * height/3)
    end
end

function drawExplosions()
    for i=1, #explosions do
        love.graphics.printf(math.floor(time - explosions[i].time*10)/10, 30, 80, 100, "left")
        if (time - explosions[i].time) < 2 then
            posx = (player.x - explosions[i].x) * displayScale + width/2
            posy = (player.y - explosions[i].y) * displayScale + height/2
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
        if (time - torpedo.time > 10) then
            table.remove(torpedos, i)
        else
            calcx = torpedo.x + math.sin(math.rad(torpedo.heading)) * torpedo.speed * (time - torpedo.time) * 5
            calcy = torpedo.y + math.cos(math.rad(torpedo.heading)) * torpedo.speed * (time - torpedo.time) * 5
            local dx = calcx - player.x
            local dy = calcy - player.y
            if dx^2 + dy^2 < 3600 and torpedo.source ~= player then
                targetHit(player, calcx, calcy, i)
            else 
                for i, target in ipairs(enemies) do                
                    local dx = calcx - target.x
                    local dy = calcy - target.y
                    if dx^2 + dy^2 < 3600 and torpedo.source ~= target then
                        targetHit(target, calcx, calcy, i)
                    end
                end
            end

            posx = (player.x - calcx) * displayScale + width/2
            posy = (player.y - calcy) * displayScale + height/2

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

function targetHit(target, x, y, i)
    --print("Torpedo:"..torpedo.source.type..", Target:"..target.type..": "..tostring(torpedo.x)..":"..tostring(torpedo.speed))
    table.remove(torpedos, i)
    torpedo.speed = 0
    createExplosion(x, y)
    target.dead = true
    finalCountdown = 5
    if (target.type == "enemy") then
        score = score + 50 + 10*level + math.ceil(5 * math.max(30 - time - target.time, 0))
        kills = kills + 1
        target.lastKnown = nil
    end
end

function drawDot(mode, x, y, r, h)
    posx = (player.x - x) * displayScale + width/2
    posy = (player.y - y) * displayScale + height/2
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
            drawDot("line", enemy.lastKnown.x, enemy.lastKnown.y, height/70, enemy.lastKnown.heading)

            calcx = enemy.lastKnown.x + math.sin(math.rad(enemy.lastKnown.heading)) * enemy.lastKnown.speed * (time - enemy.lastKnown.time) * 5
            calcy = enemy.lastKnown.y + math.cos(math.rad(enemy.lastKnown.heading)) * enemy.lastKnown.speed * (time - enemy.lastKnown.time) * 5

            pulse = math.cos((time-enemy.lastKnown.time)/15)/4 + 0.75
            love.graphics.setColor(0.1, 1.0 * pulse, 0.1) 
            drawDot("line", calcx, calcy, height/100 * pulse/2 + height/90, enemy.lastKnown.heading)

            cpx = (player.x - calcx) * displayScale + width/2
            cpy = (player.y - calcy) * displayScale + height/2        
            lpx = (player.x - enemy.lastKnown.x) * displayScale + width/2
            lpy = (player.y - enemy.lastKnown.y) * displayScale + height/2
            
            dashLine({x=lpx, y=lpy}, {x=cpx, y=cpy}, 10, 10)
        end
    end
    love.graphics.setColor(0.1, 1.0, 0.1) 
end

function checkOnDisplay(ax, ay)
    local dx = width/2 - ax
	local dy = height/2 - ay
	return dx^2 + dy^2 < ((height/3)^2)
end

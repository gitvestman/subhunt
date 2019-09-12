function drawControlPanel()
    love.graphics.setFont(smallFont)
    love.graphics.setBackgroundColor(0.1, 0.2, 0.1) 
    world = love.physics.newWorld(0, 9.81*64, true)
    love.graphics.setColor(0.0, 1.0, 0.0) 
    love.graphics.circle("line", width/2, height/2, height/3)
    love.graphics.rectangle("line", width/20, height/6, 7*width/40, 4*height/6)
    love.graphics.print("Depth", width/20+10, height/6+10, 0, 1)
    love.graphics.print("Floor", 5*width/40+10, 5*height/6-35, 0, 1)
    love.graphics.rectangle("line", width - 9*width/40, height/6, 7*width/40, 4*height/6)
    love.graphics.print("Speed", (width - 9*width/40) + 10, height/6+10, 0, 1)
    love.graphics.print("Thrust", (width - 7*width/40) + 10, 5*height/6-35, 0, 1)
    love.graphics.line((width - 9*width/40) + 10, height/2, (width - 9*width/40), height/2)
    love.graphics.line(width/20, height/2, width/20+10, height/2)
    love.graphics.print("Sonar [Q]", 10*width/40, 5*height/6 + 10, 0, 1)
    love.graphics.print("Torpedo [E]", 23*width/40, 5*height/6 + 10, 0, 1)
end

function drawSpeed(speed)
    drawMeter(speed, speed - 40, speed + 40, 5, (width - 9*width/40) + 15, "left")
end

function drawThrust(thrust)
    drawMeter(thrust, thrust - 40, thrust + 40, 5, (width - 7*width/40) - 15, "right")
end

function drawDepth(depth)
    drawMeter(depth, 1000, 0, -10, width/20 + 15, "left")
end

function drawFloor(depth, floor)
    drawMeter(floor - depth, 0, 100, 10, 4*width/40 - 10 , "right")
end

function drawPlayer()
    love.graphics.circle("fill", width/2, height/2, height/80)
end

function drawMeter(value, min, max, step, xpos, align)
    for i = math.floor(min/step)*step, math.floor(max/step)*step, step do
        y = (value - i) * height/(8*step) + height/2
        if y > height/6 + 50 and y <  5*height/6 - 40 then
            love.graphics.printf(i, xpos, y-15, 100, align)
        end
    end
end

local function myStencilFunction()
    love.graphics.circle("fill", width/2, height/2, height/3)
end

function drawStencil()
    love.graphics.setColor(0.0, 0.5, 0.0) 
    love.graphics.stencil(myStencilFunction, "replace", 1)
    love.graphics.setStencilTest("greater", 0)
end

function endStencil()
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
    local miny = math.floor((player.y + 2000)/1000)*1000
    local minx = math.floor((player.x + 2500)/1000)*1000
    local minyc = (player.y - miny) * height/(8*500) + height/2
    local minxc = (player.x - minx) * height/(8*500) + width/2
    for i = math.floor((player.y - 1500)/1000)*1000, math.floor((player.y+1500)/1000)*1000, 1000 do
        y = (player.y - i) * height/(8*500) + height/2
        if y > height/6 and y <  5*height/6 then            
            dashLine({x=minxc, y=y}, {x=minxc + 4*height/3, y=y}, 5, 5)
--            dashLine({x=width/2 - height/3, y=y}, {x=width/2 + height/3, y=y}, 10, 10)
        end
    end
    for i = math.floor((player.x - 1500)/1000)*1000, math.floor((player.x+1500)/1000)*1000, 1000 do
        x = (player.x - i) * height/(8*500) + width/2
        if x > width/6 and x <  5*width/6 then            
            dashLine({x=x, y=minyc}, {x=x, y=minyc + height}, 5, 5)
        end
    end
end

function drawCompass(rotation)
    love.graphics.translate(width/2, height/2)
    love.graphics.rotate(rotation)
    love.graphics.translate(-width/2, -height/2)
    love.graphics.line(width/2, height/6, width/2, height/6+10)     
    love.graphics.line(width/2, 5*height/6, width/2, 5*height/6-10)     
    love.graphics.line(width/2 - height/3, height/2, width/2 - height/3 + 10, height/2)     
    love.graphics.line(width/2 + height/3 - 10, height/2, width/2 + height/3, height/2)     
    love.graphics.printf("N", width/2 - 8, height/6 + 10, 50, "left")
    love.graphics.printf("S", width/2 - 8, 5*height/6 - 35, 50, "left")
    love.graphics.printf("W", width/2 - height/3 + 12, height/2 - 12, 50, "left")
    love.graphics.printf("E", width/2 + height/3 - 30, height/2 - 12, 50, "left")
end

function drawSonar(enemy, player)
    if (sonar.active) then
        duration = time - sonar.time
        if (duration > 4) then
            sonar.active = false
            if (enemy.dead) then 
                return
            end
            posx = (player.x - enemy.x)/10 + width/2
            posy = (player.y - enemy.y)/10 + height/2
            if checkOnDisplay(posx, posy) then
                lastKnownEnemySighting = {x = enemy.x, y = enemy.y, speed = enemy.speed, heading = enemy.heading, time=time}
            end
        end
        love.graphics.setColor(0.0, 1.0, 0.0) 
        love.graphics.circle("line", width/2, height/2, math.fmod((time - sonar.time)/2, 1) * height/3)
    end
end

function drawTorpedo(enemy, player)
    if (torpedo.active) then
        duration = time - torpedo.time
        if (duration > 10) then
            torpedo.active = false
        end
        if (torpedo.exploding) then
            if time - torpedo.explodingTime < 2 then
                love.graphics.circle("line", torpedo.x, torpedo.y, (time - torpedo.explodingTime)*height/10)
            else
                torpedo.active = false
            end
            return
        end
        calcx = torpedo.x + math.sin(torpedo.heading) * torpedo.speed * (time - torpedo.time) * 5
        calcy = torpedo.y + math.cos(torpedo.heading) * torpedo.speed * (time - torpedo.time) * 5
        posx = (player.x - calcx)/10 + width/2
        posy = (player.y - calcy)/10 + height/2
        local dx = calcx - enemy.x
        local dy = calcy - enemy.y
        if dx^2 + dy^2 < 40000 then
            explosionSound:play()
            torpedo.exploding = true
            torpedo.explodingTime = time
            torpedo.x = posx
            torpedo.y = posy
            torpedo.speed = 0
            enemy.dead = true
            lastKnownEnemySighting = nil
        end
        if checkOnDisplay(posx, posy) then
            love.graphics.setColor(1.0, 0.1, 0.1) 
            love.graphics.circle("fill", posx, posy, height/150)
        else 
            torpedo.active = false
        end
    end
end

function drawEnemy()
    posx = (player.x - enemy.x)/10 + width/2
    posy = (player.y - enemy.y)/10 + height/2
    if checkOnDisplay(posx, posy) and enemy.speed > 6 then

        local pulse = math.sin(time*18)/4 + 0.75
        love.graphics.setColor(0.1, 1.0 * pulse, 0.1) 
        love.graphics.circle("fill", posx, posy, height/100 * pulse/2 + height/120)
        lastKnownEnemySighting = {x = enemy.x, y = enemy.y, speed = enemy.speed, heading = enemy.heading, time=time}

    elseif (lastKnownEnemySighting ~= nil) then    
        if (lastKnownEnemySighting.time - time > 15) then
            return
        end

        lpx = (player.x - lastKnownEnemySighting.x)/10 + width/2
        lpy = (player.y - lastKnownEnemySighting.y)/10 + height/2
        if checkOnDisplay(lpx, lpy) then
            local pulse = math.cos((time-lastKnownEnemySighting.time)/30)/2 + 0.5
            love.graphics.setColor(0.1, 1.0 * pulse, 0.1) 
            love.graphics.circle("line", lpx, lpy, height/100 * pulse/2 + height/120)
        end
        calcx = lastKnownEnemySighting.x + math.sin(lastKnownEnemySighting.heading) * lastKnownEnemySighting.speed * (time - lastKnownEnemySighting.time) * 5
        calcy = lastKnownEnemySighting.y + math.cos(lastKnownEnemySighting.heading) * lastKnownEnemySighting.speed * (time - lastKnownEnemySighting.time) * 5
        cpx = (player.x - calcx)/10 + width/2
        cpy = (player.y - calcy)/10 + height/2
        if checkOnDisplay(cpx, cpy) then
            local pulse = math.cos((time-lastKnownEnemySighting.time)/15)/2 + 0.5
            love.graphics.setColor(0.1, 1.0 * pulse, 0.1) 
            love.graphics.circle("line", cpx, cpy, height/100 * pulse/2 + height/120)
        end
        dashLine({x=lpx, y=lpy}, {x=cpx, y=cpy}, 10, 10)
    end
    love.graphics.setColor(0.1, 1.0, 0.1) 
end

function checkOnDisplay(ax, ay)
    local dx = width/2 - ax
	local dy = height/2 - ay
	return dx^2 + dy^2 < ((height/3)^2)
end

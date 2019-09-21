require "TextInput"
local json = require "json"
local socket = require("socket")
local http = require("socket.http")
local ltn12 = require 'ltn12'

multiplayer = {}

function multiplayer.ping()
    b, c, h = http.request {
        url = "https://sqit.azurewebsites.net/ping",
        headers = {["Content-Type"] = "application/json"}
    }
    if (c == 200) then 
        return true
    end
    return false
end

function multiplayer.join()
    local response_body
    local request_body = json.encode(
        {   Name = player.name,
            PositionX = tostring(player.x),
            PositionY = tostring(player.y),
            PositionZ = math.floor(player.heading) * 1000 + math.floor(player.speed) * 10 + player.rudder
            -- Speed = tostring(player.speed),
            -- Heading = tostring(player.heading),
            -- Rudder = tostring(player.rudder) 
        }) 
            
    local response_body = http.request ("http://sqit.azurewebsites.net/join",request_body)

    updateEnemies(response_body)

end

function multiplayer.update()
    local response_body
    local request_body = json.encode(
        {   ID = tostring(myID),
            Name = player.name,
            PositionX = tostring(player.x),
            PositionY = tostring(player.y),
            PositionZ = math.floor(player.heading) * 1000 + math.floor(player.speed) * 10 + player.rudder
            -- Speed = tostring(player.speed),
            -- Heading = tostring(player.heading),
            -- Rudder = tostring(player.rudder) 
        }) 
    response_body = http.request ("http://sqit.azurewebsites.net/update",request_body)

    local response = json.decode(response_body)
    for i, v in ipairs(response.Players) do
        if v.ID ~= myID and v.ID ~= "" then
            -- check enemies, move or create
            print("enemyID:"..v.ID)
            break
        end
    end
end

function multiplayer.asyncupdate()
    local response_body
    local request_body = json.encode(
        {   ID = tostring(myID),
            Name = player.name,
            PositionX = tostring(player.x),
            PositionY = tostring(player.y),
            PositionZ = math.floor(player.heading) * 1000 + math.floor(player.speed) * 10 + player.rudder
            -- Speed = tostring(player.speed),
            -- Heading = tostring(player.heading),
            -- Rudder = tostring(player.rudder) 
        }) 
            
    --post("sqit.azurewebsites.net", "/update", request_body)
    download("sqit.azurewebsites.net", "/update", request_body)
end

function download(host, file, data)
    port = 80
    print (host, file, port)    
    local connectStatus, myConnection = pcall (socket.connect,host,port)
    if (connectStatus) then
        myConnection:settimeout(0.01) -- do not block you can play with this value
        local count = 0 -- counts number of bytes read
        -- May be easier to do this LuaSocket's HTTP functions
        myConnection:send("POST " .. file .. " HTTP/1.0\r\n"..
        "Accept: application/json\r\n"..
        "Content-Type: application/json\r\n"..
        "Content-Length: "..#data.."\r\n"..
        "Host: "..host.."\r\n\r\n"..
        data)
        result = ""
        local lastStatus = nil
        while true do
            local buffer, status, overflow = receive(myConnection, lastStatus)
            -- If buffer is not null the call was a success (changed in LuaSocket 2.0)
            if (buffer ~= nil) then
                 --io.write("+")
                 --io.flush()
                 count = count + string.len(buffer)
                 result = result..buffer
            else
                --print ("\n\"" .. status .. "\" with " .. string.len(overflow) .. " bytes of " .. file)
                --io.flush()
                count = count + string.len(overflow)
                result = result..overflow
            end
            if status == "closed" then break end
                lastStatus=status
            end
        myConnection:close()
        local bodystart = string.find(result, "{")
        body = string.sub(result, bodystart, -1 )
        updateEnemies(body)
    else
        print("Connection failed with error : " .. myConnection)
        io.flush()
    end
end

function updateEnemies(response_body)
    print("updateEnemies")
    --print(response_body)
    local response = json.decode(response_body)
    for i, v in ipairs(response.Players) do
        --print(i.." '"..v.ID.."' "..v.Name)
        if v.ID ~= myID and v.ID ~= "" then
            if (v.Name == player.name) then
                myID = v.ID
                print("myID:"..myID)
            else
                print("enemyID:"..v.ID)
                existingEnemy = false
                for j, enemy in ipairs(enemies) do
                    if (enemy.ID == v.ID) then
                        print("Existing enemy "..v.ID)
                        enemy.x = tonumber(v.PositionX)
                        enemy.y = tonumber(v.PositionY)
                        if (v.PositionZ ~= "") then
                            enemy.heading = math.floor(tonumber(v.PositionZ)/1000)
                            enemy.speed = math.floor((tonumber(v.PositionZ) - enemy.heading*1000)/10)
                            enemy.rudder = tonumber(v.PositionZ) - enemy.speed * 10 - enemy.heading * 1000
                        end
                        existingEnemy = true
                        break
                    end
                end
                if existingEnemy ~= true then
                    print("New enemy "..v.ID)
                    enemy = {x = tonumber(v.PositionX), y = tonumber(v.PositionY), 
                    speed = 10, thrust = 10, heading = 0, rudder = 0, dead = false, strategy = 1, 
                    torpedoloading = 0, time = time, type = "enemy", name = v.Name, ID = v.ID}
                    if (v.PositionZ ~= "") then
                        enemy.heading = math.floor(tonumber(v.PositionZ)/1000)
                        enemy.speed = math.floor((tonumber(v.PositionZ) - enemy.heading*1000)/10)
                        enemy.rudder = tonumber(v.PositionZ) - enemy.speed * 10 - enemy.heading * 1000
                    end
                    enemies[#enemies + 1] = enemy
                end
                local enemyjson = json.encode(enemy)
                print(enemyjson)
            end
        end
    end

end

threads = {} -- list of all live threads

function post (host, url, data)
    -- create coroutine
    local co = coroutine.create(
        function ()
            download(host, url, data)
        end)
    -- insert it in the 
    table.insert(threads, co)
end

function receive (myConnection, status)
    if status == "timeout" then
--        print (myConnection, "Yielding to dispatcher")
        io.flush()
        coroutine.yield(myConnection)
    end
    return myConnection:receive(1024)
end

function dispatcher ()
    while true do
        local n = table.getn(threads)
        if n == 0 then break end -- no more threads to run
        local connections = {}
        for i=1,n do
--            print (threads[i], "Resuming")
            io.flush()
            local status, res = coroutine.resume(threads[i])
            if not res then -- thread finished its task?
                table.remove(threads, i)
                break
            else -- timeout
                table.insert(connections, res)
            end
        end
        if table.getn(connections) == n then
            socket.select(connections)
        end
    end
end

-- host = "www.w3.org"
-- get(host, "/TR/html401/html40.txt")
-- get(host,"/TR/2002/REC-xhtml1-20020801/xhtml1.pdf")
-- get(host,"/TR/REC-html32.html")
-- get(host,"/TR/2000/REC-DOM-Level-2-Core-20001113/DOM2-Core.txt")
-- dispatcher()
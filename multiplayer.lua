require "TextInput"
local json = require "json"
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
        {   Name = "Peter",
            PositionX = tostring(player.x),
            PositionY = tostring(player.y),
            Speed = tostring(player.speed),
            Heading = tostring(player.heading),
            Rudder = tostring(player.rudder) 
        }) 
    -- print("Json:"..request_body)
            
    local response_body = http.request ("https://sqit.azurewebsites.net/join",request_body)

    -- if type(response_body) == "table" then
    --     print("Size:"..#response_body)
    --     print(json.encode(response_body))
    -- elseif (response_body == nil) then
    --     print("nil")
    -- else 
    --     print("Response:"..response_body)
    -- end
    local response = json.decode(response_body)
    for i, v in ipairs(response.Players) do
        if (v.Name == "Peter") then
            myID = v.ID
            print("myID:"..myID)
            break
        end
    end

end

function multiplayer.update()
    local response_body
    local request_body = json.encode(
        {   ID = tostring(myID),
            Name = "Peter",
            PositionX = tostring(player.x),
            PositionY = tostring(player.y),
            Speed = tostring(player.speed),
            Heading = tostring(player.heading),
            Rudder = tostring(player.rudder) 
        }) 
    print("Json:"..request_body)
            
    response_body = http.request ("https://sqit.azurewebsites.net/update",request_body)

    local response = json.decode(response_body)
    for i, v in ipairs(response.Players) do
        if v.ID ~= myID and v.ID ~= "" then
            -- check enemies, move or create
            print("enemyID:"..v.ID)
            break
        end
    end
end
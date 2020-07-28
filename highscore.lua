require 'lib.middleclass'
require 'TextInput'
http = require("socket.http")

highscore = {}
offline = false
playername = ""
playerRank = -1
highscorescroll = 0
highscorescrollspeed = 0

ranks = {"Lieutenant", "Commander", "Captain", "Admiral"}

function highscore.load()
    HighScores = {};
    getHighScores();
    -- input
    highscorestate = "none"

    textbox = TextInput(
        love.graphics.getWidth()/2 - 200,
        love.graphics.getHeight()/2 - 150,
        11,
        400,
        function ()
            highscorestate = "done"
            love.keyboard.setTextInput( false )
        end
    )
end

function highscore.update(dt)
    if highscorestate == "input" then
        textbox:step(dt)
        return true
    elseif highscorestate == "done" then
        playername = textbox.text 
        table.insert(HighScores, {playername, score})
        table.sort(HighScores, scoresort)
        highscorestate = "highscores"
        restarttime = time
        sendHighScore(playername, score)
        getHighScores()
        return true
    elseif highscorestate == "highscores" then
        if (time - restarttime > 10.0) then            
            love.load()
        end
        if love.keyboard.isDown("up", "w") then
             highscorescroll = highscorescroll + 1
        end
        if love.keyboard.isDown("down", "s") then
             highscorescroll = highscorescroll - 1
        end
        if (math.abs(highscorescrollspeed) > 0.1) then
            highscorescroll = highscorescroll + highscorescrollspeed
            highscorescrollspeed = highscorescrollspeed * 0.8
        end
        return true
    end
    return false
end

local function highscoreStencilFunction()
   love.graphics.rectangle("fill", width/4 + 2 , height/4 + lineheight * 2 + 10, width/2 - 4, 12*lineheight - 2)
end


function highscore.draw()
    if (#HighScores) > 1 then
        love.graphics.print("Top Dog:", 10, 10, 0, 1)
        love.graphics.print(getRank(HighScores[1][2]).." "..HighScores[1][1]..": "..HighScores[1][2], 10, lineheight + 15, 0, 1)
    else
        love.graphics.print("Offline", 10, 10, 0, 1)
    end

    if highscorestate == "input" then
        textbox:draw(getRank(score))
    elseif highscorestate == "highscores" then
        love.graphics.setColor(0.05, 0.1, 0.05, 0.9) 
        love.graphics.rectangle("fill", width/4 , height/4, width/2, 15*lineheight) 
        love.graphics.setColor(0.1, 1.0, 0.1) 
        love.graphics.rectangle("line", width/4 , height/4, width/2, 15*lineheight) 
        texty = height/4 + lineheight
        love.graphics.setFont(mainFont)
        love.graphics.printf("Hall of fame", width/4 + lineheight, texty - 2 ,300)
        love.graphics.stencil(highscoreStencilFunction, "replace", 1)
        love.graphics.setStencilTest("greater", 0)
        love.graphics.setFont(smallFont)
        texty = texty + lineheight + 10
        if (playerRank > 11) then
            texty = texty - (playerRank - 11) * lineheight
        end
        texty = texty - highscorescroll
        if (texty > height/4 + lineheight*2 + 10) then
            texty = height/4 + lineheight*2 + 10
        end
        if (texty < height/4 - lineheight*88 + 10) then
            texty = height/4 - lineheight*88 + 10
        end
        for i,v in ipairs(HighScores) do 
            if i < 100 then
                if (i == playerRank) then
                    local pulse = math.sin(time*18)/4 + 0.75
                    love.graphics.setColor(0.3, 1.0 * pulse, 0.3) 
                    love.graphics.printf(i..": "..getRank(v[2]).." "..v[1], width/4 + lineheight, texty ,350)
                    love.graphics.printf(v[2], width/2 + 4 * lineheight, texty ,300)
                else
                    love.graphics.setColor(0.1, 1.0, 0.1) 
                    love.graphics.printf(i..": "..getRank(v[2]).." "..v[1], width/4 + lineheight, texty ,350)
                    love.graphics.printf(v[2], width/2 + 4 * lineheight, texty ,300)
                end
                texty = texty + lineheight
            else
                HighScores[i] = nil
            end
        end
        love.graphics.setStencilTest()
    end
end

function getRank(score)
    return ranks[math.min(math.floor((score^0.8)/80) + 1, #ranks)]
end

function love.textinput(text)
    if highscorestate == "input" then
        textbox:textinput(text)
    end
end

function highscore.keypressed(key)
    if highscorestate == "input" then
        textbox:keypressed(key)
        return true
    end
    if highscorestate == "highscores" then
        if key == "space" or key == "return" then
            love.load()
        end
    end
    return false
end

function highscore.mousepressed( x, y, button, istouch )
--    if highscorestate == "highscores" then
--        love.load()
--    end
end

local touches = {}
local startscroll = 0

function highscore.touchpressed(id, x, y)
    if highscorestate == "highscores" then
        if x > width/4 + 2 and x < width/4 + 2 + width/2 - 4 and y > height/4 + lineheight * 2 + 10 and y < height/4 + lineheight * 2 + 10 + 12*lineheight - 2 then
            touches[id] = {x, y, 0, 0}
            startscroll = highscorescroll
        end
    end
end

function highscore.touchmoved(id, x, y, dx, dy)
    if touches[id] ~= nil then
        highscorescroll = startscroll + (touches[id][2] - y)
    end
end

function highscore.touchreleased(id, x, y)
    if touches[id] ~= nil then
        highscorescroll = startscroll + (touches[id][2] - y)
        highscorescrollspeed = -touches[id][4]
        print("touchreleased "..highscorescroll)
        if math.abs(highscorescroll) < 1 then
            love.load()
        end
    end
    touches[id] = nil
end

function CheckHighScore()
    if (highscorestate ~= "none" or offline) then
        love.load()
        --return
    end
    if score > 0 and (#HighScores < 75 or score > HighScores[75][2]) then
        highscorestate = "input"
        love.keyboard.setTextInput( true )
    elseif (#HighScores) > 1 then
        highscorestate = "highscores"
        restarttime = time
    else
        love.load()
    end
end

function sendHighScore(playername, score)
    b, c, h = http.request {
        url = "http://dreamlo.com/lb/gXMWplliu0GIHCgsPOReXguPQmJEqawkGPmz_TRnAECQ/add/"..playername.."/"..score
      }
end

function getHighScores()
    print("getHighScores "..playername)
    http.TIMEOUT = 5
    b, c, h = http.request("http://dreamlo.com/lb/5d7fe66ed1041303ecaac404/pipe/100")

    HighScores = {}
    if not (c == 200) then
        offline = true
        print("Error: '"..c.."'")
        return
    end
    playerRank = -1
    highscorescroll = 0
    highscorescrollspeed = 0
    lines = string.explode(b, "\n")
    for i,v in pairs(lines) do
        tbl = string.explode(v, "|")
        if (tbl[1] ~= nil and tbl[2] ~= nil) then
            HighScores[i] = {tbl[1],tonumber(tbl[2])}
            if (tbl[1] == playername and tonumber(tbl[2]) == score) then
                playerRank = i
                print("playerRank == "..i)
            end
        end
    end
end

function string.explode(str, div)
    --assert(type(str) == "string" and type(div) == "string", "invalid arguments")
    local o = {}
    while true do
        local pos1,pos2 = str:find(div)
        if not pos1 then
            o[#o+1] = str
            break
        end
        o[#o+1],str = str:sub(1,pos1-1),str:sub(pos2+1)
    end
    return o
end

function scoresort(object1, object2)
    return object1[2] > object2[2]
end
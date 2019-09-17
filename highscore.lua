require 'lib.middleclass'
require 'TextInput'
http = require("socket.http")

highscore = {}

function highscore.load()
    HighScores = {};
    getHighScores();
    -- input
    highscorestate = "none"

    textbox = TextInput(
        love.graphics.getWidth()/2 - 150,
        love.graphics.getHeight()/2 - 150,
        11,
        300,
        function ()
            highscorestate = "done"
            print("done")
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
        print("highscores")
        restarttime = time
        sendHighScore(playername, score)
        getHighScores()
        return true
    elseif highscorestate == "highscores" then
        if (time - restarttime > 5.0) then            
            love.load()
        end
        return true
    end
    return false
end

function highscore.draw()
    if (#HighScores) > 1 then
        love.graphics.print("Champion:", 10, 10, 0, 1)
        love.graphics.print(HighScores[1][1]..": "..HighScores[1][2], 10, 40, 0, 1)
    end

    if highscorestate == "input" then
        textbox:draw()
    elseif highscorestate == "highscores" then
        love.graphics.rectangle("line", width/2 - 250 , height/2-200,500, 500) 
        love.graphics.setColor(0.1, 0.3, 0.1, 0.9) 
        --love.graphics.setShader(gradient_shader)
        love.graphics.rectangle("fill", width/2 - 250 , height/2-200,500, 500) 
        --love.graphics.setShader()
        love.graphics.setColor(0.1, 1.0, 0.1) 
        texty = height/2-160
        love.graphics.printf("Top Scores", width/2 - 200, texty ,300)
        texty = texty + 50
        for i,v in ipairs(HighScores) do 
            if i < 10 then
                love.graphics.printf(v[1], width/2 - 200, texty ,300)
                love.graphics.printf(v[2], width/2, texty ,300)
                texty = texty + 35
            else
                HighScores[i] = nil
            end
        end
    end
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
    return false
end

function CheckHighScore()
    if (highscorestate ~= "none") then
        return
    end
    if score > 0 and (#HighScores < 10 or score > HighScores[10][2]) then
        highscorestate = "input"
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
    b, c, h = http.request ("http://dreamlo.com/lb/5d7fe66ed1041303ecaac404/pipe/10")

    lines = string.explode(b, "\n")
    for i,v in pairs(lines) do
        tbl = string.explode(v, "|")
        if (tbl[1] ~= nil and tbl[2] ~= nil) then
            HighScores[i] = {tbl[1],tonumber(tbl[2])}
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
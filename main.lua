local gfx = love.graphics
local phys = love.physics
local vector = require "hump.vector"
local camera = require "hump.camera"

love.filesystem.load("dinosaur.lua")()
love.filesystem.load("trex.lua")()
love.filesystem.load("wall.lua")()
love.filesystem.load("missile.lua")()
love.filesystem.load("explosion.lua")()
love.filesystem.load("platform.lua")()

--[[
dofile "dinosaur.lua"
dofile "trex.lua"
dofile "wall.lua"
dofile "missile.lua"
dofile "explosion.lua"
dofile "platform.lua"
--]]

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ARENA_WIDTH = 2400
ARENA_HEIGHT = 1200

PLAY_TIME = 60

function love.load()
    gfx.setBackgroundColor(0, 0, 0)
    
    -- create titles
    cpgd = gfx.newImage("title/cpgd.png")
    deadpixel = gfx.newImage("title/deadpixel.png")
    esrb = gfx.newImage("title/esrb.png")
    title = gfx.newImage("title/title.png")
    
    -- create world
    world = phys.newWorld(0, 0, ARENA_WIDTH, ARENA_HEIGHT)
    world:setCallbacks(physadd, nil, nil, nil)
    world:setGravity(0, 350)
    
    -- terrain
    sky = gfx.newImage("world/sky.png")
    grass = gfx.newImage("world/grass.png")
    grass:setFilter("nearest", "nearest")
    sand = gfx.newImage("world/sand.png")
    sand:setFilter("nearest", "nearest")

    -- create walls
    walls = {}
    walls[#walls + 1] = Wall(world, 2, ARENA_HEIGHT / 2, 5, ARENA_HEIGHT)
    walls[#walls + 1] = Wall(world, ARENA_WIDTH - 2, ARENA_HEIGHT / 2, 5, ARENA_HEIGHT)
    walls[#walls + 1] = Wall(world, ARENA_WIDTH / 2, 2, ARENA_WIDTH, 5)
    walls[#walls + 1] = Wall(world, ARENA_WIDTH / 2, ARENA_HEIGHT - 2, ARENA_WIDTH, 5)
    
    -- create player
    dino = Dinosaur(world, 1200, ARENA_HEIGHT - 200)
    
    -- create camera
    cam = camera.new(vector.new(1200, ARENA_HEIGHT - 200))
    cam.springK = 0.2
    cam.friction = 0.95
    cam.zoomV = 0
    cam.posV = vector.new(0, 0)
    cam.spring = function(dt, current, target, vel)
        local a = (target - current) * cam.springK
        vel = (vel + a) * cam.friction
        return vel
    end
    
    -- create missiles
    missiles = {
        id = 1
    }
    
    -- create lasers
    lasers = {
        id = 1
    }
    
    -- create explosions
    explosions = {
        id = 1
    }
    
    -- game state and scoring
    gameStartTime = love.timer.getTime()
    gameState = "title"
    gameScore = 0
    
    -- ui schtuff
    timerFont = gfx.newFont("fonts/prehistoric.ttf", 48)
    overFont = gfx.newFont("fonts/prehistoric.ttf", 72)
    infoFont = gfx.newFont("fonts/prehistoric.ttf", 24)

    platforms = {}
    platforms[1] = Platform(world, 256, ARENA_HEIGHT - 500, 512, 128)

    platforms[2] = Platform(world, ARENA_WIDTH - 256, ARENA_HEIGHT - 500, 512, 128)

    platforms[3] = Platform(world, ARENA_WIDTH / 2, ARENA_HEIGHT - 750, 512, 128)

    -- create enemies
    enemies = {}
    enemies[1] = Trex(world, ARENA_WIDTH / 2, ARENA_HEIGHT - 120, ARENA_WIDTH / 2 - 256, ARENA_WIDTH / 2 + 256)
    enemies[2] = Trex(world, ARENA_WIDTH / 2, ARENA_HEIGHT - (120 + 750 + 64), ARENA_WIDTH / 2 - (256 - 128), ARENA_WIDTH / 2 + (256 - 128))

    enemies[3] = Trex(world, 256, ARENA_HEIGHT - 564 - 120, 128, 512 - 128)
    enemies[4] = Trex(world, ARENA_WIDTH - 256, ARENA_HEIGHT - 564 - 120, ARENA_WIDTH - (512 - 128), ARENA_WIDTH -128)
 
    -- sound
    bgmusic = love.audio.newSource("sound/music.mp3")
    bgmusic:setVolume(0.5)
    titlemusic = love.audio.newSource("sound/titles.mp3")
    jetpacksound = love.audio.newSource("sound/jetpack.wav", "static")
    jetpacksound:setLooping(true)
    boomsound = love.audio.newSource("sound/boom.wav", "static")
    launchsound = love.audio.newSource("sound/launch.wav", "static")
    
    love.audio.play(titlemusic)
end

function love.update(dt)
    if gameState ~= "title" then
        -- update player
        dino:update(dt)
        
        -- update camera
        local velX, velY = dino.torso.body:getLinearVelocity()
        local playerVel = vector.new(velX, velY)
        local zoom = playerVel:len() / 1200
        if zoom > 1 then zoom = 1 end
        zoom = ((1 - zoom) / 2) + 0.5
        pos = vector.new(dino.torso.body:getX(), dino.torso.body:getY() - 100)
        cam.zoomV = cam.spring(dt, cam.zoom, zoom, cam.zoomV)
        local dz = cam.zoomV * dt
        cam.posV.x = cam.spring(dt, cam.pos.x, pos.x, cam.posV.x)
        local dx = cam.posV.x * dt
        cam.posV.y = cam.spring(dt, cam.pos.y, pos.y, cam.posV.y)
        local dy = cam.posV.y * dt
        cam.pos = vector.new(cam.pos.x + dx, cam.pos.y + dy)
        cam.zoom = cam.zoom + dz
        
        -- update missiles
        for k, v in pairs(missiles) do
            if k ~= "id" then
                v:update(dt)
            end
        end

        -- update and cull explosions
        for k, v in pairs(explosions) do
            if k ~= "id" then
                if love.timer.getTime() - v.spawnTime > 1000 then
                    v = nil
                end
                v:update(dt)
            end
        end

        for k, v in pairs(enemies) do
            if k ~= "id" then
                v:update(dt)
            end
        end
        
        -- update physics world
        world:update(dt)
        
        -- time up?
        elapsed = love.timer.getTime() - gameStartTime
        if elapsed > PLAY_TIME then
            gameState = "over"
        end
    end
end

function love.draw()
    if gameState == "title" then
        elapsed = love.timer.getTime() - gameStartTime
        if elapsed < 3 then
            gfx.setColor(255, 255, 255, math.sin(math.pi / 3 * elapsed) * 255)
            gfx.draw(cpgd, 0, 0, 0, 2.5, 2.5)
        elseif elapsed >= 3 and elapsed < 6 then
            gfx.setColor(255, 255, 255, math.sin(math.pi / 3 * (elapsed - 3)) * 255)
            gfx.draw(deadpixel, 0, 0, 0, 2.5, 2.5)
        elseif elapsed >= 6 and elapsed < 9 then
            gfx.setColor(255, 255, 255, math.sin(math.pi / 3 * (elapsed - 6)) * 255)
            gfx.draw(esrb, 0, 0, 0, 2.5, 2.5)
        elseif elapsed >= 9 and elapsed < 10.5 then
            gfx.setColor(255, 255, 255, math.sin(math.pi / 3 * (elapsed - 9)) * 255)
            gfx.draw(title, 0, 0, 0, 2.5, 2.5)
        else
            gfx.draw(title, 0, 0, 0, 2.5, 2.5)
        end
    else
        -- draw background
        local skyPos = vector.new(-cam.pos.x / 6, ((-cam.pos.y - 100) / 6) - 10)
        gfx.draw(sky, skyPos.x, skyPos.y)

        -- begin world drawing
        cam:predraw()

        -- draw terrain
        for i = 1, 6 do
            gfx.draw(sand, -192 + 5, (i - 1) * 224, 0, 4, 4)
            gfx.draw(sand, -384 + 5, (i - 1) * 224, 0, 4, 4)
            gfx.draw(sand, -576 + 5, (i - 1) * 224, 0, 4, 4)
            gfx.draw(sand, -768 + 5, (i - 1) * 224, 0, 4, 4)
            
            gfx.draw(sand, 2400 - 5, (i - 1) * 224, 0, 4, 4)
            gfx.draw(sand, 2592 - 5, (i - 1) * 224, 0, 4, 4)
            gfx.draw(sand, 2784 - 5, (i - 1) * 224, 0, 4, 4)
            gfx.draw(sand, 2976 - 5, (i - 1) * 224, 0, 4, 4)
        end
        for i = -2, 16 do
            gfx.draw(grass, (i - 1) * 192, ARENA_HEIGHT - 5, 0, 4, 4)
            gfx.draw(grass, (i - 1) * 192, ARENA_HEIGHT + 448 - 5, 0, 4, -4)
        end

        dino:draw()
            
        for k, v in pairs(platforms) do
            if k ~= "id" then
                v:draw()
            end
        end

        for k, v in pairs(enemies) do
            if k ~= "id" then
                v:draw()
            end
        end
        
        -- draw missiles
        for k, v in pairs(missiles) do
            if k ~= "id" then
                v:draw()
            end
        end
        
        -- draw explosions
        for k, v in pairs(explosions) do
            if k ~= "id" then
                v:draw()
            end
        end
        
        --[[
        -- thruster debug drawing
        gfx.setColor(0, 255, 0)
        gfx.setLine(5, "smooth")
        gfx.line(dino.thruster.left.pos.x, dino.thruster.left.pos.y, dino.thruster.left.pos.x - dino.thruster.left.dir.x, dino.thruster.left.pos.y - dino.thruster.left.dir.y)
        gfx.setColor(0, 0, 255)
        gfx.setLine(5, "smooth")
        gfx.line(dino.thruster.right.pos.x, dino.thruster.right.pos.y, dino.thruster.right.pos.x - dino.thruster.right.dir.x, dino.thruster.right.pos.y - dino.thruster.right.dir.y)
        --]]
        
        -- end world drawing
        cam:postdraw()
        
        -- draw ui
        gfx.setFont(infoFont)
        gfx.setColor(0, 0, 0)
        gfx.print("Time Remaining", 22, 7)
        gfx.setColor(255, 255, 255)
        gfx.print("Time Remaining", 20, 5)
        gfx.setColor(0, 0, 0)
        gfx.print("Score", 22, 502)
        gfx.setColor(255, 255, 255)
        gfx.print("Score", 20, 500)
        
        -- game timer and score
        elapsed = love.timer.getTime() - gameStartTime
        if elapsed > PLAY_TIME then
            remaining = 0
        else
            remaining = PLAY_TIME - elapsed
        end
        gfx.setFont(timerFont)
        gfx.setColor(0, 0, 0)
        gfx.print(string.format("%.2f", remaining), 22, 25)
        gfx.setColor(255, 255, 255)
        gfx.print(string.format("%.2f", remaining), 20, 23)
        gfx.setColor(0, 0, 0)
        gfx.print(gameScore, 22, 520)
        gfx.setColor(255, 255, 255)
        gfx.print(gameScore, 20, 518)
        
        -- game over text
        if gameState == "over" then
            gfx.setFont(overFont)
            gfx.setColor(0, 0, 0)
            gfx.print("GAME OVER", 202, 202)
            gfx.setColor(255, 255, 255)
            gfx.print("GAME OVER", 200, 200)
        end
    end
end

function love.keyreleased(key, unicode)
    if gameState == "playing" then
        if key == "a" or key == "d" then
            if not jetpacksound:isStopped() then
                love.audio.stop(jetpacksound)
            end
        end
    end
end

function love.keypressed(key, unicode)
    if gameState == "title" then
        gameState = "playing"
        gameStartTime = love.timer.getTime()
        love.audio.stop(titlemusic)
        love.audio.play(bgmusic)
    elseif gameState == "playing" then
        if key == " " then
            dino:right()
        elseif key == "right" then
            local dinovelX, dinovelY = dino.torso.body:getLinearVelocity()
            missiles[tostring(missiles.id)] = Missile(world, dino.torso.body:getX(), dino.torso.body:getY(), dino.torso.body:getAngle(), vector.new(dinovelX, dinovelY), missiles.id, false)
            missiles.id = missiles.id + 1
            love.audio.stop(launchsound)
            love.audio.rewind(launchsound)
            love.audio.play(launchsound)
        elseif key == "left" then
            local tailvelX, tailvelY = dino.tail[5].body:getLinearVelocity()
            missiles[tostring(missiles.id)] = Missile(world, dino.tail[5].body:getX(), dino.tail[5].body:getY(), dino.tail[5].body:getAngle(), vector.new(tailvelX, tailvelY), missiles.id, true)
            missiles.id = missiles.id + 1
            love.audio.stop(launchsound)
            love.audio.rewind(launchsound)
            love.audio.play(launchsound)
        elseif key == "a" or key == "d" then
            if jetpacksound:isStopped() then
                love.audio.play(jetpacksound)
            end
        end
    elseif gameState == "over" then
        -- nothing, lol, out of time
    end
end

function physadd(shape1data, shape2data, contact)
    if shape1data ~= nil then
        if shape1data.kind == "missile" then
            if missiles[tostring(shape1data.i)] ~= nil then
                -- delete missile
                missiles[tostring(shape1data.i)].body = nil
                missiles[tostring(shape1data.i)].shape = nil
                missiles[tostring(shape1data.i)] = nil
                
                -- create explosion
                explosions[tostring(explosions.id)] = Explosion(shape1data.pos.x, shape1data.pos.y)
                explosions.id = explosions.id + 1
                
                love.audio.stop(boomsound)
                love.audio.rewind(boomsound)
                love.audio.play(boomsound)
                
                if shape2data ~= nil then
                    if shape2data.kind == "trex" then
                        gameScore = gameScore + 1
                    end
                end
            end
        end
    end
    
    if shape2data ~= nil then
        if shape2data.kind == "missile" then
            if missiles[tostring(shape2data.i)] ~= nil then
                -- delete missile
                missiles[tostring(shape2data.i)].body = nil
                missiles[tostring(shape2data.i)].shape = nil
                missiles[tostring(shape2data.i)] = nil
                
                -- create explosion
                explosions[tostring(explosions.id)] = Explosion(shape2data.pos.x, shape2data.pos.y)
                explosions.id = explosions.id + 1
                
                love.audio.stop(boomsound)
                love.audio.rewind(boomsound)
                love.audio.play(boomsound)
                
                if shape1data ~= nil then
                    if shape1data.kind == "trex" then
                        gameScore = gameScore + 1
                    end
                end
            end
        end
    end
end

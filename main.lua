local gfx = love.graphics
local phys = love.physics
local vector = require "hump.vector"
local camera = require "hump.camera"

dofile "dinosaur.lua"
dofile "wall.lua"

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ARENA_WIDTH = 2400
ARENA_HEIGHT = 1200

function love.load()
    gfx.setBackgroundColor(0, 0, 0)
    
    -- create world
    world = phys.newWorld(0, 0, ARENA_WIDTH, ARENA_HEIGHT)
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
    dino = Dinosaur(world, 400, 300)
    
    -- create camera
    cam = camera.new(vector.new(400, 300))
    cam.springK = 0.2
    cam.friction = 0.95
    cam.zoomV = 0
    cam.posV = vector.new(0, 0)
    cam.spring = function(dt, current, target, vel)
        local a = (target - current) * cam.springK
        vel = (vel + a) * cam.friction
        return vel
    end
end

function love.update(dt)    
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
    
    -- update physics world
    world:update(dt)
end

function love.draw()    
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
    
    -- draw walls
    -- TODO: take this out
    --for k,v in pairs(walls) do
    --    v:draw()
    --end

    dino:draw()

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
end

function love.keypressed(key, unicode)
    if key == " " then
        dino:right()
    end
end

require "hump.vector"

dofile "./dinosaur.lua"
dofile "./obstacle.lua"

local vector = hump.vector

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ARENA_WIDTH = 800
ARENA_HEIGHT = 600

world = nil

walls = {
}

dino = Dinosaur:new()


test = love.graphics.newImage("head01.png")

resources = {}

resources["tail01"] = love.graphics.newImage("img/tail01.png")
resources["tail01"]:setFilter("nearest", "nearest")

resources["tail02"] = love.graphics.newImage("img/tail02.png")
resources["tail02"]:setFilter("nearest", "nearest")

resources["tail03"] = love.graphics.newImage("img/tail03.png")
resources["tail03"]:setFilter("nearest", "nearest")

resources["tail04"] = love.graphics.newImage("img/tail04.png")
resources["tail04"]:setFilter("nearest", "nearest")

test:setFilter("nearest", "nearest")

function love.load()
    
    local gfx = love.graphics
    local phys = love.physics

    gfx.setBackgroundColor(255, 255, 255)
    
    world = phys.newWorld(0, 0, 800, 600)
    world:setGravity(0, 350)
    
    left = Obstacle:new()
    left:initialize(2, ARENA_HEIGHT / 2, 5, ARENA_HEIGHT)
    walls[#walls+1] = left

    right = Obstacle:new()
    right:initialize(ARENA_WIDTH - 2, ARENA_HEIGHT / 2, 5, ARENA_HEIGHT)
    walls[#walls+1] = right

    top = Obstacle:new()
    top:initialize(ARENA_WIDTH / 2, 2, ARENA_WIDTH, 5)
    walls[#walls+1] = top

    bottom = Obstacle:new()
    bottom:initialize(ARENA_WIDTH / 2, ARENA_HEIGHT - 2, ARENA_WIDTH, 5)
    walls[#walls+1] = bottom


    --dino.foot.body = phys.newBody(world, 400, ARENA_HEIGHT - 200, 10, 15)
    --dino.foot.shape = phys.newRectangleShape(dino.foot.body, 0, 0, 50, 50, 0)

    dino:initialize(400, 400)

end

function love.update(dt)
    local kb = love.keyboard

    -- calculate correction factor
    correction = dino.torso.body:getAngle() % (2 * math.pi)
    if correction >= math.pi / 2 and correction <= 3 * math.pi / 2 then
        correction = 0
    elseif correction > 3 * math.pi / 2 then
        correction = 2 * math.pi - correction
    end
    correction = correction / (math.pi / 2)
    
    if kb.isDown("a") then
        -- apply user thrust on the right
        dino.thrusterR = vector.new(dino.torso.body:getX() + dino.THRUSTER_DIST * math.cos(dino.torso.body:getAngle()),
                                    dino.torso.body:getY() + dino.THRUSTER_DIST * math.sin(dino.torso.body:getAngle()))
        dino.torso.body:applyForce(-100 * math.cos(dino.torso.body:getAngle() + (math.pi / 2)), -100 * math.sin(dino.torso.body:getAngle() + (math.pi / 2)), dino.thrusterR.x, dino.thrusterR.y)
    elseif not kb.isDown("a") and kb.isDown("d") then
        -- apply autocorrect on the right
        dino.thrusterR = vector.new(dino.torso.body:getX() + dino.THRUSTER_DIST * math.cos(dino.torso.body:getAngle()),
                                    dino.torso.body:getY() + dino.THRUSTER_DIST * math.sin(dino.torso.body:getAngle()))
        dino.torso.body:applyForce(-25 * correction * math.cos(dino.torso.body:getAngle() + (math.pi / 2)), -25 * correction * math.sin(dino.torso.body:getAngle() + (math.pi / 2)), dino.thrusterR.x, dino.thrusterR.y)
    end
    
    if kb.isDown("d") then
        -- apply user thrust on the left
        dino.thrusterL = vector.new(dino.torso.body:getX() - dino.THRUSTER_DIST * math.cos(dino.torso.body:getAngle()),
                                    dino.torso.body:getY() - dino.THRUSTER_DIST * math.sin(dino.torso.body:getAngle()))
        dino.torso.body:applyForce(-100 * math.cos(dino.torso.body:getAngle() + (math.pi / 2)), -100 * math.sin(dino.torso.body:getAngle() + (math.pi / 2)), dino.thrusterL.x, dino.thrusterL.y)
    elseif not kb.isDown("d") and kb.isDown("a") then
        -- apply autocorrect on the left
        dino.thrusterL = vector.new(dino.torso.body:getX() - dino.THRUSTER_DIST * math.cos(dino.torso.body:getAngle()),
                                    dino.torso.body:getY() - dino.THRUSTER_DIST * math.sin(dino.torso.body:getAngle()))
        dino.torso.body:applyForce(-25 * correction * math.cos(dino.torso.body:getAngle() + (math.pi / 2)), -25 * correction * math.sin(dino.torso.body:getAngle() + (math.pi / 2)), dino.thrusterL.x, dino.thrusterL.y)
    end


    --[[
    if love.keyboard.isDown("a") or love.keyboard.isDown("d") then
        -- calculate thruster positions and swap if necessary
        dino.thrusterL = vector.new(dino.torso.body:getX() - dino.THRUSTER_DIST * math.cos(dino.torso.body:getAngle()),
                                    dino.torso.body:getY() - dino.THRUSTER_DIST * math.sin(dino.torso.body:getAngle()))
        dino.thrusterR = vector.new(dino.torso.body:getX() + dino.THRUSTER_DIST * math.cos(dino.torso.body:getAngle()),
                                    dino.torso.body:getY() + dino.THRUSTER_DIST * math.sin(dino.torso.body:getAngle()))
        
        -- "d" controls the left thruster
        if love.keyboard.isDown("d") then
            dino.torso.body:applyForce(-100 * math.cos(dino.torso.body:getAngle() + (math.pi / 2)), -100 * math.sin(dino.torso.body:getAngle() + (math.pi / 2)), dino.thrusterL.x, dino.thrusterL.y)
        end
        
        -- "a" controls the right thruster
        if love.keyboard.isDown("a") then
            dino.torso.body:applyForce(-100 * math.cos(dino.torso.body:getAngle() + (math.pi / 2)), -100 * math.sin(dino.torso.body:getAngle() + (math.pi / 2)), dino.thrusterR.x, dino.thrusterR.y)
        end
    end
    --]]
    
    dino:update(dt)
    
    world:update(dt)

end

function love.draw()
    local gfx = love.graphics
    
    -- draw walls
    gfx.setColor(0, 0, 0)

    --[[    
    drawSimpleRect(walls.left)
    drawSimpleRect(walls.right)
    drawSimpleRect(walls.top)
    drawSimpleRect(walls.bottom)
    --]]

    for k,v in pairs(walls) do v:draw() end

    dino:draw()

    gfx.pop()

    
    gfx.setColor(0, 255, 0)
    gfx.point(dino.thrusterL.x, dino.thrusterL.y)
    gfx.setColor(0, 0, 255)
    gfx.point(dino.thrusterR.x, dino.thrusterR.y)
    
    gfx.setColor(255, 255, 255)
    gfx.draw(test, 50, 50, 0, 5, 5)
end

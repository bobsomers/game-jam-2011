require "hump.vector"

local vector = hump.vector

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ARENA_WIDTH = 800
ARENA_HEIGHT = 600

walls = {
    left = {},
    right = {},
    top = {},
    bottom = {}
}

dino = {
    THRUSTER_DIST = 20,
    head = {},
    foot = {},
    torso = {}
}

test = love.graphics.newImage("head01.png")

function love.load()
    local gfx = love.graphics
    local phys = love.physics
    
    gfx.setBackgroundColor(255, 255, 255)
    
    world = phys.newWorld(0, 0, 800, 600)
    world:setGravity(0, 350)
    
    walls.left.body = phys.newBody(world, 2, ARENA_HEIGHT / 2, 0, 0)
	walls.left.shape = phys.newRectangleShape(walls.left.body, 0, 0, 5, ARENA_HEIGHT, 0)
	walls.right.body = phys.newBody(world, ARENA_WIDTH - 2, ARENA_HEIGHT / 2, 0, 0)
	walls.right.shape = phys.newRectangleShape(walls.right.body, 0, 0, 5, ARENA_HEIGHT, 0)
	walls.top.body = phys.newBody(world, ARENA_WIDTH / 2, 2, 0, 0)
	walls.top.shape = phys.newRectangleShape(walls.top.body, 0, 0, ARENA_WIDTH, 5, 0)
	walls.bottom.body = phys.newBody(world, ARENA_WIDTH / 2, ARENA_HEIGHT - 2, 0, 0)
	walls.bottom.shape = phys.newRectangleShape(walls.bottom.body, 0, 0, ARENA_WIDTH, 5, 0)
    
    dino.torso.body = phys.newBody(world, 400, ARENA_HEIGHT - 200, 10, 15)
    dino.torso.shape = phys.newRectangleShape(dino.torso.body, 0, 0, 100, 50, 0)
    dino.thrusterL = vector.new(dino.torso.body:getX() - dino.THRUSTER_DIST, dino.torso.body:getY())
    dino.thrusterR = vector.new(dino.torso.body:getX() + dino.THRUSTER_DIST, dino.torso.body:getY())

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
    
    
    
    world:update(dt)
end

function drawSimpleRect(obj)
    local x1, y1, x2, y2, x3, y3, x4, y4 = obj.shape:getBoundingBox()
    local w = x3 - x2
    local h = y2 - y1
    love.graphics.rectangle("fill", obj.body:getX() - (w / 2), obj.body:getY() - (h / 2), w, h)
end

function love.draw()
    local gfx = love.graphics
    
    -- draw walls
    gfx.setColor(0, 0, 0)
    drawSimpleRect(walls.left)
    drawSimpleRect(walls.right)
    drawSimpleRect(walls.top)
    drawSimpleRect(walls.bottom)
    
    -- body
    gfx.push()
    gfx.translate(dino.torso.body:getX(), dino.torso.body:getY())
    gfx.rotate(dino.torso.body:getAngle())
    gfx.setColor(255, 0, 0)
    gfx.rectangle("fill", -50, -25, 100, 50)


        -- left leg
        gfx.push()
        gfx.translate(0, 25, 0)
        gfx.setColor(0, 255, 0)
        gfx.rectangle("fill", -10, -10, 10, 10)
        gfx.pop()

    gfx.pop()

    
    gfx.setColor(0, 255, 0)
    gfx.point(dino.thrusterL.x, dino.thrusterL.y)
    gfx.setColor(0, 0, 255)
    gfx.point(dino.thrusterR.x, dino.thrusterR.y)
    
    gfx.setColor(255, 255, 255)
    gfx.draw(test, 50, 50, 0, 5, 5)
end

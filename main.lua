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
    if love.keyboard.isDown("a") or love.keyboard.isDown("d") then
        -- calculate thruster positions and swap if necessary
        dino.thrusterL = vector.new(dino.torso.body:getX() - dino.THRUSTER_DIST * math.cos(dino.torso.body:getAngle()),
                                    dino.torso.body:getY() - dino.THRUSTER_DIST * math.sin(dino.torso.body:getAngle()))
        dino.thrusterR = vector.new(dino.torso.body:getX() + dino.THRUSTER_DIST * math.cos(dino.torso.body:getAngle()),
                                    dino.torso.body:getY() + dino.THRUSTER_DIST * math.sin(dino.torso.body:getAngle()))
        if dino.thrusterL.x > dino.thrusterR.x then
            dino.thrusterL, dino.thrusterR = dino.thrusterR, dino.thrusterL
        end
        
        -- "d" controls the left thruster
        if love.keyboard.isDown("d") then
            dino.torso.body:applyForce(25, -100, dino.thrusterL.x, dino.thrusterL.y)
        end
        
        -- "a" controls the right thruster
        if love.keyboard.isDown("a") then
            dino.torso.body:applyForce(-25, -100, dino.thrusterR.x, dino.thrusterR.y)
        end
    end
    
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
    
    gfx.push()
    gfx.translate(dino.torso.body:getX(), dino.torso.body:getY())
    gfx.rotate(dino.torso.body:getAngle())
    gfx.setColor(255, 0, 0)
    gfx.rectangle("fill", -50, -25, 100, 50)
    gfx.pop()
    
    gfx.setColor(0, 255, 0)
    gfx.point(dino.thrusterL.x, dino.thrusterL.y)
    gfx.setColor(0, 0, 255)
    gfx.point(dino.thrusterR.x, dino.thrusterR.y)
end
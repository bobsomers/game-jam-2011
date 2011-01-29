require "hump.vector"

dofile "dinosaur.lua"
dofile "obstacle.lua"

local vector = hump.vector

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
ARENA_WIDTH = 800
ARENA_HEIGHT = 600

world = nil

walls = {
}

dino = Dinosaur


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
end

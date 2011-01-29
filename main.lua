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

    gfx.setBackgroundColor(0, 0, 0)
    
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

    for k,v in pairs(walls) do v:draw() end

    dino:draw()

    gfx.pop()

    --[[
    -- thruster debug drawing
    gfx.setColor(0, 255, 0)
    gfx.setLine(5, "smooth")
    gfx.line(dino.thruster.left.pos.x, dino.thruster.left.pos.y, dino.thruster.left.pos.x - dino.thruster.left.dir.x, dino.thruster.left.pos.y - dino.thruster.left.dir.y)
    gfx.setColor(0, 0, 255)
    gfx.setLine(5, "smooth")
    gfx.line(dino.thruster.right.pos.x, dino.thruster.right.pos.y, dino.thruster.right.pos.x - dino.thruster.right.dir.x, dino.thruster.right.pos.y - dino.thruster.right.dir.y)
    --]]
    
    gfx.setColor(255, 255, 255)
    gfx.draw(test, 50, 50, 0, 5, 5)
end

function love.keypressed(key, unicode)
    if key == " " then
        dino:right()
    end
end

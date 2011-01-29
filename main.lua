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

dino = {}

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
end

function love.update(dt)
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
end
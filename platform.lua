local gfx = love.graphics
local phys = love.physics
local vector = require "hump.vector"
local class = require "hump.class"

Platform = class(function(self, world, x, y, width, height)
    self.width, self.height = width, height

    self.loc = vector.new(x,y)

    self.image = gfx.newImage("world/block.png")
    self.image_size = vector.new(64, 64)

    self.body = phys.newBody(world, x, y, 0, 0)
    self.shape = phys.newRectangleShape(self.body, 0, 0, width, height, 0)
    self.shape:setCategory(16)
end)

function Platform:draw()
    local x1, y1, x2, y2, x3, y3, x4, y4 = self.shape:getBoundingBox()
    local w = x3 - x2
    local h = y2 - y1

    gfx.setColor(255, 255, 255)

    --gfx.rectangle("fill", self.body:getX() - (w / 2), self.body:getY() - (h / 2), w, h)

    for i = self.body:getX() - (w / 2), self.body:getX() + (w / 2) - 1, self.image_size.x do
        for j = self.body:getY() + (h / 2), self.body:getY() - (h / 2) - 1, self.image_size.y do
            gfx.draw(self.image, i, j, 0, 2, 2)
        end
    end

end

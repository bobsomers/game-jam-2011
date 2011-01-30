local gfx = love.graphics
local phys = love.physics
local vector = require "hump.vector"
local class = require "hump.class"

Wall = class(function(self, world, x, y, width, height)
    self.body = phys.newBody(world, x, y, 0, 0)
    self.shape = phys.newRectangleShape(self.body, 0, 0, width, height, 0)
    self.shape:setCategory(16)
end)

function Wall:draw()
    local x1, y1, x2, y2, x3, y3, x4, y4 = self.shape:getBoundingBox()
    local w = x3 - x2
    local h = y2 - y1
    gfx.setColor(255, 255, 255)
    gfx.rectangle("fill", self.body:getX() - (w / 2), self.body:getY() - (h / 2), w, h)
end

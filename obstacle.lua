
dofile "game/helper.lua"

local gfx = love.graphics
local phys = love.physics
local vector = hump.vector

Obstacle = {}

function Obstacle:new (o)

    o = o or { 
                shape = nil, 
                body = nil 
             }

    setmetatable(o, self)
    self.__index = self
    return o
end

-- initialize an obstacle to the given location
function Obstacle.initialize(self, x, y, width, height)

    self.body = phys.newBody(world, x, y, 0, 0)
	self.shape = phys.newRectangleShape(self.body, 0, 0, width, height, 0)

end

function Obstacle.draw(self)

    drawSimpleRect(self)

end

function Obstacle.update(self, dt)


end

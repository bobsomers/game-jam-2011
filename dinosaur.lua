
-- template dinosaur dataset
Dinosaur = {}

local gfx = love.graphics
local phys = love.physics
local vector = hump.vector

function Dinosaur:new (o)

    o = o or { 
                THRUSTER_DIST = 25,
                head = {},
                foot = {},
                torso = {}
             }

    setmetatable(o, self)
    self.__index = self

    return o
end

function Dinosaur.initTail(self, x, y)
    self.tail = {}

    -- create tail segments
    for i=1,4 do
        self.tail[i] = {}
        self.tail[i].body = phys.newBody(world, x + 50 + (i * 14), y, 0.000001, 0.000001)
        self.tail[i].shape = phys.newRectangleShape(self.tail[i].body, 0, 0, 20 - 2*i, 20 - 2*i, 0)
        -- if it is the first joint, allow it to rotate a little more than the others
        if i == 1 then
            self.tail[i].joint = love.physics.newRevoluteJoint( self.torso.body, self.tail[i].body, x + 50 + ((i-1) * 14), y )
            self.tail[i].joint:setMaxMotorTorque(0)
            self.tail[i].joint:setLimits(-math.pi / 4, math.pi / 4)
            self.tail[i].joint:setLimitsEnabled(true)
        else
        -- otherwise, restrict the rotation of the tail segments
            self.tail[i].joint = love.physics.newRevoluteJoint( self.tail[i-1].body, self.tail[i].body, x + 50 + ((i-1) * 14), y )
            self.tail[i].joint:setLimits(-math.pi / 16, math.pi / 16)
            self.tail[i].joint:setLimitsEnabled(true)
        end
    end
end

function Dinosaur.initTorso(self, x, y)

    self.torso.body = phys.newBody(world, x, y, 10, 15)
    self.torso.shape = phys.newRectangleShape(dino.torso.body, 0, 0, 100, 50, 0)
    self.thrusterLpos = vector.new(dino.torso.body:getX() - dino.THRUSTER_DIST, dino.torso.body:getY())
    self.thrusterRpos = vector.new(dino.torso.body:getX() + dino.THRUSTER_DIST, dino.torso.body:getY())
    self.thrusterLdir = vector.new(0, 0)
    self.thrusterRdir = vector.new(0, 0)

    self.foot.body = phys.newBody(world, x, y + 25, 2, 3)
    self.foot.shape = phys.newRectangleShape(dino.foot.body, 0, 0, 50, 50, 0)

    self:initTail(x, y)

end

-- initialize a dinosaur to the given location
function Dinosaur.initialize(self, x, y)

    self:initTorso (x, y)

end

function Dinosaur.draw(self)

    -- body
    gfx.push()
    gfx.translate(self.torso.body:getX(), self.torso.body:getY())
    gfx.rotate(self.torso.body:getAngle())
    gfx.setColor(255, 0, 0)
    gfx.rectangle("fill", -50, -25, 100, 50)

    gfx.pop()

        -- left leg
        ---[[
        gfx.push()
        gfx.translate(self.foot.body:getX(), self.foot.body:getY())
        gfx.rotate(self.foot.body:getAngle())
        gfx.setColor(0, 255, 0)
        gfx.rectangle("fill", -25, -25, 50, 50)
        gfx.pop()

    for i=4,1,-1 do
        gfx.push()
        gfx.translate(self.tail[i].body:getX(), self.tail[i].body:getY())
        gfx.rotate(self.tail[i].body:getAngle())
        --gfx.setColor(0, 0, 255)
        --gfx.rectangle("fill", -5, -5, 20 - 2*i, 20 - 2*i)
        gfx.setColor(255, 255, 255)
        gfx.draw(resources["tail0" .. i], 0, 0, 0, 2, 2, 0, 0)
        gfx.pop()
    end

        --]]

end

function Dinosaur.update(self, dt)
    local kb = love.keyboard

    dinoAngle = self.torso.body:getAngle()

    -- calculate correction factor
    -- warning: major voodoo ahead
    correction = dino.torso.body:getAngle() % (2 * math.pi)
    if correction >= math.pi / 2 and correction <= 3 * math.pi / 2 then
        correction = 0
    elseif correction > 3 * math.pi / 2 then
        correction = 2 * math.pi - correction
    end
    correction = 1 - (correction / (math.pi / 2))
    if correction < 0.1 then correction = 0 end
    correction = math.exp(-2 * correction)
    
    -- calculate thruster positions and directions
    self.thrusterLpos = vector.new(self.torso.body:getX() - self.THRUSTER_DIST * math.cos(dinoAngle),
                                   self.torso.body:getY() - self.THRUSTER_DIST * math.sin(dinoAngle))
    self.thrusterRpos = vector.new(self.torso.body:getX() + self.THRUSTER_DIST * math.cos(dinoAngle),
                                   self.torso.body:getY() + self.THRUSTER_DIST * math.sin(dinoAngle))
    
    if kb.isDown("a") then
        -- apply thrust on the right
        self.thrusterRdir = vector.new(-150 * math.cos(dinoAngle - (math.pi / 10) + (math.pi / 2)),
                                       -150 * math.sin(dinoAngle - (math.pi / 10) + (math.pi / 2)))
    else
        -- apply autocorrecting thrust on the right
        self.thrusterRdir = vector.new(-100 * correction * math.cos(dinoAngle - (math.pi / 10) + (math.pi / 2)),
                                       -100 * correction * math.sin(dinoAngle - (math.pi / 10) + (math.pi / 2)))
    end
    self.torso.body:applyForce(self.thrusterRdir.x, self.thrusterRdir.y, self.thrusterRpos.x, self.thrusterRpos.y)
    
    if kb.isDown("d") then
        -- apply thrust on the left
        self.thrusterLdir = vector.new(-150 * math.cos(dinoAngle + (math.pi / 10) + (math.pi / 2)),
                                       -150 * math.sin(dinoAngle + (math.pi / 10) + (math.pi / 2)))
    else
        -- apply autocorrecting thrust on the left
        self.thrusterLdir = vector.new(-100 * correction * math.cos(dinoAngle + (math.pi / 10) + (math.pi / 2)),
                                       -100 * correction * math.sin(dinoAngle + (math.pi / 10) + (math.pi / 2)))
    end
    self.torso.body:applyForce(self.thrusterLdir.x, self.thrusterLdir.y, self.thrusterLpos.x, self.thrusterLpos.y)
end

function Dinosaur.right(self)
    self.torso.body:applyImpulse(0, -50, self.torso.body:getX() - 75, self.torso.body:getY())
end

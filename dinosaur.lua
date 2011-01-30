
-- template dinosaur dataset
Dinosaur = {}

local gfx = love.graphics
local phys = love.physics
local vector = hump.vector

function Dinosaur:new (o)

    o = o or { 
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

    self.foot.body = phys.newBody(world, x, y + 25, 2, 3)
    self.foot.shape = phys.newRectangleShape(dino.foot.body, 0, 0, 50, 50, 0)

    self:initTail(x, y)

end

-- initialize a dinosaur to the given location
function Dinosaur.initialize(self, x, y)
    self:initTorso (x, y)
    
    -- thruster set up
    self.thruster = {
        DISTANCE = 25,
        USER_POWER = 150,
        AUTOCORRECT_POWER = 100,
        left = {},
        right = {},
    }
    self.thruster.left.pos = vector.new(self.torso.body:getX() - self.thruster.DISTANCE, self.torso.body:getY())
    self.thruster.left.dir = vector.new(0, 0)
    self.thruster.right.pos = vector.new(self.torso.body:getX() + self.thruster.DISTANCE, self.torso.body:getY())
    self.thruster.right.dir = vector.new(0, 0)
    
    -- thruster particle systems
    self.thruster.image = love.graphics.newImage("thruster_particle.png")
    self.thruster.left.psys = love.graphics.newParticleSystem(self.thruster.image, 1000)
    self.thruster.left.psys:setEmissionRate(1000)
    self.thruster.left.psys:setSpeed(500, 600)
	self.thruster.left.psys:setSize(1, 0.5)
	self.thruster.left.psys:setColor(220, 105, 20, 255, 194, 30, 18, 0)
	self.thruster.left.psys:setPosition(400, 300)
	self.thruster.left.psys:setLifetime(0.1)
	self.thruster.left.psys:setParticleLife(0.2)
	self.thruster.left.psys:setDirection(math.pi / 2)
	self.thruster.left.psys:setSpread(math.pi / 4)
	self.thruster.left.psys:setTangentialAcceleration(1000)
	self.thruster.left.psys:setRadialAcceleration(-2000)
	self.thruster.left.psys:stop()
    self.thruster.right.psys = love.graphics.newParticleSystem(self.thruster.image, 1000)
    self.thruster.right.psys:setEmissionRate(1000)
    self.thruster.right.psys:setSpeed(500, 600)
	self.thruster.right.psys:setSize(1, 0.5)
	self.thruster.right.psys:setColor(220, 105, 20, 255, 194, 30, 18, 0)
	self.thruster.right.psys:setPosition(400, 300)
	self.thruster.right.psys:setLifetime(0.1)
	self.thruster.right.psys:setParticleLife(0.2)
	self.thruster.right.psys:setDirection(math.pi / 2)
	self.thruster.right.psys:setSpread(math.pi / 4)
	self.thruster.right.psys:setTangentialAcceleration(1000)
	self.thruster.right.psys:setRadialAcceleration(-2000)
	self.thruster.right.psys:stop()
    
end

function Dinosaur.draw(self)
    -- thrusters
    local oldColorMode = love.graphics.getColorMode()
    local oldBlendMode = love.graphics.getBlendMode()
    gfx.setColorMode("modulate")
    gfx.setBlendMode("additive")
    gfx.draw(self.thruster.left.psys, 0, 0)
    gfx.draw(self.thruster.right.psys, 0, 0)
    gfx.setColorMode(oldColorMode)
    gfx.setBlendMode(oldBlendMode)

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
    if correction < math.pi / 2 then
        correction_side = "right"
    elseif correction >= math.pi / 2 and correction <= 3 * math.pi / 2 then
        correction = 0
        correction_side = "none"
    elseif correction > 3 * math.pi / 2 then
        correction = 2 * math.pi - correction
        correction_side = "left"
    end
    correction = 1 - (correction / (math.pi / 2))
    if correction < 0.2 then correction = 0 end
    correction = math.exp(-0.6 * correction)
    
    -- calculate thruster positions and directions
    self.thruster.left.pos = vector.new(self.torso.body:getX() - self.thruster.DISTANCE * math.cos(dinoAngle),
                                        self.torso.body:getY() - self.thruster.DISTANCE * math.sin(dinoAngle))
    self.thruster.right.pos = vector.new(self.torso.body:getX() + self.thruster.DISTANCE * math.cos(dinoAngle),
                                         self.torso.body:getY() + self.thruster.DISTANCE * math.sin(dinoAngle))
                                         
    -- thrusters!
    if kb.isDown("a") then
        -- apply thrust on the right
        self.thruster.right.dir = vector.new(-self.thruster.USER_POWER * math.cos(dinoAngle - (math.pi / 10) + (math.pi / 2)),
                                             -self.thruster.USER_POWER * math.sin(dinoAngle - (math.pi / 10) + (math.pi / 2)))
    else
        if correction_side == "right" then
            -- apply autocorrecting thrust on the right
            self.thruster.right.dir = vector.new(-self.thruster.AUTOCORRECT_POWER * correction * math.cos(dinoAngle - (math.pi / 10) + (math.pi / 2)),
                                                 -self.thruster.AUTOCORRECT_POWER * correction * math.sin(dinoAngle - (math.pi / 10) + (math.pi / 2)))
        else
            self.thruster.right.dir = vector.new(0, 0)
        end
    end
    self.torso.body:applyForce(self.thruster.right.dir.x, self.thruster.right.dir.y, self.thruster.right.pos.x, self.thruster.right.pos.y)
    self.thruster.right.psys:setPosition(self.thruster.right.pos.x, self.thruster.right.pos.y)
    
    if kb.isDown("d") then
        -- apply thrust on the left
        self.thruster.left.dir = vector.new(-self.thruster.USER_POWER * math.cos(dinoAngle + (math.pi / 10) + (math.pi / 2)),
                                            -self.thruster.USER_POWER * math.sin(dinoAngle + (math.pi / 10) + (math.pi / 2)))
    else
        if correction_side == "left" then
            -- apply autocorrecting thrust on the left
            self.thruster.left.dir = vector.new(-self.thruster.AUTOCORRECT_POWER * correction * math.cos(dinoAngle + (math.pi / 10) + (math.pi / 2)),
                                                -self.thruster.AUTOCORRECT_POWER * correction * math.sin(dinoAngle + (math.pi / 10) + (math.pi / 2)))
        else
            self.thruster.left.dir = vector.new(0, 0)
        end
    end
    self.torso.body:applyForce(self.thruster.left.dir.x, self.thruster.left.dir.y, self.thruster.left.pos.x, self.thruster.left.pos.y)
    self.thruster.left.psys:setPosition(self.thruster.left.pos.x, self.thruster.left.pos.y)
    
    if self.thruster.left.dir:len() > 60 then
        self.thruster.left.psys:start()
        self.thruster.left.psys:setDirection(dinoAngle + (math.pi / 2))
    end
    if self.thruster.right.dir:len() > 60 then
        self.thruster.right.psys:start()
        self.thruster.right.psys:setDirection(dinoAngle + (math.pi / 2))
    end
    
    self.thruster.left.psys:update(dt)
    self.thruster.right.psys:update(dt)
end

function Dinosaur.right(self)
    self.torso.body:applyImpulse(0, -50, self.torso.body:getX() - 50, self.torso.body:getY())
end

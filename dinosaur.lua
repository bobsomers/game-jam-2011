local gfx = love.graphics
local phys = love.physics
local vector = require "hump.vector"
local class = require "hump.class"

Dinosaur = class(function(self, world, x, y)
    -- create torso
    self.torso = {
        size = vector.new(100, 56)
    }
    self.torso.body = phys.newBody(world, x, y, 10, 15)
    self.torso.shape = phys.newRectangleShape(self.torso.body, 0, 0, self.torso.size.x, self.torso.size.y, 0)
    self.torso.image = gfx.newImage("bront/body1.png")
    self.torso.image:setFilter("nearest", "nearest")
    
    -- create head
    self.head = {
        size = vector.new(42, 42),
        offset = vector.new(-50, -50)
    }
    self.head.body = phys.newBody(world, x + self.head.offset.x, y + self.head.offset.y, 0.000001, 0.000001)
    self.head.shape = phys.newRectangleShape(self.head.body, 0, 0, self.head.size.x, self.head.size.y, 0)
    self.head.joint = love.physics.newRevoluteJoint(self.torso.body, self.head.body, x + self.head.offset.x, y + self.head.offset.y)
    self.head.joint:setMaxMotorTorque(0)
    self.head.joint:setLimits(-math.pi / 6, math.pi / 6)
    self.head.joint:setLimitsEnabled(true)
    self.head.closed = gfx.newImage("bront/head_laser.png")
    self.head.closed:setFilter("nearest", "nearest")
    self.head.open = gfx.newImage("bront/head_laser_awesome.png")
    self.head.open:setFilter("nearest", "nearest")
    self.head.image = self.head.closed
    
    -- create tail
    self.tail = {
        offset = vector.new(40, 0)
    }
    for i = 1, 4 do
        self.tail[i] = {}
        self.tail[i].body = phys.newBody(world, x + self.tail.offset.x + (i * 14), y + self.tail.offset.y, 0.000001, 0.000001)
        self.tail[i].shape = phys.newRectangleShape(self.tail[i].body, 0, 0, 20 - 2 * i, 20 - 2 * i, 0)
        -- if it is the first joint, allow it to rotate a little more than the others
        if i == 1 then
            self.tail[i].joint = love.physics.newRevoluteJoint(self.torso.body, self.tail[i].body, x + self.tail.offset.x + ((i - 1) * 14), y + self.tail.offset.y)
            self.tail[i].joint:setMaxMotorTorque(0)
            self.tail[i].joint:setLimits(-math.pi / 4, math.pi / 4)
            self.tail[i].joint:setLimitsEnabled(true)
        else
        -- otherwise, restrict the rotation of the tail segments
            self.tail[i].joint = love.physics.newRevoluteJoint(self.tail[i - 1].body, self.tail[i].body, x + self.tail.offset.x + ((i - 1) * 14), y + self.tail.offset.y)
            self.tail[i].joint:setLimits(-math.pi / 16, math.pi / 16)
            self.tail[i].joint:setLimitsEnabled(true)
        end
        self.tail[i].image = gfx.newImage("bront/tail" .. i .. ".png")
        self.tail[i].image:setFilter("nearest", "nearest")
    end
    
    -- create thrusters
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
    
    -- create thruster particle systems
    self.thruster.image = love.graphics.newImage("fx/thruster_particle.png")
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
end)

function Dinosaur:draw()
    -- thrusters
    local oldColorMode = love.graphics.getColorMode()
    local oldBlendMode = love.graphics.getBlendMode()
    gfx.setColorMode("modulate")
    gfx.setBlendMode("additive")
    gfx.draw(self.thruster.left.psys, 0, 0)
    gfx.draw(self.thruster.right.psys, 0, 0)
    gfx.setColorMode(oldColorMode)
    gfx.setBlendMode(oldBlendMode)

    -- tail
    for i = 4, 1, -1 do
        gfx.push()
            gfx.translate(self.tail[i].body:getX(), self.tail[i].body:getY())
            gfx.rotate(self.tail[i].body:getAngle())
            gfx.setColor(255, 255, 255)
            gfx.draw(self.tail[i].image, 0, 0, 0, 2, 2, 0, 0)
        gfx.pop()
    end
    
    -- body
    gfx.setColor(255, 255, 255)
    gfx.draw(self.torso.image, self.torso.body:getX(), self.torso.body:getY(), self.torso.body:getAngle(), 2, 2, self.torso.size.x / 4, self.torso.size.y / 4)

    -- head
    gfx.setColor(255, 255, 255)
    gfx.draw(self.head.image, self.head.body:getX(), self.head.body:getY(), self.head.body:getAngle(), 2, 2, self.head.size.x / 4, self.head.size.y / 4)
end


function Dinosaur:update(dt)
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
    
    if self.thruster.left.dir:len() + self.thruster.right.dir:len() < 100 then
        self.head.image = self.head.closed
    else
        self.head.image = self.head.open
    end
    
    self.thruster.left.psys:update(dt)
    self.thruster.right.psys:update(dt)
end

function Dinosaur:right()
    self.torso.body:applyImpulse(0, -45, self.torso.body:getX() - 50, self.torso.body:getY())
end

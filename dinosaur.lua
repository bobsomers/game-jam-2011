local gfx = love.graphics
local phys = love.physics
local vector = require "hump.vector"
local class = require "hump.class"

Foot = class(function(self, world, x, y, footdim, stepsize)
    self.footdim, self.stepsize = footdim, stepsize
    self.location = vector.new(x,y)


    -- wheel
    self.body = phys.newBody(world, x, y, 0.25, 0.0001)
    self.shape = phys.newCircleShape(self.body, x, y, self.stepsize / 2)
    self.shape:setCategory(1)
    self.shape:setMask(1,2,3,4,16)

    -- right foot
    self.right = {}
    self.right.body = phys.newBody(world, x, y+self.stepsize / 2, 2, 0.000)
    self.right.shape = phys.newRectangleShape(self.right.body, 0, 0, self.footdim.x, self.footdim.y, 0)
    self.right.joint = phys.newRevoluteJoint(self.body, 
                                             self.right.body, 
                                             x,
                                             y+self.stepsize / 2)
    self.right.shape:setCategory(2)
    self.right.shape:setMask(1,2,3,4)

    --[[
    -- left foot
    self.left = {}
    self.left.body = phys.newBody(world, x - (self.stepsize / 2), y, 0.0001, 0.0001)
    self.left.shape = phys.newRectangleShape(self.left.body, x, y - (self.stepsize / 2), self.footdim.x, self.footdim.y)
    self.left.joint = phys.newRevoluteJoint(self.body, 
                                             self.left.body, 
                                             x,
                                             y - (self.stepsize / 2))
    self.left.shape:setCategory(2)
    self.left.shape:setMask(1,2,3,4)
    --]]

end)

function Foot:draw()

    -- left
    gfx.push()
        gfx.translate(self.body:getX(), self.body:getY())
        gfx.rotate(self.body:getAngle())
        gfx.setColor(255, 255, 0)
        gfx.circle("fill", 0, 0, self.stepsize / 2)
    gfx.pop()

    --[[
    gfx.push()
        gfx.translate(self.left.body:getX(), self.left.body:getY())
        gfx.rotate(self.left.body:getAngle())
        gfx.setColor(0, 255, 0)
        gfx.rectangle("fill", 0, 0, self.footdim.x / 2, self.footdim.y / 2, self.footdim.x, self.footdim.y)
    gfx.pop()
    --]]

    gfx.push()
        gfx.translate(self.right.body:getX(), self.right.body:getY())
        gfx.rotate(self.right.body:getAngle())
        gfx.setColor(0, 255, 0)
        gfx.rectangle("fill", -self.footdim.x / 2, -self.footdim.y / 2, self.footdim.x, self.footdim.y)
    gfx.pop()

end

Dinosaur = class(function(self, world, x, y)
    -- create torso
    self.torso = {
        size = vector.new(100, 90)
    }
    self.torso.body = phys.newBody(world, x, y, 10, 15)
    self.torso.shape = phys.newRectangleShape(self.torso.body, 0, 0, self.torso.size.x, self.torso.size.y, 0)
    self.torso.image = gfx.newImage("bront/body_missile.png")
    self.torso.image:setFilter("nearest", "nearest")
    self.torso.shape:setCategory(3)
    
    -- create feet
    self.feet = {}
    self.feet.fore = {}
    self.feet.rear = {}

    self.feet.fore.size = vector.new( 32, 16 )
    self.feet.fore.offset = vector.new( 20, 40 )
    self.feet.fore.image = gfx.newImage("bront/foot_fore.png")
    self.feet.fore.image:setFilter("nearest", "nearest")

    self.feet.rear.size = vector.new( 32, 16 )
    self.feet.rear.offset = vector.new( -20, 40 )
    self.feet.rear.image = gfx.newImage("bront/foot_back.png")
    self.feet.rear.image:setFilter("nearest", "nearest")

    -- create front feet
    --self.feet.front = Foot(world, x, y+30, vector.new(60, 20), 40)

    --self.feet.front.joint = phys.newRevoluteJoint(self.feet.front.body, self.torso.body, x, y+30)

    -- create head
    self.head = {
        size = vector.new(42, 42)
    }

    self.neck = {
        seg1 = { size = vector.new(15, 15) },
        seg2 = { size = vector.new(15, 15) },
        base = vector.new(15, 15),
        dist = vector.new(50, -55)
    }

    -- create tail
    self.tail = {
        offset = vector.new(-45, 05)
    }

    offset = vector.new(self.neck.base.x + self.neck.dist.x, self.neck.base.y + self.neck.dist.y)

    self.head.body = phys.newBody(world, x + offset.x, y + offset.y, 0.000001, 0.000001)
    self.head.shape = phys.newRectangleShape(self.head.body, 0, 0, self.head.size.x, self.head.size.y, 0)
    self.head.joint = love.physics.newRevoluteJoint(self.torso.body, self.head.body, x + offset.x, y + offset.y)
    self.head.joint:setMaxMotorTorque(0)
    self.head.joint:setLimits(-math.pi / 6, math.pi / 6)
    self.head.joint:setLimitsEnabled(true)
    self.head.closed = gfx.newImage("bront/head_laser.png")
    self.head.closed:setFilter("nearest", "nearest")
    self.head.open = gfx.newImage("bront/head_laser_awesome.png")
    self.head.open:setFilter("nearest", "nearest")
    self.head.image = self.head.closed
    self.head.shape:setCategory(3)

    midpoint = vector.new(self.neck.base.x + (self.neck.dist.x / 2), self.neck.base.y + (self.neck.dist.y / 2))
    fthird = vector.new(self.neck.base.x + (self.neck.dist.x / 3), self.neck.base.y + (self.neck.dist.y / 3))
    sthird = vector.new(self.neck.base.x + (2 * self.neck.dist.x / 3), self.neck.base.y + (2 * self.neck.dist.y / 3))

    theta_neck = math.atan(self.neck.dist.y / self.neck.dist.x)

    -- segment 1
    self.neck.seg1.body = phys.newBody(world, x + fthird.x, y + fthird.y, 0.000001, 0.000001)
    self.neck.seg1.shape = phys.newRectangleShape(self.neck.seg1.body, 0, 0, 15, 15, 0)
    self.neck.seg1.shape:setCategory(4)
    self.neck.seg1.shape:setMask(1,2,3)
    self.neck.seg1.image = gfx.newImage("bront/tail1.png")
    self.neck.seg1.image:setFilter("nearest", "nearest")
    self.neck.seg1.body:setAngle(theta_neck)


    -- segment 2
    self.neck.seg2.body = phys.newBody(world, x + sthird.x, y + sthird.y, 0.000001, 0.000001)
    self.neck.seg2.shape = phys.newRectangleShape(self.neck.seg2.body, 0, 0, 15, 15, 0)
    self.neck.seg2.shape:setCategory(4)
    self.neck.seg2.shape:setMask(1,2,3)
    self.neck.seg2.image = gfx.newImage("bront/tail2.png")
    self.neck.seg2.image:setFilter("nearest", "nearest")
    self.neck.seg2.body:setAngle(theta_neck)



    self.neck.seg1.joint1 = love.physics.newRevoluteJoint(self.torso.body, 
                                                     self.neck.seg1.body, 
                                                     x + self.neck.base.x, 
                                                     y + self.neck.base.y)

    self.neck.seg1.joint2 = love.physics.newRevoluteJoint(self.neck.seg1.body, 
                                                     self.neck.seg2.body, 
                                                     x + midpoint.x, 
                                                     y + midpoint.y)

    self.neck.seg2.joint4 = love.physics.newRevoluteJoint(self.head.body, 
                                                     self.neck.seg2.body, 
                                                     x + offset.x, 
                                                     y + offset.y)


    for i = 1, 5 do
        self.tail[i] = {}

        if i < 5 then
            self.tail[i].body = phys.newBody(world, x + self.tail.offset.x - (i * 14), y + self.tail.offset.y, 0.000001, 0.000001)
            self.tail[i].shape = phys.newRectangleShape(self.tail[i].body, 0, 0, 20 - 2 * i, 20 - 2 * i, 0)
        else
            self.tail[i].body = phys.newBody(world, x + self.tail.offset.x - (5 * 14) - 50, y + self.tail.offset.y - 10, 0.000001, 0.000001)
            self.tail[i].shape = phys.newRectangleShape(self.tail[i].body, 0, 0, 30, 15, 0)
        end

        self.tail[i].shape:setCategory(4)

        if i < 3 then
            self.tail[i].shape:setMask(1,2,3)
        end


        -- if it is the first joint, allow it to rotate a little more than the others
        if i == 1 then
            self.tail[i].joint = love.physics.newRevoluteJoint(self.torso.body, self.tail[i].body, x + self.tail.offset.x - ((i-1) * 14), y + self.tail.offset.y)
            self.tail[i].joint:setMaxMotorTorque(0)
            self.tail[i].joint:setLimits(-math.pi / 4, math.pi / 4)
            self.tail[i].joint:setLimitsEnabled(true)
            self.tail[i].image = gfx.newImage("bront/tail" .. 1 .. ".png")
        else
        -- otherwise, restrict the rotation of the tail segments
            self.tail[i].joint = love.physics.newRevoluteJoint(self.tail[i - 1].body, self.tail[i].body, x + self.tail.offset.x - ((i - 1) * 14), y + self.tail.offset.y)
            self.tail[i].joint:setMaxMotorTorque(0)
            self.tail[i].joint:setLimits(-math.pi / 16, math.pi / 16)
            self.tail[i].joint:setLimitsEnabled(true)
            self.tail[i].image = gfx.newImage("bront/tail" .. i-1 .. ".png")
        end
        self.tail[i].image:setFilter("nearest", "nearest")
    end
    
    -- create thrusters
    self.thruster = {
        DISTANCE = 25,
        USER_POWER = 150,
        AUTOCORRECT_POWER = 100,
        left = {},
        right = {},
        offset = vector.new(25, 40)
    }
    self.thruster.left.pos = vector.new(self.torso.body:getX() - self.thruster.offset.x, self.torso.body:getY() + self.thruster.offset.y)
    self.thruster.left.dir = vector.new(0, 0)
    self.thruster.right.pos = vector.new(self.torso.body:getX() + self.thruster.offset.x, self.torso.body:getY() + self.thruster.offset.y)
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
	self.thruster.left.psys:setSpread(math.pi / 6)
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
	self.thruster.right.psys:setSpread(math.pi / 6)
	self.thruster.right.psys:setTangentialAcceleration(1000)
	self.thruster.right.psys:setRadialAcceleration(-2000)
	self.thruster.right.psys:stop()
end)

function Dinosaur:draw()

    gfx.setColor(255, 255, 255)

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
    for i = 5, 1, -1 do
        gfx.push()
            gfx.translate(self.tail[i].body:getX(), self.tail[i].body:getY())
            gfx.rotate(self.tail[i].body:getAngle())
            gfx.setColor(255, 255, 255)
            gfx.draw(self.tail[i].image, 0, 0, 0, 2, 2, 0, 0)
        gfx.pop()
    end
    
    -- feet
    local fore = self.feet.fore

    gfx.setColor(255, 255, 255)
    gfx.push()
    gfx.translate(self.torso.body:getX(), self.torso.body:getY())
    gfx.rotate(self.torso.body:getAngle())
    gfx.draw(fore.image, fore.offset.x, fore.offset.y, 0, 2, 2, fore.size.x / 4, fore.size.y / 4)
    gfx.pop()

    local rear = self.feet.rear

    gfx.setColor(255, 255, 255)
    gfx.push()
    gfx.translate(self.torso.body:getX(), self.torso.body:getY())
    gfx.rotate(self.torso.body:getAngle())
    gfx.draw(fore.image, rear.offset.x, rear.offset.y, 0, 2, 2, rear.size.x / 4, rear.size.y / 4)
    gfx.pop()


    -- body
    gfx.setColor(255, 255, 255)
    gfx.push()
    gfx.translate(self.torso.body:getX(), self.torso.body:getY())
    gfx.rotate(self.torso.body:getAngle())
    gfx.draw(self.torso.image, 0, -5, 0, 2, 2, self.torso.size.x / 4, self.torso.size.y / 4)
    gfx.pop()
    
    -- neck seg2
    gfx.setColor(255, 255, 255)
    gfx.draw(self.neck.seg2.image, self.neck.seg2.body:getX(), self.neck.seg2.body:getY(), self.neck.seg2.body:getAngle(), 2, 2, self.neck.seg2.size.x / 4, self.neck.seg2.size.y / 4)
    
    -- neck seg1
    gfx.setColor(255, 255, 255)
    gfx.draw(self.neck.seg1.image, self.neck.seg1.body:getX(), self.neck.seg1.body:getY(), self.neck.seg1.body:getAngle(), 2, 2, self.neck.seg1.size.x / 4, self.neck.seg1.size.y / 4)

    -- head
    gfx.setColor(255, 255, 255)
    gfx.draw(self.head.image, self.head.body:getX(), self.head.body:getY(), self.head.body:getAngle(), 2, 2, self.head.size.x / 4, self.head.size.y / 4)


    gfx.setColor(255, 255, 255)
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
    if kb.isDown("a") and gameState == "playing" then
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
    
    if kb.isDown("d") and gameState == "playing" then
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

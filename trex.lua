local gfx = love.graphics
local phys = love.physics
local vector = require "hump.vector"
local class = require "hump.class"

Trex = class(function(self, world, x, y, xmin, xmax)
    -- create torso
    self.torso = {
        size = vector.new(70, 70)
    }

    self.xmin, self.xmax = xmin, xmax

    self.torso.body = phys.newBody(world, x, y, 10, 15)
    self.torso.shape = phys.newRectangleShape(self.torso.body, 0, 0, self.torso.size.x, self.torso.size.y, 0)
    self.torso.image = gfx.newImage("trex/body.png")
    self.torso.image:setFilter("nearest", "nearest")
    self.torso.shape:setCategory(8)
    
    -- create feet
    self.feet = {}
    self.feet.fore = {}
    self.feet.rear = {}

    self.feet.anim_theta = 0
    self.feet.stepsize = 8
    self.feet.anim_direction = 1
    self.feet.anim_speed = 2

    self.feet.fore.size = vector.new( 36, 36 )
    self.feet.fore.offset = vector.new( 15, 20 )
    self.feet.fore.image = gfx.newImage("trex/foot_fore.png")
    self.feet.fore.image:setFilter("nearest", "nearest")

    self.feet.rear.size = vector.new( 36, 36 )
    self.feet.rear.offset = vector.new( -10, 20 )
    self.feet.rear.image = gfx.newImage("trex/foot_back.png")
    self.feet.rear.image:setFilter("nearest", "nearest")

    -- create front feet
    --self.feet.front = Foot(world, x, y+30, vector.new(60, 20), 40)

    --self.feet.front.joint = phys.newRevoluteJoint(self.feet.front.body, self.torso.body, x, y+30)

    -- create head
    self.head = {
        size = vector.new(42, 42)
    }

    self.head.anim_face = 1

    self.neck = {
        seg1 = { size = vector.new(15, 15) },
        seg2 = { size = vector.new(15, 15) },
        base = vector.new(15, -15),
        dist = vector.new(30, -45)
    }

    -- create tail
    self.tail = {
        offset = vector.new(-40, -15)
    }

    offset = vector.new(self.neck.base.x + self.neck.dist.x, self.neck.base.y + self.neck.dist.y)

    self.head.body = phys.newBody(world, x + offset.x, y + offset.y, 0.000001, 0.000001)
    self.head.shape = phys.newRectangleShape(self.head.body, 0, 0, self.head.size.x, self.head.size.y, 0)
    self.head.joint = love.physics.newRevoluteJoint(self.torso.body, self.head.body, x + offset.x, y + offset.y)
    self.head.joint:setMaxMotorTorque(0)
    self.head.joint:setLimits(-math.pi / 6, math.pi / 6)
    self.head.joint:setLimitsEnabled(true)
    self.head.closed = gfx.newImage("trex/head1.png")
    self.head.closed:setFilter("nearest", "nearest")
    self.head.open = gfx.newImage("trex/head_panic_right.png")
    self.head.open:setFilter("nearest", "nearest")
    self.head.image = self.head.closed
    self.head.shape:setCategory(8)

    midpoint = vector.new(self.neck.base.x + (self.neck.dist.x / 2), self.neck.base.y + (self.neck.dist.y / 2))
    fthird = vector.new(self.neck.base.x + (self.neck.dist.x / 3), self.neck.base.y + (self.neck.dist.y / 3))
    sthird = vector.new(self.neck.base.x + (2 * self.neck.dist.x / 3), self.neck.base.y + (2 * self.neck.dist.y / 3))

    theta_neck = math.atan(self.neck.dist.y / self.neck.dist.x)

    -- segment 1
    self.neck.seg1.body = phys.newBody(world, x + fthird.x, y + fthird.y, 0.000001, 0.000001)
    self.neck.seg1.shape = phys.newRectangleShape(self.neck.seg1.body, 0, 0, 15, 15, 0)
    self.neck.seg1.shape:setCategory(9)
    self.neck.seg1.shape:setMask(6,7,8)
    self.neck.seg1.image = gfx.newImage("trex/tail1.png")
    self.neck.seg1.image:setFilter("nearest", "nearest")
    self.neck.seg1.body:setAngle(theta_neck)


    -- segment 2
    self.neck.seg2.body = phys.newBody(world, x + sthird.x, y + sthird.y, 0.000001, 0.000001)
    self.neck.seg2.shape = phys.newRectangleShape(self.neck.seg2.body, 0, 0, 15, 15, 0)
    self.neck.seg2.shape:setCategory(9)
    self.neck.seg2.shape:setMask(6,7,8)
    self.neck.seg2.image = gfx.newImage("trex/tail2.png")
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

        self.tail[i].body = phys.newBody(world, x + self.tail.offset.x - (i * 14), y + self.tail.offset.y, 0.000001, 0.000001)
        self.tail[i].shape = phys.newRectangleShape(self.tail[i].body, 0, 0, 20 - 2 * i, 20 - 2 * i, 0)

        self.tail[i].shape:setCategory(9)

        if i < 3 then
            self.tail[i].shape:setMask(6,7,8)
        end


        -- if it is the first joint, allow it to rotate a little more than the others
        if i == 1 then
            self.tail[i].joint = love.physics.newRevoluteJoint(self.torso.body, self.tail[i].body, x + self.tail.offset.x - ((i-1) * 14), y + self.tail.offset.y)
            self.tail[i].joint:setMaxMotorTorque(0)
            self.tail[i].joint:setLimits(-math.pi / 4, math.pi / 4)
            self.tail[i].joint:setLimitsEnabled(true)
            self.tail[i].image = gfx.newImage("trex/tail" .. 1 .. ".png")
        else
        -- otherwise, restrict the rotation of the tail segments
            self.tail[i].joint = love.physics.newRevoluteJoint(self.tail[i - 1].body, self.tail[i].body, x + self.tail.offset.x - ((i - 1) * 14), y + self.tail.offset.y)
            self.tail[i].joint:setMaxMotorTorque(0)
            self.tail[i].joint:setLimits(-math.pi / 16, math.pi / 16)
            self.tail[i].joint:setLimitsEnabled(true)
            self.tail[i].image = gfx.newImage("trex/tail" .. i-1 .. ".png")
        end
        self.tail[i].image:setFilter("nearest", "nearest")
    end
    
end)

function Trex:draw()

    gfx.setColor(255, 255, 255)

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
    gfx.draw(fore.image, 
             self.feet.fore.pos.x, 
             self.feet.fore.pos.y, 0, 2, 2, 
             fore.size.x / 4, fore.size.y / 4)
    gfx.pop()

    local rear = self.feet.rear

    gfx.setColor(255, 255, 255)
    gfx.push()
    gfx.translate(self.torso.body:getX(), self.torso.body:getY())
    gfx.rotate(self.torso.body:getAngle())
    gfx.draw(rear.image, 
             self.feet.rear.pos.x, 
             self.feet.rear.pos.y, 0, 2, 2, 
             rear.size.x / 4, rear.size.y / 4)
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

    if self.head.anim_face == 1 then
        gfx.draw(self.head.image, self.head.body:getX(), self.head.body:getY(), self.head.body:getAngle(), 2, 2, self.head.size.x / 4, self.head.size.y / 4)
    else
        gfx.draw(self.head.open, self.head.body:getX(), self.head.body:getY(), self.head.body:getAngle(), 2, 2, self.head.size.x / 4, self.head.size.y / 4)
    end

    gfx.setColor(255, 255, 255)
end


function Trex:update(dt)
    local kb = love.keyboard

    self.torso.body:applyForce(100 * self.feet.anim_direction, 0, self.torso.body:getX(), self.torso.body:getY())

    self.feet.anim_theta = self.feet.anim_theta + 2 * math.pi * dt * self.feet.anim_direction * self.feet.anim_speed

    if self.feet.anim_theta > 2 * math.pi then
        self.feet.anim_theta = self.feet.anim_theta - (2 * math.pi)
    end

    if self.torso.body:getX() > self.xmax then
        self.feet.anim_direction = -1
    elseif self.torso.body:getX() < self.xmin then
        self.feet.anim_direction = 1
    end

    local stepcos = math.cos(self.feet.anim_theta)
    local stepcos2 = math.cos(self.feet.anim_theta + math.pi)

    if stepcos < 0 then stepcos = 0 end
    if stepcos2 < 0 then stepcos2 = 0 end

    self.feet.fore.pos = vector.new(self.feet.fore.offset.x + math.sin(self.feet.anim_theta) * self.feet.stepsize, 
                                    self.feet.fore.offset.y - stepcos * self.feet.stepsize)

    self.feet.rear.pos = vector.new(self.feet.rear.offset.x + math.sin(self.feet.anim_theta + math.pi) * self.feet.stepsize, 
                                    self.feet.rear.offset.y - stepcos2 * self.feet.stepsize)

    if self.feet.anim_theta > math.pi then
        self.head.anim_face = 2
    else
        self.head.anim_face = 1
    end

end


-- template dinosaur dataset
Dinosaur = {}

local gfx = love.graphics
local phys = love.physics
local vector = hump.vector

function Dinosaur:new (o)

    o = o or { 
                THRUSTER_DIST = 20,
                head = {},
                foot = {},
                torso = {}
             }

    setmetatable(o, self)
    self.__index = self

    return o
end

function Dinosaur.initTorso(self, x, y)

    self.torso.body = phys.newBody(world, x, y, 10, 15)
    self.torso.shape = phys.newRectangleShape(dino.torso.body, 0, 0, 100, 50, 0)
    self.thrusterLpos = vector.new(dino.torso.body:getX() - dino.THRUSTER_DIST, dino.torso.body:getY())
    self.thrusterRpos = vector.new(dino.torso.body:getX() + dino.THRUSTER_DIST, dino.torso.body:getY())
    self.thrusterLdir = vector.new(0, 0)
    self.thrusterRdir = vector.new(0, 0)

    self.foot.body = phys.newBody(world, x, y - 25, 5, 7)
    self.foot.shape = phys.newRectangleShape(dino.foot.body, 0, 0, 50, 50, 0)

    joint = love.physics.newDistanceJoint( self.torso.body, self.foot.body, x, y, x, y-25 )

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
        gfx.push()
        gfx.translate(self.foot.body:getX(), self.foot.body:getY())
        gfx.rotate(self.foot.body:getAngle())
        gfx.setColor(0, 255, 0)
        gfx.rectangle("fill", -25, -25, 50, 50)
        gfx.pop()


end

function Dinosaur.update(self, dt)
    local kb = love.keyboard

    dinoAngle = self.torso.body:getAngle()

    -- calculate correction factor
    --[[
    correction = dino.torso.body:getAngle() % (2 * math.pi)
    if correction >= math.pi / 2 and correction <= 3 * math.pi / 2 then
        correction = 0
    elseif correction > 3 * math.pi / 2 then
        correction = 2 * math.pi - correction
    end
    correction = correction / (math.pi / 2)
    --]]
    
    -- calculate thruster positions and directions
    self.thrusterLpos = vector.new(self.torso.body:getX() - self.THRUSTER_DIST * math.cos(dinoAngle),
                                   self.torso.body:getY() - self.THRUSTER_DIST * math.sin(dinoAngle))
    self.thrusterRpos = vector.new(self.torso.body:getX() + self.THRUSTER_DIST * math.cos(dinoAngle),
                                   self.torso.body:getY() + self.THRUSTER_DIST * math.sin(dinoAngle))
    
    if kb.isDown("a") then
        -- apply thrust on the right
        self.thrusterRdir = vector.new(-100 * math.cos(dinoAngle + (math.pi / 2)),
                                       -100 * math.sin(dinoAngle + (math.pi / 2)))
        self.torso.body:applyForce(self.thrusterRdir.x, self.thrusterRdir.y, self.thrusterRpos.x, self.thrusterRpos.y)
        
    else
        self.thrusterRdir = vector.new(0, 0)
    end
    
    if kb.isDown("d") then
        -- apply thrust on the left
        self.thrusterLdir = vector.new(-100 * math.cos(dinoAngle + (math.pi / 2)),
                                       -100 * math.sin(dinoAngle + (math.pi / 2)))
        self.torso.body:applyForce(self.thrusterLdir.x, self.thrusterLdir.y, self.thrusterLpos.x, self.thrusterLpos.y)
    else
        self.thrusterLdir = vector.new(0, 0)
    end

    if love.keyboard.isDown("s") then
        self.torso.body:applyImpulse(0, -20, self.torso.body:getX(), self.torso.body:getY())
    end

end

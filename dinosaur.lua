
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
    self.thrusterL = vector.new(dino.torso.body:getX() - dino.THRUSTER_DIST, dino.torso.body:getY())
    self.thrusterR = vector.new(dino.torso.body:getX() + dino.THRUSTER_DIST, dino.torso.body:getY())

    self.foot.body = phys.newBody(world, x, y + 25, 2, 3)
    self.foot.shape = phys.newRectangleShape(dino.foot.body, 0, 0, 50, 50, 0)

    --joint = love.physics.newDistanceJoint( self.torso.body, self.foot.body, x+25, y, x, y+25 )
    --joint2 = love.physics.newDistanceJoint( self.torso.body, self.foot.body, x-25, y, x, y+25 )
    --joint = love.physics.newWeldJoint( self.torso.body, self.foot.body )

    self.tail = {}

    for i=1,1 do
        self.tail[i] = {}
        self.tail[i].body = phys.newBody(world, x + 50 + (i * 15), y, 0.000001, 0.000001)
        self.tail[i].shape = phys.newRectangleShape(self.tail[i].body, 0, 0, 20 - 2*i, 20 - 2*i, 0)

        if i > 1 then
            --self.tail[i].joint = love.physics.newRevoluteJoint( self.tail[i-1].body, self.tail[i].body, x + 50 + ((i-1) * 15), y )
        else
            --self.tail[i].joint = love.physics.newRevoluteJoint( self.torso.body, self.tail[i].body, x + 50 + ((i-1) * 15), y )
        end
    end

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

    for i=1,1 do
        gfx.push()
        gfx.translate(self.tail[i].body:getX(), self.tail[i].body:getY())
        gfx.rotate(self.tail[i].body:getAngle())
        gfx.setColor(0, 0, 255)
        --gfx.rectangle("fill", -5, -5, 20 - 2*i, 20 - 2*i)
        gfx.setColor(255, 255, 255)
        gfx.draw(resources["tail01"], 0, 0, 0, 2, 2, -5, -5)
        gfx.pop()
    end


end

function Dinosaur.update(self, dt)

    dinoAngle = self.torso.body:getAngle()

    if love.keyboard.isDown("a") or love.keyboard.isDown("d") then

        dino.thrusterL = vector.new(self.torso.body:getX() - self.THRUSTER_DIST * math.cos(dinoAngle),
                                    self.torso.body:getY() - self.THRUSTER_DIST * math.sin(dinoAngle))
        dino.thrusterR = vector.new(self.torso.body:getX() + self.THRUSTER_DIST * math.cos(dinoAngle),
                                    self.torso.body:getY() + self.THRUSTER_DIST * math.sin(dinoAngle))
        
        -- "d" controls the left thruster
        if love.keyboard.isDown("d") then
            self.torso.body:applyForce(-100 * math.cos(dinoAngle + (math.pi / 2)), 
                                       -100 * math.sin(dinoAngle + (math.pi / 2)), 
                                       self.thrusterL.x, self.thrusterL.y)
        end
        
        -- "a" controls the right thruster
        if love.keyboard.isDown("a") then
            self.torso.body:applyForce(-100 * math.cos(dinoAngle + (math.pi / 2)), 
                                       -100 * math.sin(dinoAngle + (math.pi / 2)), 
                                       self.thrusterR.x, self.thrusterR.y)
        end
    end

    if love.keyboard.isDown("s") then
        self.torso.body:applyImpulse(0, -20, self.torso.body:getX(), self.torso.body:getY())
    end

end

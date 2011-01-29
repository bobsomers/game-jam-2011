
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


    -- left leg
    gfx.push()
    gfx.translate(0, 25, 0)
    gfx.setColor(0, 255, 0)
    gfx.rectangle("fill", -25, -25, 50, 50)
    gfx.pop()

end

function Dinosaur.update(self, dt)

    dinoAngle = dino.torso.body:getAngle()

    if love.keyboard.isDown("a") or love.keyboard.isDown("d") then
        -- calculate thruster positions and swap if necessary
        dino.thrusterL = vector.new(dino.torso.body:getX() - dino.THRUSTER_DIST * math.cos(dinoAngle),
                                    dino.torso.body:getY() - dino.THRUSTER_DIST * math.sin(dinoAngle))
        dino.thrusterR = vector.new(dino.torso.body:getX() + dino.THRUSTER_DIST * math.cos(dinoAngle),
                                    dino.torso.body:getY() + dino.THRUSTER_DIST * math.sin(dinoAngle))
        if dino.thrusterL.x > dino.thrusterR.x then
            dino.thrusterL, dino.thrusterR = dino.thrusterR, dino.thrusterL
        end
        
        -- "d" controls the left thruster
        if love.keyboard.isDown("d") then
            dino.torso.body:applyForce(-100 * math.cos(dinoAngle + (math.pi / 2)), -100 * math.sin(dinoAngle + (math.pi / 2)), dino.thrusterL.x, dino.thrusterL.y)
        end
        
        -- "a" controls the right thruster
        if love.keyboard.isDown("a") then
            dino.torso.body:applyForce(-100 * math.cos(dinoAngle + (math.pi / 2)), -100 * math.sin(dinoAngle + (math.pi / 2)), dino.thrusterR.x, dino.thrusterR.y)
        end
    end

    if love.keyboard.isDown("s") then
        dino.torso.body:applyImpulse(0, -20, dino.torso.body:getX(), dino.torso.body:getY())
    end

end

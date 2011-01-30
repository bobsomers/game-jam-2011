local gfx = love.graphics
local phys = love.physics
local vector = require "hump.vector"
local class = require "hump.class"

Missile = class(function(self, world, x, y, angle, vel, index, left)
    local offset = vector.new(15, -35)
    offset = offset:rotated(angle)

    if left then
        offset = vector.new(0, 0)
    end
    
    self.body = phys.newBody(world, x + offset.x, y + offset.y, 5, 10)
    self.shape = phys.newRectangleShape(self.body, 0, 0, 32, 20, 0)
    self.image = gfx.newImage("fx/missile.png")
    self.image:setFilter("nearest", "nearest")
    if not left then
        self.body:setAngle(angle)
    else
        self.body:setAngle(angle + math.pi)
    end
    self.body:setLinearVelocity(vel.x, vel.y)
    self.shape:setCategory(5)
    self.shape:setMask(1, 2, 3, 4)
    self.shape:setData({
        kind = "missile",
        i = index
    })
    self.power = 300
    self.shove = 40
    
    -- give it an initial shove vertically away from the dino
    if not left then
        local shovedir = vector.new(math.cos(self.body:getAngle() - math.pi / 2), math.sin(self.body:getAngle() - math.pi / 2))
        shovedir:normalize_inplace()
        self.body:applyImpulse(self.shove * shovedir.x, self.shove * shovedir.y)
    end
    
    -- smoke trail particle system
    self.smoke = {}
    self.smoke.image = love.graphics.newImage("fx/thruster_particle.png")
    self.smoke.psys = love.graphics.newParticleSystem(self.smoke.image, 1000)
    self.smoke.psys:setEmissionRate(1000)
    self.smoke.psys:setSpeed(400, 500)
	self.smoke.psys:setSize(0.5, 0.5)
	self.smoke.psys:setColor(62, 62, 62, 255, 152, 152, 152, 0)
	self.smoke.psys:setPosition(x, y)
	self.smoke.psys:setLifetime(0.1)
	self.smoke.psys:setParticleLife(0.2)
	self.smoke.psys:setDirection(math.pi / 2)
	self.smoke.psys:setSpread(math.pi / 6)
	self.smoke.psys:setTangentialAcceleration(1000)
	self.smoke.psys:setRadialAcceleration(-2000)
	self.smoke.psys:stop()
end)

function Missile:update(dt)
    -- update missle
    local force = vector.new(math.cos(self.body:getAngle() + math.pi), math.sin(self.body:getAngle() + math.pi))
    force:normalize_inplace()
    self.body:applyForce(self.power * -force.x, self.power * -force.y)
    
    -- update shape data with position
    local data = self.shape:getData()
    data.pos = vector.new(self.body:getX(), self.body:getY())
    self.shape:setData(data)
    
    -- update smoke trail
    self.smoke.psys:setPosition(self.body:getX(), self.body:getY())
    self.smoke.psys:setDirection(self.body:getAngle() + math.pi)
    self.smoke.psys:start()
    self.smoke.psys:update(dt)
end

function Missile:draw()
    -- draw smoke trail
    local oldColorMode = love.graphics.getColorMode()
    local oldBlendMode = love.graphics.getBlendMode()
    gfx.setColorMode("modulate")
    gfx.setBlendMode("additive")
    gfx.draw(self.smoke.psys, 0, 0)
    gfx.setColorMode(oldColorMode)
    gfx.setBlendMode(oldBlendMode)

    -- draw sprite
    gfx.setColor(255, 255, 255)
    gfx.draw(self.image, self.body:getX(), self.body:getY(), self.body:getAngle(), 2, 2, 32 / 4, 20 / 4)
end

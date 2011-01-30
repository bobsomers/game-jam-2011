local gfx = love.graphics
local phys = love.physics
local vector = require "hump.vector"
local class = require "hump.class"

Explosion = class(function(self, x, y)
    -- particle system
    self.image = love.graphics.newImage("fx/thruster_particle.png")
    self.spawnTime = love.timer.getTime()
    self.psys = love.graphics.newParticleSystem(self.image, 1000)
    self.psys:setEmissionRate(1000)
    self.psys:setSpeed(300, 400)
	self.psys:setSize(2, 1)
	self.psys:setColor(220, 105, 20, 255, 194, 30, 18, 0)
	self.psys:setPosition(x, y)
	self.psys:setLifetime(0.1)
	self.psys:setParticleLife(0.2)
	self.psys:setDirection(0)
	self.psys:setSpread(2 * math.pi)
	self.psys:setTangentialAcceleration(1000)
	self.psys:setRadialAcceleration(-2000)
	self.psys:start()
end)

function Explosion:update(dt)
    self.psys:update(dt)
end

function Explosion:draw()
    -- draw smoke trail
    local oldColorMode = love.graphics.getColorMode()
    local oldBlendMode = love.graphics.getBlendMode()
    gfx.setColorMode("modulate")
    gfx.setBlendMode("additive")
    gfx.draw(self.psys, 0, 0)
    gfx.setColorMode(oldColorMode)
    gfx.setBlendMode(oldBlendMode)
end

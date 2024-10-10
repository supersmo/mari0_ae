tether = class:new()

function tether:init(p1, p2, color)
    self.p1 = p1
    self.p2 = p2
	self.springextension = 0  -- How far the spring is currently stretched or compressed.
	self.color = color
	print("color: " .. tostring(self.color), " p1: " .. self.p1.playernumber.. " p2: " .. self.p2.playernumber)
end

function tether:update(dt)
	-- apply teathered death.
	if tethereddeath and tetheredplayers > 1 and not everyonedead then
		if self.p1.dead and not self.p2.dead then
			self.p2:die("lava")
		elseif self.p2.dead and not self.p1.dead then
			self.p1:die("lava")
		end
	end

	if tetherenabled == false then
		self.tethered = false
		return false
	end
	if tetheredplayers < 2 or self.p1 == nil or self.p2 == nil or self.p1.dead or self.p2.dead then
		self.tethered = false
		return false
	end
	self.tethered = true
	
    -- get springextention length
    local dx = self.p2.x-self.p1.x
    local dy = self.p1.y-self.p2.y
    local length = math.max(0, math.sqrt(dx*dx + dy*dy)-tetherlength)
    self.springextension = length

    if length <= 0 then
		return false
	end
    self.springstretched = true

    --get angle from p1 to p2
    local tetherangle = math.atan2(dy, dx)

    self:updateplayer(self.p1, tetherangle, length, dt)
    self:updateplayer(self.p2, tetherangle + math.pi, length, dt)
end

function tether:updateplayer(p, angle, length, dt)
	if (not p.controlsenabled) or p.vine or p.fence then
		return false
	end

	-- calculate optimal damping for when a character is hanging by the spring.
	local mass = p.size
	local damping = math.sqrt(4*mass*tetherstiffness)
	damping = damping*tetherdampingcoefficient --lower damping because optimal is boring

	-- calculate forces
	-- positive force y is updwards. Negate this later to apply to screen coordinates
    -- calculate tether force
	local springforcemagnitude = length*tetherstiffness
	local springforcex = math.cos(angle)*springforcemagnitude
	local springforcey = math.sin(angle)*springforcemagnitude
	local dampingforcex = -damping*p.speedx
	local dampingforcey = damping*p.speedy
	
	-- apply forces
	local xadd = (springforcex + dampingforcex)*dt/mass
	local yadd = -(springforcey + dampingforcey)*dt/mass --negate because of screen coordinates

	--print("p " .. p.playernumber .. "; " .. " size: " .. p.size .. "; position: (" .. p.x .. "," .. p.y .. "); angle: " .. angle*180/math.pi .. "; stretch: ".. length .. "springforce:(" .. springforcex .. "," .. springforcey .. ")" .. "; dampingforce: (" .. dampingforcex .. "," .. dampingforcey .. ")" .. "; speed: (" .. p.speedx .. "," .. p.speedy .. ")")

	p.speedx = p.speedx + xadd
	p.speedy = p.speedy + yadd
end

function tether:draw()
	if  self.tethered then
		love.graphics.setColor(self.color)
		local linewidth=4
		if self.springextension > 0 then
			linewidth = math.max(4 - 1*self.springextension,1)
		end
		love.graphics.setLineWidth(linewidth)
		love.graphics.line(math.floor(((self.p1.x-xscroll)*16+self.p1.offsetX)*scale), math.floor(((self.p1.y-yscroll)*16-self.p1.offsetY)*scale), math.floor(((self.p2.x-xscroll)*16+self.p2.offsetX)*scale), math.floor(((self.p2.y-yscroll)*16-self.p2.offsetY)*scale))
	end
end
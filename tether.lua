tether = class:new()

function tether:init(p1, p2, tethergroup)
    self.p1 = p1
    self.p2 = p2
	self.springlength = 0
	local numberoftethers = math.ceil(players/tetheredplayers)
	self.color = (1-(tethergroup-1)/(numberoftethers-1))*0.5+0.5 -- shades of grey. 50% white to 100% white 
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

	if tetheredplayers < 2 or self.p1 == nil or self.p2 == nil or self.p1.dead or self.p2.dead then
		self.tethered = false
		return false
	end
	self.tethered = true
	
    -- get springextention length
    local dx = self.p2.x-self.p1.x
    local dy = self.p1.y-self.p2.y
    local length = math.max(0, math.sqrt(dx*dx + dy*dy)-tetherlength)
    self.springlength = length

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
	--damping = damping*0.25 --lower damping because optimal is boring
	damping = damping*0.05 --lower damping because optimal is boring

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
		love.graphics.setColor(self.color, self.color, self.color)
		local linewidth=4
		if self.springlength > 0 then
			linewidth = math.max(4 - 1*self.springlength,1)
		end
		love.graphics.setLineWidth(linewidth)
		love.graphics.line(math.floor(((self.p1.x-xscroll)*16+self.p1.offsetX)*scale), math.floor(((self.p1.y-yscroll)*16-self.p1.offsetY)*scale), math.floor(((self.p2.x-xscroll)*16+self.p2.offsetX)*scale), math.floor(((self.p2.y-yscroll)*16-self.p2.offsetY)*scale))
	end
end
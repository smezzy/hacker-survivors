Spring =  Class:extend()

--t represents tension, higher the tension, the stiffer it gets
--x is the target value for the spring, 0 is fine for most cases since you'ill be adding it to other values like scale
--d is the dampening, the higher the dampening the spring will move slower, kinda how fast it ocilates
--v is the velocity
--f is the force of the pulling
--a is the displacement

function Spring:new(x, t, d)
   self.x = x or 0
   self.t = t or 500
   self.d = d or 20
   self.target_x = self.x
   self.v = 0
end


function Spring:update(dt)
   local a = -self.t*(self.x - self.target_x) - self.d*self.v
   self.v = self.v + a * dt
   self.x = self.x + self.v * dt
end

function Spring:pull(f, t, d)
   if t then self.t = t end
   if d then self.d = d end
   self.v = self.v + f
end

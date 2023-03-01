Sparks = Class:extend()
Sparks:implement(GameObject)

function Sparks:new(args)
    self:init_game_obj(args)
    self.speed = self.speed or love.math.random(3, 6)
    self.r = randomdir(-math.pi, math.pi)
    self.scale = self.scale or 2
    self.velocity = self.velocity or 60
    self.points = {}
    self.color = self.color or colors.fg
end

function Sparks:update(dt)
    local movex, movey = self:calculate_movement(dt)
    self.x = self.x + movex * self.velocity
    self.y = self.y + movey * self.velocity
    -- self.r = self.r + 3 * dt
    self.speed = self.speed - 5 * dt

    self.points = {
        self.x + math.cos(self.r) * self.speed * self.scale, self.y + math.sin(self.r) * self.speed * self.scale,
        self.x + math.cos(self.r + math.pi / 2) * self.speed * self.scale * 0.3,
        self.y + math.sin(self.r + math.pi / 2) * self.speed * self.scale * 0.3,
        self.x - math.cos(self.r) * self.speed * self.scale * 3.5,
        self.y - math.sin(self.r) * self.speed * self.scale * 3.5,
        self.x + math.cos(self.r - math.pi / 2) * self.speed * self.scale * 0.3,
        self.y - math.sin(self.r + math.pi / 2) * self.speed * self.scale * 0.3,
    }
    if self.speed < 0 then self.remove = true end
end

function Sparks:calculate_movement(dt)
    return math.cos(self.r) * self.speed * dt, math.sin(self.r) * self.speed * dt
end

function Sparks:draw()
    if self.remove then return end
    love.graphics.push()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    love.graphics.polygon("fill", self.points)
    love.graphics.setColor(1, 1, 1)
    love.graphics.pop()
end

HitParticle = Class:extend()
HitParticle:implement(GameObject)

function HitParticle:new(args)
    self:init_game_obj(args)
    self.color = self.color or colors.fg
    self.lifetime = self.lifetime or 0.15
    self.angle = math.atan2(self.y_vel, self.x_vel)
    self.t:tween(self.lifetime, self, { w = 0 }, 'in-quad')
    self.t:after(self.lifetime, function() self.dead = true end)
end

function HitParticle:update(dt)
    self:update_game_obj(dt)
    self.x = self.x + self.x_vel * self.speed * dt
    self.y = self.y + self.y_vel * self.speed * dt
end

function HitParticle:draw()
    graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
    graphics.rectangle(self.x, self.y, self.w, self.h, 0, 0, self.color)
    graphics.pop()
end

HitCircle = Class:extend()
HitCircle:implement(GameObject)

function HitCircle:new(args)
    self:init_game_obj(args)
    self.radius = self.radius or 10
    self.lw = self.radius or 10
    self.max = self.radius * 3
    self.color = assets.color_effects
end

function HitCircle:update(dt)
    self:update_game_obj(dt)
    if self.radius > self.max then
        self.dead = true
        return
    end
    self.lw = self.lw - dt * 80
    if self.lw < 0 then
        self.lw = 0
    end
    self.radius = self.radius + 80 * dt
end

function HitCircle:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    love.graphics.setLineWidth(self.lw)
    love.graphics.circle("line", self.x, self.y, self.radius)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1)
end

HitSquare = Class:extend()
HitSquare:implement(GameObject)

function HitSquare:new(args)
    self:init_game_obj(args)
    self.color = self.color or colors.fg
    self.t:after(self.duration, function() self.dead = true end)
    self.t:tween(self.duration, self, { h = self.h*2, w = self.w*2 }, 'out-cubic')
end

function HitSquare:update(dt)
    self:update_game_obj(dt)
end

function HitSquare:draw()
    graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
    graphics.rectangle(self.x, self.y, self.w, self.h, 0, 0, self.color, 2)
    graphics.pop()
end

MuzzleFlash = Class:extend()
MuzzleFlash:implement(GameObject)

function MuzzleFlash:new(args)
    self:init_game_obj(args)
    self.color = self.color or colors.fg
    self.lifetime = self.lifetime or 0.15
    self.t:tween(self.lifetime, self, { radius = 0 }, 'out-cubic')
    self.t:after(self.lifetime + 0.05, function() self.dead = true end)
end

function MuzzleFlash:update(dt)
    self:update_game_obj(dt)
    if self.parent then
        self.x = self.parent.firepointx
        self.y = self.parent.firepointy
    end
end

function MuzzleFlash:draw()
    graphics.circle(self.x, self.y, self.radius, self.color)
end

MuzzleFlashII = Class:extend()
MuzzleFlashII:implement(GameObject)

function MuzzleFlashII:new(args)
    self:init_game_obj(args)
    self.color = self.color or colors.fg
    self.angle = self.angle + math.pi / 4
    self.t:tween(0.1, self, { sx = 0 }, 'in-cubic')
    self.t:after(0.1, function() self.dead = true end)
end

function MuzzleFlashII:update(dt)
    self:update_game_obj(dt)
end

function MuzzleFlashII:draw()
    graphics.push(self.x, self.y, 0, 1, 1)
    -- love.graphics.rotate(self.angle)
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    love.graphics.scale(self.sx, self.sy)
    love.graphics.rotate(math.pi / 4)
    love.graphics.translate(-self.x, -self.y)
    graphics.rectangle(self.x, self.y, self.w, self.h, 0, 0, self.color)
    graphics.pop()
end

LightningLine = Class:extend()
LightningLine:implement(GameObject)

function LightningLine:new(args)
    self:init_game_obj(args)
    self.lw = args.lw or 2.5
    self.lines = {}
    self.x, self.y = (self.x1+self.x2)/2, (self.y1+self.y2)/2
    table.insert(self.lines, {x1 = self.x1, y1 = self.y1, x2 = self.x2, y2 = self.y2})
    self.color = self.color or colors.white
    self.generations = self.generations or 4
    self.max_offset = self.max_offset or 8
    self:generate()
    self.duration = self.duration or 0.15
    self.alpha = 1
    self.t:tween(self.duration, self, {alpha = 0}, 'in-out-cubic', function() self.dead = true end)
end

function LightningLine:update(dt)
    self:update_game_obj(dt)
end

function LightningLine:generate()
    local offset_amount = self.max_offset
    local lines = self.lines

    for j = 1, self.generations do
        for i = #lines, 1, -1 do
            local start_point_x, start_point_y = lines[i].x1, lines[i].y1
            local end_point_x, end_point_y = lines[i].x2, lines[i].y2
            table.remove(lines, i)

            local mid_point_x, mid_point_y = (start_point_x + end_point_x)/2, (start_point_y + end_point_y)/2
            local pnx, pny = Vector.perpendicular(Vector.normalize(end_point_x - start_point_x, end_point_y - start_point_y))
            mid_point_x = mid_point_x + pnx*random(-offset_amount, offset_amount)
            mid_point_y = mid_point_y + pny*random(-offset_amount, offset_amount)
            table.insert(lines, {x1 = start_point_x, y1 = start_point_y, x2 = mid_point_x, y2 = mid_point_y})
            table.insert(lines, {x1 = mid_point_x, y1 = mid_point_y, x2 = end_point_x, y2 = end_point_y})
        end
        offset_amount = offset_amount/2
    end
end

function LightningLine:draw()
    for i, line in ipairs(self.lines) do 
        love.graphics.setColor(self.color2.r, self.color2.g, self.color2.b, self.alpha)
        love.graphics.setLineWidth(self.lw)
        love.graphics.line(line.x1, line.y1, line.x2, line.y2) 

        love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.alpha)
        love.graphics.setLineWidth(self.lw-1)
        love.graphics.line(line.x1, line.y1, line.x2, line.y2) 
    end
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 1)
end

function LightningLine:destroy()
    self.dead = true
end


AnimatedSquare = Class:extend()
AnimatedSquare:implement(GameObject)

function AnimatedSquare:new(args)
    self:init_game_obj(args)
    self.color = self.color or colors.fg
    self.t:tween(0.3, self, { h = 0 }, 'out-cubic')
    self.t:after(0.3, function() self.dead = true end)
end

function AnimatedSquare:update(dt)
    self:update_game_obj(dt)
end

function AnimatedSquare:draw()
    graphics.rectangle2(self.x - self.w/2, self.y, self.w, self.h, 0, 0, self.color)
end

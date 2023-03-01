Trail = Class:extend()

function Trail:new()
    self.timer = Timer()
    self.xs = {}
    self.ys = {}
    self.rs = {}
    self.colors = {}
    self.durations = {}
    self.tweens = {}
    self.creation_times = {}
    self.active = {}

    for i = 1, 2000 do
        self.xs[i] = 0
        self.ys[i] = 0
        self.rs[i] = 0
        self.colors[i] = default_color
        self.durations[i] = 0
        self.tweens[i] = 0
        self.creation_times[i] = 0
        self.active[i] = false
    end
end

function Trail:update(dt)
    self.timer:update(dt)
    for i = 1, 2000 do
        if self.active[i] and love.timer.getTime() > (self.creation_times[i] + self.durations[i]) then
            self:remove(i)
        end
    end
end

function Trail:draw()
    for i = 1, 2000 do
        if self.active[i] then
            graphics.set_color(self.colors[i])
            love.graphics.circle('fill', self.xs[i], self.ys[i], self.rs[i])
            love.graphics.setColor(1, 1, 1)
        end
    end
end

function Trail:add(x, y, r, color, d)
    local i = self:getFreeIndex()
    if not i then return end
    self.xs[i] = x
    self.ys[i] = y
    self.rs[i] = r or random(4, 6)
    self.colors[i] = color
    self.durations[i] = d or random(0.3, 0.5)
    self.tweens[i] = self.timer:tween(self.durations[i], self.rs, { [i] = 0 }, 'linear')
    self.creation_times[i] = love.timer.getTime()
    self.active[i] = true
end

function Trail:remove(i)
    self.xs[i] = nil
    self.ys[i] = nil
    self.rs[i] = nil
    self.durations[i] = nil
    self.timer:cancel(self.tweens[i])
    self.tweens[i] = nil
    self.creation_times[i] = nil
    self.active[i] = false
end

function Trail:getFreeIndex()
    for i = 1, 2000 do
        if not self.active[i] then return i end
    end
end


TrailParticle = Class:extend()
TrailParticle:implement(GameObject)

function TrailParticle:new(args)
    self:init_game_obj(args)
    self.a = 1
    self.t:tween(self.duration, self, { lw = 0, a = 0 }, 'linear')
    self.t:after(self.duration, function() self.dead = true end)
end


function TrailParticle:update(dt)
    self:update_game_obj(dt)
end

function TrailParticle:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b, self.a)
    love.graphics.setLineWidth(self.lw)
    love.graphics.line(self.x1, self.y1, self.x2, self.y2)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setLineWidth(1)
end


Trail2 = Class:extend()
Trail2:implement(GameObject)

function Trail2:new(args)
    self:init_game_obj(args)
    self.last_x, self.last_y = self.x, self.y
    self.color = self.color or colors.white
    -- self.cd = 0.03
    -- self.cd_timer = 0
end

function Trail2:update(dt)
    self:update_game_obj(dt)
    if self.parent.dead then
        self.dead = true
        return 
    end
    -- self.cd_timer = self.cd_timer + dt
    self.x, self.y = self.parent.x, self.parent.y
    -- if self.cd_timer > self.cd then
    --     self.cd_timer = 0
        TrailParticle { group = self.group, x1 = self.x, y1 = self.y, x2 = self.last_x, y2 = self.last_y, color = self.color, lw = self.lw, duration = self.duration}
        self.last_x, self.last_y = self.x, self.y
    -- end
end

function Trail2:draw()
end

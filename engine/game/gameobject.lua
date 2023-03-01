GameObject = Class:extend()

function GameObject:init_game_obj(args)
    for k, v in pairs(args) do self[k] = v end
    -- game object
    self.id = self.id or uid()
    if self.group then self.group:add(self) else error('you forget group men  something wonrng') end

    --transform
    self.x, self.y = self.x or 0, self.y or 0
    self.angle = self.angle or 0
    self.ox, self.oy = self.ox or 0, self.oy or 0
    self.sx, self.sy = self.sx or 1, self.sy or 1
    self.z = self.z or 1
    self.x_vel, self.y_vel = self.x_vel or 0, self.y_vel or 0
    --stuff
    self.t = Timer()
    self.spring = Spring()

    return self
end

function GameObject:update_game_obj(dt)
    self.t:update(dt)
    self.spring:update(dt)

    if self.interact_with_mouse then
        if self:is_colliding_with_point(mouse_x, mouse_y) then
            if not self.touching_mouse then
                if self.on_mouse_enter then self:on_mouse_enter() end
                self.touching_mouse = true
            end
            if self.on_touching_mouse then self:on_touching_mouse() end
        else
            if self.touching_mouse then
                self.touching_mouse = false
                if self.on_mouse_exit then self:on_mouse_exit() end
            end
        end
    end
end
function GameObject:rotate_towards(angle, rt_speed, dt)
    local angle_to = self:angle_to(angle)
    self.angle = self.angle + (lume.sign(angle_to) * math.min(rt_speed * dt, math.abs(angle_to)))
end

function GameObject:set_position(x, y, dt)
    self.x, self.y = self.x + x * dt, self.y + y * dt
end

function GameObject:angle_to(angle)
    local d = angle - self.angle
    return (d + math.pi) % (math.pi * 2) - math.pi
end

function GameObject:is_colliding_with_point(px, py)
    return px > self.x - self.w / 2 and px < self.x + self.w - self.w / 2 and py > self.y - self.h / 2 and
        py < self.y + self.h - self.h / 2
end

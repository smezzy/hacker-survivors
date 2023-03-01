Projectile = Class:extend()
Projectile:implement(Physics, GameObject)

function Projectile:new(args)
    self:init_game_obj(args)
    self:init_physics(self.w, self.h)
    self.class = "Projectile"
    self:disable_collision_with("Projectile", "Player", "Node", "Drop")
    self.color = self.color or colors.white

    self.damaged_enemies = {}

    self.seeking_force = self.seeking_force or 0
    self.velocity = self.velocity or 0
    self.damage = self.damage or 1
    self.lifetime = self.lifetime or 99
    self.explosive = self.explosive or false
    self.shock = self.shock or false
    self.piercing = self.piercing or 1
    self.explosion_range = self.explosion_range or 100


    if self.deaccel then
        self.t:tween(self.deaccel, self, { speed = 0 }, 'in-cubic')
    end

    self.trails = {}

    if self.ichor and self.flaming then
        self.trail = Trail2 { group = main.current.particles, x = self.x, y = self.y, parent = self, duration = 0.25,
            lw = self.h, color = colors.red }
    elseif self.ichor then
        self.trail = Trail2 { group = main.current.particles, x = self.x, y = self.y, parent = self, duration = 0.25,
            lw = self.h, color = colors.yellow }
    elseif self.flaming then
        self.trail = Trail2 { group = main.current.particles, x = self.x, y = self.y, parent = self, duration = 0.25,
            lw = self.h, color = colors.orange }
    end

end

function Projectile:update(dt)
    if self.paused or main.current.paused then return end
    self:update_game_obj(dt)

    if self.seeking and self.seeking.dead then
        self.seeking = nil
        self:seek_target()
    end
    if self.seeking_force and self.seeking then
        local angle = lume.angle(self.x, self.y, self.seeking.x, self.seeking.y)
        self:rotate_towards(angle, self.seeking_force, dt)
    elseif self.seeking_force and not self.seeking then
        self:seek_target()
    end

    if self.deaccel and self.speed <= 10 then
        self.dead = true
    end

    if self.x >= arena_width or self.x <= 0 or self.y >= arena_height or self.y <= 0 then
        self:wall_particle()
        self.dead = true
    end

    self.x_vel, self.y_vel = math.cos(self.angle), math.sin(self.angle)
    self:move(self.x_vel * self.velocity, self.y_vel * self.velocity, dt)
end

function Projectile:seek_target()
    self.seeking = main.current.main:get_closest_object(self.x, self.y, 999999, function(o)
        return (o:is(Mineral) or o:is(Enemy))
    end)
end

function Projectile:find(obj)
    for _, e in ipairs(self.damaged_enemies) do
        if e.id == obj.id then
            return true
        end
    end
end

function Projectile:wall_particle()
    local xx, yy = self.x, self.y
    MuzzleFlash { group = main.current.main, x = xx, y = yy, w = 16, radius = 12, h = 16, lifetime = 0.25 }

    local pdirx, pdiry = math.cos(self.angle + math.pi / 4), math.sin(self.angle + math.pi / 4)
    HitParticle {
        group = main.current.main,
        x = self.x,
        y = self.y,
        w = 8, h = 2,
        x_vel = -math.cos(self.angle + (math.pi / 4) * love.math.random(0, 1.5)),
        y_vel = -math.sin(self.angle + (math.pi / 4) * love.math.random(0, 1.5)),
        speed = random(80, 200),
        lifetime = 0.2
    }
    HitParticle {
        group = main.current.main,
        x = self.x,
        y = self.y,
        w = 8, h = 2,
        x_vel = -math.cos(self.angle - (math.pi / 4) * love.math.random(0, 1.5)),
        y_vel = -math.sin(self.angle - (math.pi / 4) * love.math.random(0, 1.5)),
        speed = random(80, 200),
        lifetime = 0.2
    }
end

function Projectile:on_collision_enter(col)
    local obj = col.other
    if obj:is(Enemy) or obj:is(Mineral) then
        if not fn.findIndex(self.damaged_enemies, function(o) return o.id == obj.id end) then
            obj:take_damage(self.damage)

            if self.flaming then
                obj:apply_debuff("flame")
            end

            if self.shock then
                obj:apply_debuff("shock")
            end

            if self.ichor then
                obj:apply_debuff("ichor")
            end

            if self.shock and self.explosive then
                sfx.die_tower:play()
                Explosion { group = self.group, x = self.x, y = self.y, radius = self.explosion_range / 6, duration = 0.2,
                    color = colors.blue }
                local enemies = main.current.main:query_area(self.x, self.y, self.explosion_range * 2,
                    function(o) return (o:is(Enemy) or o:is(Mineral)) and o ~= obj end)
                obj:apply_debuff('shock')
                local color = colors.blue
                local color2 = colors.white

                if self.flame and self.ichor then
                    color = colors.red
                    color2 = colors.red
                elseif self.ichor then
                    color = colors.yellow
                    color2 = colors.white
                elseif self.flame then
                    color = colors.red
                    color2 = colors.white
                end
                for index, e in ipairs(enemies) do
                    if index > 8 then
                        break
                    end
                    e:take_damage(self.damage)
                    e:apply_debuff('shock')
                    if self.ichor then
                        e:apply_debuff('ichor')
                    end
                    LightningLine { group = main.current.main, x1 = self.x, y1 = self.y, x2 = e.x, y2 = e.y,
                        duration = 0.25, lw = 2, color = color, max_offset = 10, color2 = color2 }
                end
            elseif self.explosive and self.ichor then
                local enemies = main.current.main:query_area(self.x, self.y, self.explosion_range * 2,
                    function(o) return (o:is(Enemy) or o:is(Mineral)) and o ~= obj end)
                sfx.enemy_die4:play()
                Explosion { group = self.group, x = self.x, y = self.y, radius = self.explosion_range / 6, duration = 0.2,
                    color = colors.yellow }
                for _, e in ipairs(enemies) do
                    e:take_damage(self.damage)
                    e:apply_debuff("ichor")
                end
                HitSquare { group = main.current.main, x = self.x, y = self.y, w = self.explosion_range * 1.2,
                    h = self.explosion_range * 1.2, angle = random(0, math.pi * 2), duration = 0.15,
                    color = colors.yellow }
            elseif self.explosive then
                local enemies = main.current.main:query_area(self.x, self.y, self.explosion_range * 2,
                    function(o) return (o:is(Enemy) or o:is(Mineral)) and o ~= obj end)
                sfx.enemy_die4:play()
                for _, e in ipairs(enemies) do
                    e:take_damage(self.damage)
                end
                self:explosion_particle()
            end

            self:destroy()
        end
    end
end

function Projectile:explosion_particle()
    HitSquare { group = main.current.main, x = self.x, y = self.y, w = self.explosion_range * 1.2,
        h = self.explosion_range * 1.2, angle = random(0, math.pi * 2), duration = 0.15, color = colors.white }
end

function Projectile:destroy()
    self:wall_particle()
    self.dead = true
end

function Projectile:draw()
    graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
    graphics.rectangle(self.x, self.y, self.w, self.h, 0, 0, self.color)
    graphics.pop()
end

Explosion = Class:extend()
Explosion:implement(GameObject)

function Explosion:new(args)
    self:init_game_obj(args)
    self.t:tween(self.duration, self, { radius = self.radius / 2 }, 'out-quad')
    self.t:after(self.duration * 0.5, function() self.dead = true end)
end

function Explosion:update(dt)
    self:update_game_obj(dt)
end

function Explosion:draw()
    graphics.circle(self.x, self.y, self.radius, self.color)
end

Spark = Class:extend()
Spark:implement(GameObject)

function Spark:new(args)
    self:init_game_obj(args)
    self.t:tween(self.duration, self, { x_vel = 0, y_vel = 0, radius = 0 }, 'in-cubic')
    self.previous_x = self.x
    self.previous_y = self.y
end

function Spark:update(dt)
    self:update_game_obj(dt)
    self.x, self.y = self.x + self.x_vel * dt, self.y + self.y_vel * dt
end

function Spark:draw()
end

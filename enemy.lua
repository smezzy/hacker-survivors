Enemy = Class:extend()
Enemy:implement(GameObject)
Enemy:implement(Physics)

function Enemy:new(args)
    self:init_game_obj(args)
    if self.type == "godot" then
        self:init_physics(48, 48)
    else
        self:init_physics(16, 16)
    end
    self.class = "Enemy"
    self:disable_collision_with("Enemy", "Mineral", "Drop")
    self.sprite = images["godot"]
    self.x_vel, self.y_vel = vector2.normalize((arena_width / 2) - self.x, (arena_height / 2) - self.y)
    self.mv_speed = 0
    self.max_mv_speed = 60
    self.accel = 100
    self.health = self.health or 4
    self:seek(main.current.core)
    self.rotation_speed = 8
    self.can_damage = true
    self.seek_radius = 300
    self.width, self.height = 16, 8
    self.value = 10

    self.shield_dmg = 3
    if self.type == "fastboi" then
        self.max_mv_speed = 60
        self.health = 85 + main.current.extra_enemy_health
        self.color = colors.blue
    elseif self.type == "tankboi" then
        self.max_mv_speed = 20
        self.health = 400 + main.current.extra_enemy_health
        self.color = colors.orange
    elseif self.type == "shield_breaker" then
        self.max_mv_speed = 20
        self.health = 200 + main.current.extra_enemy_health
        self.shield_dmg = 10
        self.color = colors.white
        self.lw = 1
    elseif self.type == "averageboi" then
        self.max_mv_speed = 30
        self.health = 200 + main.current.extra_enemy_health
        self.color = colors.fg2
    elseif self.type == "eliteboi1" then
        self.max_mv_speed = 40
        self.tier = 100
        self.health = 5000 + main.current.extra_enemy_health
        self.color = colors.red
        self.value = 200
        self.width, self.height = 16 * 1.5, 8 * 1.5
    elseif self.type == "eliteboi2" then
        self.max_mv_speed = 40
        self.tier = 100
        self.health = 6000 + main.current.extra_enemy_health
        self.color = colors.red
        self.value = 500
        self.width, self.height = 16 * 1.5, 8 * 1.5
    elseif self.type == "eliteboi3" then
        self.max_mv_speed = 40
        self.tier = 100
        self.health = 7000 + main.current.extra_enemy_health
        self.color = colors.red
        self.value = 1000
        self.width, self.height = 16 * 1.5, 8 * 1.5
    elseif self.type == "godot" then
        self.max_mv_speed = 10
        self.health = 50000 + main.current.extra_enemy_health
        self.color = colors.red
    end

    self.hp_bar = ProgressBar { group = self.group, w = 18, align = 'center', color = colors.orange, h = 1,
        max_value = self.health }
    self.hp_bar.hidden = true

    local closest_node = main.current.main:get_closest_object(self.x, self.y, self.seek_radius,
        function(o) return (o:is(Node) and not o.preview) or o:is(Player) end)
    if closest_node and closest_node ~= self.seeking then
        self:seek(closest_node)
    elseif not closest_node then
        self:seek({ x = arena_width / 2, y = arena_height / 2 })
    end

    self.t:every(0.3, function()
        local closest_node = main.current.main:get_closest_object(self.x, self.y, self.seek_radius,
            function(o) return (o:is(Node) and not o.preview) or o:is(Player) end)
        if closest_node and closest_node ~= self.seeking then
            self:seek(closest_node)
        elseif not closest_node then
            self:seek({ x = arena_width / 2, y = arena_height / 2 })
        end
    end)
end

function Enemy:update(dt)
    if self.paused or main.current.paused then return end
    self:update_game_obj(dt)
    if self.type == "godot" then
        self.hp_bar.x, self.hp_bar.y = self.x, self.y + 45
    else
        self.hp_bar.x, self.hp_bar.y = self.x, self.y + 12
    end

    if self.can_damage then
        self.mv_speed = self.mv_speed + dt * self.accel
        self.mv_speed = lume.clamp(self.mv_speed, 0, self.max_mv_speed)
        self.dirx, self.diry = self.seeking.x - self.x, self.seeking.y - self.y
        local angle = math.atan2(self.diry, self.dirx)
        self:rotate_towards(angle, dt)
        self.x_vel, self.y_vel = math.cos(self.angle), math.sin(self.angle)
        self:move(self.x_vel * self.mv_speed, self.y_vel * self.mv_speed, dt)
    else
        local angle = nil
        if self.spinning then
            -- self.mv_speed = self.mv_speed * math.pow(0.9, dt * 10)
            self.angle = self.angle + dt * (self.mv_speed * 0.2)
            self:move(self.x_vel * self.mv_speed, self.y_vel * self.mv_speed, dt)
        else
            angle = math.atan2(self.y_vel, self.x_vel)
            self:rotate_towards(angle, dt * 3)
            self:move(math.cos(angle) * self.mv_speed, math.sin(angle) * self.mv_speed, dt)
        end
        self.mv_speed = self.mv_speed * math.pow(0.6, dt * 10)
    end

end

function Enemy:apply_force(x, y)
    self.x_vel, self.y_vel = x, y
end

function Enemy:seek(obj)
    self.seeking = obj
end

function Enemy:apply_debuff(type)
    local particle = function(color)
        for i = 0, 4 do
            local angle = random(0, math.pi * 2)
            HitParticle {
                group = main.current.main,
                x = self.x,
                y = self.y,
                lifetime = 0.2,
                x_vel = math.cos(angle),
                y_vel = math.sin(angle),
                speed = random(50, 80),
                w = 7,
                h = 2,
                color = color
            }
        end
    end

    if type == "shock" then
        particle(colors.blue)
        if self.shock_trigger then
            self.t:cancel(self.shock_trigger)
        end
        self.shock_trigger = self.t:every(0.2, function()
            self:take_damage(20)
            particle(colors.blue)
        end, 10)
    elseif type == "flame" then
        particle(colors.red)
        self.flaming = true
        if self.flame_trigger then
            self.t:cancel(self.flame_trigger)
        end
        self.flame_trigger = self.t:every(0.2, function()
            self:take_damage(150)
            particle(colors.red)
        end, 2)
    elseif type == "ichor" then
        self.ichor = true
        self.t:after(2, function() self.ichor = false end)
    end
end

function Enemy:rotate_towards(angle, dt)
    local angle_to = self:angle_to(angle)
    self.angle = self.angle + (lume.sign(angle_to) * math.min(self.rotation_speed * dt, math.abs(angle_to)))
end

function Enemy:take_damage(amount)

    if self.ichor then
        amount = amount * 1.2
    end

    MuzzleFlash { group = main.current.main, x = self.x, y = self.y, w = 16, radius = 16, h = 16, lifetime = 0.15 }

    self.health = self.health - amount
    self.hp_bar:update_value(self.health)
    self.hp_bar.hidden = false
    if self.hp_trigger then
        self.t:cancel(self.hp_trigger)
    end
    self.hp_trigger = self.t:after(0.2, function()
        self.hp_bar.hidden = true
    end)
    if not self.dead and self.health <= 0 then
        main.current:set_enemy_count(main.current.enemy_count - 1)
        self.dead = true
        self:die()
    end
    self.spring:pull(8)
end

function Enemy:on_collision_enter(col)
    local obj = col.other
    if self.can_damage and obj:is(Node) or obj:is(Player) then
        self.can_damage = false
        obj:take_damage(1)
        self.mv_speed = self.max_mv_speed
        local dirx, diry = vector2.normalize(obj.x - self.x, obj.y - self.y)
        MuzzleFlash { group = self.group, x = self.x + math.cos(self.angle) * self.w / 2,
            y = self.y + math.sin(self.angle) * self.w / 2, radius = 13, lifetime = 0.15, color = colors.fg2 }
        self:apply_force(-dirx * 60, -diry * 60)
        self.t:after(0.3, function() self.can_damage = true end)
    end
end

function Enemy:knockback(obj, force, duration)
    if not self.can_damage then return end
    if self.type == "shield_breaker" then
        Explosion { group = self.group, x = self.x, y = self.y, radius = 30, duration = 0.2, color = colors.blue }
    end
    self.can_damage = false
    self.mv_speed = force
    self.spinning = true
    local dirx, diry = vector2.normalize(obj.x - self.x, obj.y - self.y)
    MuzzleFlash { group = self.group, x = self.x + math.cos(self.angle) * self.w / 2,
        y = self.y + math.sin(self.angle) * self.w / 2, radius = 13, lifetime = 0.15, color = colors.fg2 }
    self:apply_force(-dirx, -diry)
    self.t:after(duration, function() self.spinning = false
        self.can_damage = true
    end)
end

function Enemy:die()
    Drop { group = main.current.drops, x = self.x, y = self.y, type = 'coin', value = self.value, tier = self.tier}
    for i = 0, 4 do
        local angle = random(0, math.pi * 2)
        HitParticle {
            group = main.current.main,
            x = self.x,
            y = self.y,
            lifetime = 0.2,
            x_vel = math.cos(angle),
            y_vel = math.sin(angle),
            speed = random(60, 120),
            w = 7,
            h = 2,
            color = colors.orange
        }
    end

    if self.flaming then
        local enemies = main.current.main:query_area(self.x, self.y, 64, function(o) return o:is(Enemy) end)
        for _, e in ipairs(enemies) do
            e:apply_debuff("flame")
        end
    end

    self.hp_bar.dead = true
end

function Enemy:draw()
    -- graphics.set_color(colors.orange)
    if self.type == "godot" then
        self.sprite:draw(self.x, self.y, self.angle, self.sx + self.spring.x, self.sy + self.spring.x)
        return
    end
    graphics.push(self.x, self.y, self.angle, self.sx + self.spring.x, self.sy + self.spring.x)
    graphics.rectangle(self.x, self.y, self.width, self.height, 3, 3, self.color, self.lw)
    -- self.sprite:draw(self.x, self.y, 0, self.sx, self.sy)
    graphics.pop()
    -- graphics.set_color()
end

Drop = Class:extend()
Drop:implement(GameObject)
-- Drop:implement(Physics)

function Drop:new(args)
    self:init_game_obj(args)
    self.w, self.h = 8, 8
    -- self:init_physics(8, 8)
    -- self.class = "Drop"
    -- self:disable_collision_with("Mineral", "Player", "Enemy", "Projectile", "Node")

    self.tier = self.tier or 1
    self.polygons = {}
    if self.type == "coin" then
        print(self.value)
        self.value = self.value or 10
        self.radius = 2
        self.line = true
        self.color = colors.fg2
        for i = 1, 11 do
            local angle = ((math.pi * 2) / 10) * i
            local dist = random(self.radius, self.radius + 1)
            local px, py = math.cos(angle) * dist, math.sin(angle) * dist
            table.insert(self.polygons, px)
            table.insert(self.polygons, py)
        end
    end

    self.can_pickup = true
    self.can_collide = true
    self.leash_distance = 96
    self.player_in_range = false

    self.t:every(1 / 60, function()
        self:optimize()
    end)
end

tier_to_value = {
    [1] = 10,
    [2] = 10 * 5,
    [3] = 10 * 5 * 5,
    [4] = 10 * 5 * 5 * 5,
    [5] = 10 * 5 * 5 * 5 * 5,
}

function Drop:optimize()
    local drops = self.group:query_area(self.x, self.y, 32, function(o)
        return o:is(Drop) and o.tier == self.tier and not o.delivering
    end)
    if #drops > 4 then
        for _, drop in ipairs(drops) do
            drop.dead = true
        end
        local tier = self.tier + 1
        Drop { group = main.current.drops, x = self.x, y = self.y, type = 'coin', value = tier_to_value[tier],
            tier = tier }
    else
        return
    end
    self.dead = true
end

function Drop:update(dt)
    if self.dead then return end
    self:update_game_obj(dt)

    if self.delivering then
        local dirx, diry = vector2.normalize(self.delivering.x - self.x, self.delivering.y - self.y)
        self.x_vel, self.y_vel = dirx * self.velocity, diry * self.velocity
        self:set_position(self.x_vel, self.y_vel, dt)

        if lume.distance(self.x, self.y, self.delivering.x, self.delivering.y, true) <=
            self.delivering.radius * self.delivering.radius then
            self:destroy()
        end
        return
    end

    if not self.can_collide then
        self:set_position(self.x_vel, self.y_vel, dt)
        return
    end


    if self.attached_to then
        if lume.distance(self.x, self.y, self.attached_to.x, self.attached_to.y, true) >=
            self.leash_distance * self.leash_distance then
            local dirx, diry = vector2.normalize(self.attached_to.x - self.x, self.attached_to.y - self.y)
            self.x_vel, self.y_vel = dirx * self.attached_to.velocity, diry * self.attached_to.velocity
        else
            self.x_vel, self.y_vel = 0, 0
        end
    end

    self:set_position(self.x_vel, self.y_vel, dt)
end

function Drop:deliver_to(obj)
    self.attached_to = nil
    self.delivering = obj
    self.velocity = 0
    self.t:tween(random(0.5, 0.8), self, { velocity = 250 }, 'in-cubic')
end

function Drop:destroy()
    if self.type == "material" then
        self.delivering.materials = self.delivering.materials + self.value
    elseif self.type == "coin" then
        main.current.player.gold = main.current.player.gold + self.value
    end
    MuzzleFlashII { group = main.current.main, x = self.x, y = self.y, w = 16, h = 16, angle = random(0, math.pi * 2),
        lifetime = 0.07 }
    self.dead = true
    sfx.get_material:play()
end

function Drop:attach_to(to)
    self.attached_to = to
end

function Drop:apply_force(x, y)
    self.x_vel, self.y_vel = x, y
    self.can_collide = false
    self.t:tween(random(0.1, 0.3), self, { x_vel = 0, y_vel = 0 }, 'in-cubic', function()
        self.can_collide = true
    end)
end

function Drop:draw()
    graphics.push(self.x, self.y, self.angle, self.sx, self.sy)

    if self.attached_to then
        graphics.set_color(colors.bg3)
        love.graphics.line(self.x, self.y, self.attached_to.x, self.attached_to.y)
        graphics.set_color()
    end

    love.graphics.translate(self.x, self.y)
    graphics.set_color(self.color)
    if self.line then
        love.graphics.polygon('line', self.polygons)
    else
        love.graphics.polygon('fill', self.polygons)
    end
    graphics.set_color()
    graphics.pop()
end

Mineral = Class:extend()
Mineral:implement(GameObject)
Mineral:implement(Physics)

function Mineral:new(args)
    self:init_game_obj(args)
    self:init_physics(8, 8)
    self.class = "Mineral"
    self:disable_collision_with("Enemy", "Projectile")

    self.polygons = {}
    if self.type == "coin" then
        self.radius = self.w
        self.line = false
        self.color = colors.orange
        for i = 1, 11 do
            local angle = ((math.pi * 2) / 10) * i
            local dist = random(self.radius - 2, self.radius + 2)
            local px, py = math.cos(angle) * dist, math.sin(angle) * dist
            table.insert(self.polygons, px)
            table.insert(self.polygons, py)
        end
    end

    self.health = 10
    self.minerals = 5
end

function Mineral:update(dt)
    self:update_game_obj(dt)
end

function Mineral:take_damage(amount)
    MuzzleFlash { group = main.current.main, x = self.x, y = self.y, w = 16, radius = 16, h = 16, lifetime = 0.15 }
    if self.dead then return end
    self.health = self.health - amount
    if self.health <= 0 then
        self:die()
    end
end

function Mineral:apply_debuff()
end

function Mineral:die()
    self.dead = true
    for i = 1, self.minerals do
        local d = Drop { group = main.current.drops, x = self.x, y = self.y, type = self.type }
        d:apply_force(random(-350, 350), random(-350, 350))
    end
end

function Mineral:draw()
    graphics.push(self.x, self.y, self.angle, self.sx, self.sy)

    love.graphics.translate(self.x, self.y)
    graphics.set_color(self.color)
    love.graphics.polygon('line', self.polygons)
    graphics.set_color()
    graphics.pop()

end

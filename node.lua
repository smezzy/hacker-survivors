Node = Class:extend()
Node:implement(GameObject)
Node:implement(Physics)

function Node:new(args)
    self:init_game_obj(args)

    if self.type == "core" then
        self:init_physics(22, 22)
    else
        self:init_physics(16, 16)
    end

    main.current.towers = main.current.towers + 1
    self.class = "Node"
    self:disable_collision_with("Player", "Projectile", "Mineral", "Drop", "Enemy")

    --private varaibels
    self.triggers = {}
    self.nodes_connected = {}
    self.cables = {}

    -- states
    self.preview = true

    -- stats
    self.health = 0
    self.shield = 0
    self.max_shield = 12
    self.ammo = 0
    self.max_ammo = 0
    self.energy = 0
    self.max_energy = 0
    self.materials = 0
    self.max_materials = 0
    self.upload_rate = 0
    self.download_rate = 0
    self.downloads = 0
    self.online = true
    self.upload_timer = 0
    self.upload_cd = 0
    self.node_index = 0

    -- misc
    self.interact_with_mouse = true
    self.time_alive = 0

    --sprite
    self.color = node_to_color[self.type] or colors.white
    self.radius = 5

    if self.type == "core" then
        self.energy = 50
        self.upload_rate = 4
        self.max_energy = 1500
        self.health = 50
        self.max_health = 50
        self.radius = 16
        self.w, self.h = 16, 16
        self.color = node_to_color[self.type]
        self.preview = false
        self.receives = { 'energy' }
    elseif self.type == "overclock" then
        self.price = 30
        self.shock = 0
        self.flame = 0
        self.rocket =  0
        self.explosive = 0
        self.max_shock = 0
        self.max_flame = 0
        self.max_rocket =  0
        self.max_explosive = 0
        self.health = 10
        self.max_health = 10
        self.color = node_to_color[self.type]
        self.max_ammo = 150
        self.attack_speed = 1/9
        self.attack_range = 120
        self.receives = { 'ammo', 'shield', 'flame', 'shock', 'rocket', 'explosive' }
    elseif self.type == "ranger" then
        self.price = 30
        self.shock = 0
        self.flame = 0
        self.rocket =  0
        self.explosive = 0
        self.max_shock = 0
        self.max_flame = 0
        self.max_rocket =  0
        self.max_explosive = 0
        self.health = 10
        self.max_health = 10
        self.color = node_to_color[self.type]
        self.max_ammo = 20
        self.attack_speed = 1/4
        self.attack_range = 99999
        self.receives = { 'ammo', 'shield', 'flame', 'shock', 'rocket', 'explosive' }
    elseif self.type == "gunner" then
        self.price = 30
        self.shock = 0
        self.flame = 0
        self.rocket =  0
        self.explosive = 0
        self.max_shock = 0
        self.max_flame = 0
        self.max_rocket =  0
        self.max_explosive = 0
        self.health = 10
        self.max_health = 10
        self.color = colors.orange
        self.max_ammo = 50
        self.attack_speed = 1/6
        self.attack_range = 180
        self.receives = { 'ammo', 'shield', 'flame', 'shock', 'rocket', 'explosive' }
    elseif self.type == "cannon" then
        self.price = 30
        self.shock = 0
        self.flame = 0
        self.rocket =  0
        self.explosive = 0
        self.max_shock = 0
        self.max_flame = 0
        self.max_rocket =  0
        self.max_explosive = 0
        self.health = 10
        self.max_health = 10
        self.color = node_to_color[self.type]
        self.max_ammo = 20
        self.attack_speed = 0.6
        self.attack_range = 500
        self.receives = { 'ammo', 'shield', 'flame', 'shock', 'rocket', 'explosive' }
    elseif self.type == "ammo" then
        self.health = 6
        self.max_health = 6
        self.price = 50
        self.color = colors.green
        self.energy = 0
        self.max_energy = 100
        self.upload_rate = 6
        self.ammo_type = { damage = 1, tier = 0 }
        self.receives = { 'energy' }
    elseif self.type == "shield" then
        self.shield_spring = Spring()
        self.price = 60
        self.shock = 0
        self.flame = 0
        self.rocket =  0
        self.explosive = 0
        self.max_shock = 0
        self.max_flame = 0
        self.max_rocket =  0
        self.max_explosive = 0
        self.expected_ammo = 0
        self.expected_flame = 0
        self.expected_shock = 0
        self.expected_rocket = 0
        self.expected_explosive = 0
        self.health = 4
        self.max_health = 4
        self.color = colors.blue
        self.shield = 0
        self.max_shield = 100
        self.max_ammo = 100
        self.upload_rate = 0
        self.last_shield_radius = 0
        self.receives = { 'ammo', 'shield', 'flame', 'shock', 'rocket', 'explosive' }
    elseif self.type == "generator" then
        self.price = 40
        self.health = 15
        self.max_health = 15
        self.energy = 0
        self.max_energy = 500
        self.max_ammo = 50
        self.materials = 0
        self.max_materials = 50
        self.upload_rate = 3
        self.color = colors.white
        self.receives = { 'material' }
    elseif self.type == "processing_unit" then
        self.price = 20
        self.health = 10
        self.max_health = 10
        self.ammo = 0
        self.max_ammo = 2
        self.upload_rate = 3
        self.ammo_queue = {}
        self.receives = { 'ammo' }
    elseif self.type == "flame_gen" then
        self.price = 100
        self.ammo_type = { damage = 1, flaming = true, tier = 1 }
        self.health = 10
        self.max_health = 10
        self.ammo = 0
        self.max_ammo = 5
        self.energy = 0
        self.max_energy = 30
        self.upload_rate = 3
        self.ammo_queue = {}
        self.receives = { 'ammo' }
    elseif self.type == "explosive_gen" then
        self.price = 100
        self.ammo_type = { damage = 1, explosive = true, tier = 1 }
        self.health = 10
        self.max_health = 10
        self.ammo = 0
        self.max_ammo = 5
        self.energy = 0
        self.max_energy = 30
        self.upload_rate = 3
        self.ammo_queue = {}
        self.receives = { 'ammo' }
    elseif self.type == "shock_gen" then
        self.price = 100
        self.health = 10
        self.max_health = 10
        self.ammo = 0
        self.max_ammo = 5
        self.energy = 0
        self.max_energy = 30
        self.upload_rate = 10
        self.ammo_queue = {}
        self.ammo_type = { damage = 1, shock = true, tier = 1 }
        self.receives = { 'ammo' }
    elseif self.type == "rocket_gen" then
        self.price = 100
        self.health = 10
        self.max_health = 10
        self.ammo = 0
        self.max_ammo = 5
        self.energy = 0
        self.max_energy = 30
        self.upload_rate = 3
        self.ammo_queue = {}
        self.ammo_type = { damage = 1, seeking_force = 10, tier = 1 }
        self.receives = { 'ammo' }
    end
end

function Node:init()
    self[self.type .. "_init"](self)
    self.active = true
    if not self.online then
        self:activate()
    end
end

function Node:flame_gen_init()
    self:init_upload('flame', 'ammo')
end

function Node:shock_gen_init()
    self:init_upload('shock', 'ammo')
end

function Node:rocket_gen_init()
    self:init_upload('rocket', 'ammo')
end

function Node:explosive_gen_init()
    self:init_upload('explosive', 'ammo')
end

function Node:activate()
    self.online = true
    self.group.world:add(self, self.x - w / 2, self.y - h / 2, w or self.w, h or self.h)
end

function Node:show_stats()
    if main.current.player.card then
        main.current.player.card:destroy()
        main.current.player.card = nil
    end
    main.current.player.card = Card {
        group = main.current.game_ui,
        x = self.x,
        y = self.y,
        parent = self,
        color = node_to_color[self.type]
    }

    for _, r in ipairs(self.receives) do
        main.current.player.card:add_info(r, colors.fg2)
    end

    main.current.player.card:post_create()
end

function Node:send_packet_to(node, packet_type, ammo_opts)
    local dist = math.sqrt(math.abs(distance(self.x, self.y, node.x, node.y)))
    Resource { group = main.current.particles, x = self.x, y = self.y, dest = node, type = packet_type, quant = 1,
        dist = dist, parent = self, color = node_to_color[self.type], ammo_opts = ammo_opts }
end

function Node:upload(packet_type, material, node)
    if self[material] <= 0 then return end
    if not node then return end
    -- for _, node in ipairs(self.nodes_connected) do
        -- if packet_type == "energy" and material == "materials" and node.type ~= "core" then return end

    local upload = false
    if fn.findIndex(node.receives, function(a) return a == packet_type end) then

        local og_packet = packet_type
        if packet_type == "shock" or packet_type == "flame" or packet_type == "explosive" or packet_type == "rocket" then
            packet_type = "ammo"
        end

        node['expected_' .. packet_type] = node['expected_' .. packet_type] or -1
        node['expected_' .. packet_type] = node['expected_' .. packet_type] + 1

        if node['expected_' .. packet_type] < node['max_' .. packet_type] then
            self[material] = self[material] - 1
            self['expected_' .. material] = self['expected_' .. material] or self[material] + 1
            self['expected_' .. material] = self['expected_' .. material] - 1

            packet_type = og_packet
            upload = true
            self:send_packet_to(node, packet_type, self.ammo_type)
        else
            node['expected_' .. packet_type] = node['expected_' .. packet_type] - 1
        end

    end
    return upload
    -- end
end

function Node:init_upload(packet_type, material)
    self.uploading = true
    self.packet_type = packet_type
    self.material_type = material
    -- local trigger = self.t:every(1 / self.upload_rate, function()
        -- self:upload(packet_type, material, new_ammo)
    -- end)

    -- table.insert(self.triggers, trigger)
end

function Node:core_init()
    self:init_upload('energy', 'energy')
end

function Node:processing_unit_init()
    self:init_upload('ammo', 'ammo')
end

function Node:transport_init()
    self:init_upload('energy', 'energy')
    self:init_upload('ammo', 'ammo')
end

function Node:shield_init()
    local shield_trigger = self.t:every(0.01, function() self:increase_shield() end)
    table.insert(self.triggers, shield_trigger)
end

function Node:ammo_init()
    self:init_upload('ammo', 'energy')
end

function Node:generator_init()
    self:init_upload('energy', 'materials')
end

function Node:add_node(node, cable)
    local already_connected = fn.findIndex(self.nodes_connected, function(o) return o == node end)
    if already_connected then return already_connected end
    table.insert(self.nodes_connected, node)
    table.insert(self.cables, cable)
end

function Node:take_damage(amount)
    self.health = self.health - amount
    self.spring:pull(6)
    if self.health <= 0 then
        self:deactivate()
    end
end

function Node:increase_shield()
    if self.ammo <= 0 then return end
    if self.shield >= self.max_shield then return end
        

    self.shield = self.shield + 1

    if self.shield_tween then
        self.t:cancel(self.shield_tween)
    end
    self.shield_tween = self.t:tween(0.06, self, {last_shield_radius = self.shield}, 'out-quad')

    self.ammo = self.ammo - 1
    self.expected_ammo = self.expected_ammo - 1
end

function Node:shield_damage(amount, from)
    self.shield = self.shield - amount
    self.shield_spring:pull(10)

    local special = false
    if self.shield_tween then
        self.t:cancel(self.shield_tween)
    end
    self.shield_tween = self.t:tween(0.06, self, {last_shield_radius = self.shield}, 'out-quad')

    if self.shock > 0 then
        self.shock = self.shock -1
        self.expected_shock = self.expected_shock - 1
        from:apply_debuff("shock")
    end

    if self.rocket > 0 then
        self.rocket = self.rocket -1
        self.expected_rocket = self.expected_rocket - 1
        from:apply_debuff("ichor")
    end

    if self.explosive > 0 then
        self.explosive = self.explosive -1
        self.expected_explosive = self.expected_explosive - 1
        special = true
    end

    return special
end

function Node:deactivate()
    self.online = false
    self:destroy()
    -- self.group.world:remove(self)
end

function Node:destroy()
    if self.type == 'core' then return end
    self.dead = true
    MuzzleFlash { group = main.current.main, x = self.x, y = self.y, w = 16, radius = 12, h = 16, lifetime = 0.25 }
    for _, cable in ipairs(self.cables) do
        cable:destroy()
    end
    main.current.towers = main.current.towers - 1
    if main.current.towers <= 0 then
        main.current.game_over = true
        main.current.paused = true
    end
end

function Node:update(dt)
    if self.paused or main.current.paused then return end
    if self.dead then return end
    self:update_game_obj(dt)

    if self.shield_spring then
        self.shield_spring:update(dt)
    end

    self.upload_timer = self.upload_timer - dt
    self.upload_cd = 1/self.upload_rate
    if #self.nodes_connected > 0 then
        if self.uploading and self.upload_timer < 0 then
            for _, node in ipairs(self.nodes_connected) do
                if self:upload(self.packet_type, self.material_type, self.nodes_connected[self.node_index + 1]) then
                    self.node_index = self.node_index + 1
                    self.node_index = (self.node_index % #self.nodes_connected)
                    break
                else
                    self.node_index = self.node_index + 1
                    self.node_index = (self.node_index % #self.nodes_connected)
                end
            end
            self.upload_timer = self.upload_cd
        end
    end

    if self.type == "ammo" then
        self.energy = self.max_energy
    end

    if self.type == "shield" then
        local enemies = main.current.main:query_area(self.x, self.y, self.shield + 16, function(o) return o:is(Enemy) end)
        for _, e in ipairs(enemies) do
            if e.can_damage then 
                if self:shield_damage(e.shield_dmg, e) then
                    e:knockback(self, 260, 1.5)
                    e:take_damage(5)
                    HitSquare { group = main.current.main, x = e.x, y = e.y, w = 25, h = 25, angle = random(0, math.pi*2), duration = 0.15, color = colors.white}
                else
                    e:knockback(self, 80, 0.3)
                end
            end
        end
    end

    if not self.active and not main.current.building_phase then
        self:init()
    elseif main.current.building_phase and self.active then
        self:stop()
    end

    if self.downloads > 0 then
        self.time_alive = self.time_alive + dt
        self.download_rate = math.floor(self.downloads / self.time_alive)
    end

    if self["update_" .. self.type] then
        self["update_" .. self.type](self)
    end
end

function Node:update_ammo()
end

local function compare_table(a, b)
    local size_a, size_b = 0, 0
    for k, v in pairs(a) do
        size_a = size_a + 1
    end
    for k, v in pairs(b) do
        size_b = size_b + 1
    end
    if size_a ~= size_b then
        return false
    end

    for k, v in pairs(a) do
        if not b[k] then
            return false
        end
    end
    return true
end

function Node:deliver(resource, quant)
    if not self[resource] then return end
    if resource == "ammo" then
        self.ammo = self.ammo + quant
    elseif resource == "flame" then
        self.ammo = self.ammo + quant
        self.flame = self.flame + 1 
    elseif resource == "rocket" then
        self.ammo = self.ammo + quant
        self.rocket = self.rocket + 1
    elseif resource == "explosive" then
        self.ammo = self.ammo + quant
        self.explosive = self.explosive + 1
    elseif resource == "shock" then
        self.ammo = self.ammo + quant
        self.shock = self.shock + 1
    elseif resource == "energy" then
        self.energy = self.energy + quant
    elseif resource == "shield" then
        if self.shield >= self.max_shield then return end
        self.shield = self.shield + quant
    end

    self.downloads = self.downloads + 1
end

function Node:gunner_init()
    local gunner_trigger = self.t:every(self.attack_speed, function() self:shoot() end)
    table.insert(self.triggers, gunner_trigger)
end
function Node:overclock_init()
    local gunner_trigger = self.t:every(self.attack_speed, function() self:shoot() end)
    table.insert(self.triggers, gunner_trigger)
end
function Node:ranger_init()
    local gunner_trigger = self.t:every(self.attack_speed, function() self:shoot() end)
    table.insert(self.triggers, gunner_trigger)
end

function Node:stop()
    self.uploading = false
    self.active = false
    -- for _, trigger in ipairs(self.triggers) do
    --     self.t:cancel(trigger)
    -- end
end

function Node:update_gunner()
end

function Node:shoot()
    -- sfx.hit:play()
    if self.ammo <= 0 then return end

    local enemy = main.current.main:get_closest_object(self.x, self.y, self.attack_range,
        function(o) return o:is(Enemy) end)
    if not enemy then return end

    self.spring:pull(5)
    sfx.hit:play()


    local dirx, diry = vector2.normalize(enemy.x - self.x, enemy.y - self.y)
    self.angle = math.atan2(diry, dirx)

    local firepointx, firepointy = self.x + dirx * 8, self.y + diry * 8

    local bullet_opts = {}
    bullet_opts.damage = 45

    if self.flame > 0 then
        self.flame = self.flame - 1
        self.ammo = self.ammo - 1
        bullet_opts.damage = bullet_opts.damage + 10
        self['expected_ammo'] = self['expected_ammo'] - 1
        bullet_opts.flaming = true
    end

    if self.explosive > 0 then
        self.explosive = self.explosive - 1
        self.ammo = self.ammo - 1
        bullet_opts.damage = bullet_opts.damage + 5
        self['expected_ammo'] = self['expected_ammo'] - 1
        bullet_opts.explosive = true
    end

    if self.rocket > 0 then
        self.rocket = self.rocket - 1
        self.ammo = self.ammo - 1
        bullet_opts.damage = bullet_opts.damage + 2
        self['expected_ammo'] = self['expected_ammo'] - 1
        bullet_opts.seeking_force = 7
        bullet_opts.ichor = true
    end

    if self.shock > 0 then
        self.shock = self.shock - 1
        self.ammo = self.ammo - 1
        bullet_opts.damage = bullet_opts.damage * 0.8
        self['expected_ammo'] = self['expected_ammo'] - 1
        bullet_opts.shock = true
    end

    if #bullet_opts <= 0 then
        self.ammo = self.ammo - 1
        self['expected_ammo'] = self['expected_ammo'] - 1
    end

    local opts = {
        group = main.current.main,
        x = firepointx,
        y = firepointy,
        w = 8,
        h = 2,
        dirx = dirx,
        diry = diry,
        velocity = 600,
        angle = self.angle,
    }

    for k, v in pairs(bullet_opts) do
        opts[k] = v
    end

    local projectile = Projectile(opts)

    MuzzleFlash { group = main.current.main, x = firepointx, y = firepointy, radius = 12 }
    for i = 0, 2 do
        local angle = random(0, math.pi * 2)
        HitParticle {
            group = main.current.main,
            x = firepointx,
            y = firepointy,
            lifetime = 0.2,
            x_vel = math.cos(angle),
            y_vel = math.sin(angle),
            speed = random(40, 100),
            w = 6,
            h = 1
        }
    end
end

function Node:start_build()
    if self.dead then return end
    self.preview = false
    self.group.world:update(self, self.x, self.y)
    AnimatedSquare{group = main.current.game_ui, x = self.x, y = self.y-self.h/2, w = 24, h = 24}
end

function Node:draw()
    local color = self.color
    if not self.online then
        color = colors.bg2
    end

    graphics.circle(self.x, self.y, self.radius, colors.black)
    graphics.circle(self.x, self.y, self.radius, self.color, 1)

    if self.shield > 0 then
        graphics.circle(self.x, self.y, 7 + self.last_shield_radius + self.shield_spring.x, colors.blue, 1)
    end
end

Resource = Class:extend()
Resource:implement(GameObject)

function Resource:new(args)
    self:init_game_obj(args)
    self.w, self.h = 2, 1

    self.angle = math.atan2(self.dest.y - self.y, self.dest.x - self.x)
    local offx, offy = math.cos(self.angle) * (self.w + self.parent.radius),
        math.sin(self.angle) * (self.w + self.parent.radius)
    local offx2, offy2 = math.cos(self.angle) * (self.w + self.dest.radius),
        math.sin(self.angle) * (self.w + self.dest.radius)
    self.x, self.y = self.x + offx, self.y + offy

    self.t:tween(self.dist / 10, self, { x = self.dest.x - offx2, y = self.dest.y - offy2 }, 'linear',
        function()
            self.dest:deliver(self.type, self.quant, self.ammo_opts)
            self.dead = true
        end)
end

function Resource:update(dt)
    if main.current.paused then return end
    self:update_game_obj(dt)
end

function Resource:draw()
    graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
    graphics.rectangle(self.x, self.y, self.w, self.h, 0, 0, self.color)
    graphics.pop()
    -- graphics.circle(self.x, self.y, 3, self.color)
end

Cable = Class:extend()
Cable:implement(GameObject)

function Cable:new(args)
    self:init_game_obj(args)
end

function Cable:update(dt)
    self:update_game_obj(dt)
end

function Cable:destroy()
    self.dead = true
    if self.c1.dead then
        table.remove(self.c2.nodes_connected, fn.findIndex(self.c2.nodes_connected, function(o) return o == self.c1 end))
    elseif self.c2.dead then
        table.remove(self.c1.nodes_connected, fn.findIndex(self.c1.nodes_connected, function(o) return o == self.c2 end))
    end
end

function Cable:draw()
    local angle = lume.angle(self.c1.x, self.c1.y, self.c2.x, self.c2.y)
    local offx, offy = math.cos(angle) * (self.c1.radius + 3), math.sin(angle) * (self.c1.radius + 3)
    local offx2, offy2 = math.cos(angle) * (self.c2.radius + 3), math.sin(angle) * (self.c2.radius + 3)
    graphics.polyline(colors.bg2, 1, self.c1.x + offx, self.c1.y + offy, self.c2.x - offx2, self.c2.y - offy2)
end


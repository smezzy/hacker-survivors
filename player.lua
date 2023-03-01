-- TODO:
-- Towers:
--      Energy:
--      * Shield Tower
--      * Ammo Tower
--      Resource:
--      * Transport Node: stores any resource and transport it to all its neighboors
--      * energy suck machine, will suck nearby enemies drops

Player = Class:extend()
Player:implement(GameObject)
Player:implement(Physics)

function Player:new(args)
    self:init_game_obj(args)
    self:init_physics(9, 9)
    self.class = "Player"
    self:disable_collision_with("Player", "Projectile", "Node")
    self.trail = Trail()
    self.dirx, self.diry = 0, 0
    self.radius = 32

    self.can_show_stats = true

    self.polygons = {}

    self.polygons[1] = {
        self.w, 0,
        self.w / 4, -self.w / 2,
        -self.w, -self.w / 2,
        -self.w + 2, 0,
        -self.w, self.w / 2,
        self.w / 4, self.w / 2,
    }

    self.polygons[2] = {
        -self.w / 4, -(self.w / 2) - 2,
        -self.w, -self.w - 3,
        -self.w, -(self.w / 2) - 2,
    }

    self.polygons[3] = {
        -self.w / 4, (-(self.w / 2) - 2) * -1,
        -self.w, (-self.w - 3) * -1,
        -self.w, (-(self.w / 2) - 2) * -1,
    }

    -- variabels
    self.rotation_speed = 15
    self.velocity = 150
    self.max_speed = 180
    self.acceleration = 200
    self.shoot_timer = 0
    self.attack_speed = 0.2
    self.pickup_radius = 64

    self.ammo = 50
    self.max_ammo = 50

    self.shield = 0
    self.max_shield = 50

    self.health = 100
    self.max_health = 100

    self.can_turn_timer = 0

    self.drops = {}
    self.materials_drop = {}

    self.gold = 0
    self.level_up_gold = 50
    self.level_extra = 0
    self.level = 0
    self.levels_to_queue = 0


    self.hover_sqr2 = HoverSquare { group = main.current.main, x = self.x, y = self.y }

    self.t:every(1 / 15, function()
        self:collide_with_drops()

    end)
end

function Player:level_up()
    self.gold = self.gold - self.level_up_gold
    self.level_up_gold = self.level_up_gold + 10 + (10 * self.level)
    self.level = self.level + 1

    if self.tc then
        self.levels_to_queue = self.levels_to_queue + 1
        return
    end


    self:show_tc()
end

function Player:show_tc()
    self.can_show_stats = false
    self.tc = TowerChooser { group = main.current.ui, x = game_width / 2, y = game_height / 2 }
    main.current.time_scale = 0
end

function Player:update(dt)
    self.shoot_timer = self.shoot_timer - dt
    self.can_turn_timer = self.can_turn_timer - dt
    self:update_game_obj(dt)
    self.trail:add(self.x, self.y, 2, colors.white, random(0.1, 0.3))
    self.trail:update(dt)

    if self.gold >= self.level_up_gold then
        self:level_up()
    end



    if input:down "w" then
        self.diry = -1
    elseif input:down "s" then
        self.diry = 1
    else
        self.diry = 0
    end


    if input:down "a" then
        self.dirx = -1
    elseif input:down "d" then
        self.dirx = 1
    else
        self.dirx = 0
    end


    -- if not self.preview_node and not self.card and not self.hovered_node and not self.tc and input:pressed "mouse1" then
    --     self.tc = TowerChooser { group = main.current.ui, x = screen_mx, y = screen_my + 22 }
    -- elseif self.tc and input:released "mouse1" then
    --     self.tc:destroy()
    --     self.tc = nil
    -- end

    self:handle_selecting_nodes(dt)

    --
    if input:down "mouse2" and not self.preview_node then
        self.shooting = true
    else
        self.shooting = false
    end

    if self.preview_node then
        if input:pressed "mouse1" then
            self.preview_node:start_build()
            if self.levels_to_queue > 0 then
                self.levels_to_queue = self.levels_to_queue - 1
                self:show_tc()
            end
            self.t:after(0.06, function() self.can_show_stats = true end)

            local objs = main.current.main:get_objects(function(o) return o:is(Enemy) or o:is(Node) or o:is(Projectile) end)
            for _, obj in ipairs(objs) do
                obj.paused = false
            end

            self.preview_node = nil
            self.hover_sqr.dead = true
            self.hover_sqr = nil
            cursor.visible = true
        end
    end

    if self.preview_node then
        cursor.visible = false
        self.preview_node.x, self.preview_node.y = lume.round(mouse_x / 8) * 8, lume.round(mouse_y / 8) * 8

        if not self.hover_sqr then
            self.hover_sqr = HoverSquare { group = main.current.game_ui, x = mouse_y, y = mouse_y, w = 9, h = 9 }
        else
            self.hover_sqr.x, self.hover_sqr.y = self.preview_node.x, self.preview_node.y
        end

    end


    if self.shooting then
        self.velocity = 50
        local mdirx, mdiry = mouse_x - self.x, mouse_y - self.y
        local d_angle = math.atan2(mdiry, mdirx)
        self.x_vel, self.y_vel = vector2.normalize(self.dirx, self.diry)
        self:rotate_towards(d_angle, dt)

        if self.shoot_timer < 0 then
            if self:compare_angle((self.angle + math.pi) % (math.pi * 2) - math.pi, d_angle) then
                self:shoot(mdirx, mdiry)
            end
        end
    else
        if (math.abs(self.dirx) > 0 or math.abs(self.diry) > 0) then
            self.velocity = self.velocity + self.acceleration * dt
            self.velocity = lume.clamp(self.velocity, 0, self.max_speed)
            local d_angle = math.atan2(self.diry, self.dirx)
            self:rotate_towards(d_angle, dt)
            self.x_vel, self.y_vel = math.cos(self.angle), math.sin(self.angle)
            -- self.angle = math.atan2(self.y_vel, self.x_vel)
        else
            self.velocity = self.velocity * math.pow(0.4, 10 * dt)
        end
    end

    if main.current.paused then return end
    self:move(self.x_vel * self.velocity, self.y_vel * self.velocity, dt)
end

function Player:take_damage(amount)
    self.health = self.health - 1
end

function Player:handle_selecting_nodes(dt)
    local nodes = self.group:query_area(mouse_x, mouse_y, 8, function(o) return o:is(Node) and not o.preview end)
    if #nodes > 0 and not self.tc then
        self.hover_sqr2.x, self.hover_sqr2.y = nodes[1].x, nodes[1].y
        self.hover_sqr2.spring:pull(6)
        self.hover_sqr2.w, self.hover_sqr2.h = nodes[1].radius, nodes[1].radius
        self.hovered_node = nodes[1]
        self.hover_sqr2.hidden = false
        cursor.visible = false
    else
        self.hovered_node = nil
        self.hover_sqr2.hidden = true
        cursor.visible = true
    end


    if not self.connecting1 and input:down "mouse1" then
        self.connecting1 = self.hovered_node
    end

    if self.connecting1 then
        cursor.visible = false
    end
    if input:pressed "mouse1" then
        if self.hovered_node and self.connecting1 == self.hovered_node and not self.tc and self.can_show_stats then
            -- self.hovered_node:show_stats()
        else
            if self.card and not self.card.touching_mouse then
                self.card:destroy()
                self.card = nil
            end
        end

    end

    if input:pressed "mouse3" then
        if self.hovered_node and not self.preview_node then
            -- self:select_node(self.hovered_node.type)
            -- self.hovered_node:destroy()
            self.hovered_node:show_stats()
        else
            if self.card and not self.card.touching_mouse then
                self.card:destroy()
                self.card = nil
            end
        end
    end

    if input:released "mouse1" then
        if self.connecting1 and self.hovered_node and self.hovered_node ~= self.connecting1 then
            self:connect(self.connecting1, self.hovered_node)
        end

        cursor.visible = true
        self.connecting1 = nil
    end

end

function Player:connect(n1, n2)
    local cable = Cable { group = main.current.particles, x = 0, y = 0, c1 = n1, c2 = n2 }
    local fail = n1:add_node(n2, cable)
    n2:add_node(n1, cable)

    if fail then cable.dead = true end
end

function Player:collide_with_drops()
    if self.preview_node then return end

    local drops = main.current.drops:query_area(self.x, self.y, self.pickup_radius,
        function(o) return (o:is(Drop)) end)

    for _, drop in ipairs(drops) do
        if not drop.delivering then
            drop:deliver_to(self)
        end
    end
end

function Player:compare_angle(a1, a2)
    return math.abs(a1 - a2) <= 0.01
end

function Player:rotate_towards(angle, dt)
    if main.current.paused then return end
    local angle_to = self:angle_to(angle)
    self.angle = self.angle + (lume.sign(angle_to) * math.min(self.rotation_speed * dt, math.abs(angle_to)))
end

function Player:add_node_to_queue(node)
    table.insert(self.hovering_nodes, node)
end

function Player:remove_node_from_queue(node)
    for i = #self.hovering_nodes, 1 do
        if self.hovering_nodes == node then
            table.remove(self.hovering_nodes, i)
            break
        end
    end
end

function Player:shoot()
    self.shoot_timer = self.attack_speed
    self.shooting = true
    sfx.hit:play()
    local dirx, diry = vector2.normalize(mouse_x - self.x, mouse_y - self.y)
    local angle = math.atan2(diry, dirx)
    local offx, offy = math.cos(angle) * 12, math.sin(angle) * 12
    MuzzleFlashII { group = self.group, x = self.x + offx, y = self.y + offy, angle = angle, w = 10, h = 10,
        color = colors.white }
    -- Projectile { group = self.group, x = self.x + offx, y = self.y + offy, angle = angle, w = 12, h = 7, dirx = dirx,
    --     diry = diry, speed = 1600, lifetime = 0.3, type = "beam", color = colors.white}
    Projectile { group = self.group, x = self.x + offx, y = self.y + offy, angle = angle, w = 8, h = 3, dirx = dirx,
        diry = diry, velocity = 500, lifetime = 0.3, color = colors.white, damage = 40 }

    HitParticle { group = main.current.main, x = self.x + offx, y = self.y + offy, angle = angle + math.pi / 2,
        x_vel = math.cos(angle - math.pi / 2), y_vel = math.sin(angle - math.pi / 2), speed = 190, w = 8, h = 3,
        lifetime = 0.1, color = colors.white }
    HitParticle { group = main.current.main, x = self.x + offx, y = self.y + offy, angle = angle - math.pi / 2,
        x_vel = math.cos(angle + math.pi / 2), y_vel = math.sin(angle + math.pi / 2), speed = 190, w = 8, h = 3,
        lifetime = 0.1, color = colors.white }
end

function Player:select_node(type)
    main.current.time_scale = 1

    if self.tc then self.tc:destroy() end
    self.tc = nil

    local objs = main.current.main:get_objects(function(o) return o:is(Enemy) or o:is(Node) or o:is(Projectile) end)
    for _, obj in ipairs(objs) do
        obj.paused = false
    end

    self.preview_node = Node { group = main.current.main, x = mouse_x, y = mouse_y, type = type }
end

function Player:draw()
    self.trail:draw()
    love.graphics.push()
    love.graphics.translate(self.x, self.y)
    love.graphics.rotate(self.angle)
    -- graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
    -- love.graphics.circle("line", self.x, self.y, 12)
    graphics.set_color(colors.black)
    love.graphics.polygon('fill', self.polygons[3])
    love.graphics.polygon('fill', self.polygons[2])
    love.graphics.polygon('fill', self.polygons[1])
    graphics.set_color(colors.white)
    love.graphics.polygon('line', self.polygons[3])
    love.graphics.polygon('line', self.polygons[2])
    love.graphics.polygon('line', self.polygons[1])
    graphics.set_color()
    graphics.pop()

    -- graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
    -- images["ship"]:draw(self.x, self.y, 0)
    -- graphics.pop()

    if self.connecting1 then
        if self.hovered_node and self.hovered_node ~= self.connecting1 then
            local angle = math.atan2(self.connecting1.y - self.hovered_node.y, self.connecting1.x - self.hovered_node.x)
            local offx, offy = math.cos(angle) * 8, math.sin(angle) * 8
            graphics.polyline(colors.bg2, 1, self.connecting1.x - offx, self.connecting1.y - offy,
                self.hovered_node.x + offx, self.hovered_node.y + offy)
        else
            local angle = math.atan2(self.connecting1.y - mouse_y, self.connecting1.x - mouse_x)
            local offx, offy = math.cos(angle) * 8, math.sin(angle) * 8
            graphics.polyline(colors.bg2, 1, self.connecting1.x - offx, self.connecting1.y - offy, mouse_x, mouse_y)
            graphics.circle(mouse_x, mouse_y, 4, colors.bg3)
        end
    end
end

HoverSquare = Class:extend()
HoverSquare:implement(GameObject)

function HoverSquare:new(args)
    self:init_game_obj(args)
    self.w, self.h = self.w or 16, self.h or 16
    self.hidden = false
end

function HoverSquare:update(dt)
    self:update_game_obj(dt)
end

function HoverSquare:draw()
    if self.hidden then return end
    graphics.push(self.x, self.y, self.angle, self.sx + self.spring.x, self.sy + self.spring.x)
    local w = self.w
    local w10 = self.w / 2
    local x1, y1 = self.x - w, self.y - w
    local x2, y2 = self.x + w, self.y + w
    -- local lw = math.remap(w, 32, 256, 2, 4)
    local lw = 1
    graphics.polyline(colors.white, lw, x1, y1 + w10, x1, y1, x1 + w10, y1)
    graphics.polyline(colors.white, lw, x2 - w10, y1, x2, y1, x2, y1 + w10)
    graphics.polyline(colors.white, lw, x2 - w10, y2, x2, y2, x2, y2 - w10)
    graphics.polyline(colors.white, lw, x1, y2 - w10, x1, y2, x1 + w10, y2)
    -- graphics.rectangle((x1+x2)/2, (y1+y2)/2, x2-x1, y2-y1, nil, nil, self.color_transparent)
    graphics.pop()
end

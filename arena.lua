Arena = Class:extend()
Arena:implement(State)

function Arena:new(name)
    self:init_state(name)
    self.main = Group():physics()
    self.drops = Group():physics()
    self.ui = Group()
    self.game_ui = Group()
    self.particles = Group()
    self.t = Timer()
    self.prev_mouse_y, self.prev_mouse_x = 0, 0
    arena_width, arena_height = 1224, 1224

    self.triggers = {}

    self.current_wave = 0

    self.dead_enemy_count = 0

    self.building_phase = true

    self.time_scale = 1


    self.waves = {
        [1] = {
            virus = 2,

        },
        [2] = {
            virus = 50,
        },
        [3] = {
            virus = 70
        },
        [4] = {
            virus = 90,
        },
        [5] = {
            virus = 120,
        }
    }
end

function Arena:on_enter(from)
    self.cam = camera
    self.elapsed_time = 0
    self.max_time = 600
    self.enemy_count = 0
    sfx.ost:play()

    self.towers = 0

    -- self.core = Node { group = self.main, x = arena_width / 2, y = arena_height / 2, type = 'core'}


    local g1 = Node { group = self.main, x = arena_width / 2 + 28, y = math.floor(arena_height / 2) - 3, type = 'ammo' }
    g1.preview = false


    local g2 = Node { group = self.main, x = arena_width / 2 - 28 - 8, y = math.floor(arena_height / 2) - 3,
        type = 'ammo' }
    g2.preview = false

    local g3 = Node { group = self.main, x = arena_width / 2 - 4, y = math.floor(arena_height / 2) - 3,
        type = 'overclock' }
    g3.preview = false

    local cable = Cable { group = self.particles, x = 0, y = 0, c1 = g1, c2 = g2 }
    g1:add_node(g2, cable)
    g2:add_node(g1, cable)
    g1:add_node(g3, cable)
    g2:add_node(g3, cable)
    g3:add_node(g1, cable)
    g3:add_node(g2, cable)


    self.player = Player { group = self.main, x = arena_width / 2, y = arena_height / 2 }
    self.camx, self.camy = arena_height / 2, arena_height / 2
    self.cam:setBounds(0 - game_width / 2, 0 - game_height / 2, arena_width + game_width,
        arena_height + game_height)

    self.cam:setFollowStyle('TOPDOWN_TIGHT')
    self.cam:setFollowLerp(0.2)

    self.ui_stuff = Ui { group = self.ui, x = 0, y = 0 }

    camera.x, camera.y = arena_width / 2, arena_height / 2
    self.paused = true
    self.tutorial = true

    self:init_spawning()
    self.spawners = {}
    self.max_enemies = 30
    table.insert(self.spawners, Spawner(4, 60, 10))
    table.insert(self.spawners, Spawner(4, 60, 1))

    local id = 0
    self.extra_enemy_health = 0
    self.t:every(60, function()
        if id == 3 then
            table.insert(self.spawners, Spawner(4, 60, 2, "shield_breaker"))
            self.extra_enemy_health = 100
        end
        if id == 5 then
            table.insert(self.spawners, Spawner(4, 60, 2, "tankboi"))
            self.extra_enemy_health = 200
        end
        if id == 8 then
            table.insert(self.spawners, Spawner(4, 60, 2, "averageboi"))
            self.extra_enemy_health = 300
        end
        if id == 9 then
            table.insert(self.spawners, Spawner(4, 60, 2, "fastboi"))
            table.insert(self.spawners, Spawner(4, 60, 2, "tankboi"))
            table.insert(self.spawners, Spawner(4, 60, 5, "shield_breaker"))
            self.extra_enemy_health = 400
        end

        if id > 4 then
            table.insert(self.spawners, Spawner(4, 60, 2))
        end

        self.max_enemies = self.max_enemies * 1.31
        self.max_enemies = lume.clamp(self.max_enemies, 0, 400)
        table.insert(self.spawners, Spawner(4, 60, 1))
        id = id + 1
    end, 10)

    self.t:after(100, function()
        main.current:set_enemy_count(main.current.enemy_count + 50)
        self.t:every(0.01, function()
            local dist = random(arena_width / 2 + 100, arena_width / 2 + 200)
            local angle = random(0, math.pi * 2)
            local px, py = (arena_width / 2) + math.cos(angle) * dist, (arena_height / 2) + math.sin(angle) * dist
            Enemy { group = main.current.main, x = px, y = py, type = enemy, health = self.enemy_health,
                max_mv_speed = self.enemy_speed, type = choose_random_type() }
        end, 50)
    end)

    self.t:after(180, function()
        main.current:set_enemy_count(main.current.enemy_count + 1)
        local dist = random(arena_width / 2 + 100, arena_width / 2 + 200)
        local angle = random(0, math.pi * 2)
        local px, py = (arena_width / 2) + math.cos(angle) * dist, (arena_height / 2) + math.sin(angle) * dist
        Enemy { group = main.current.main, x = px, y = py, health = self.enemy_health, max_mv_speed = self.enemy_speed,
            type = "eliteboi1" }
    end)

    self.t:after(360, function()
        main.current:set_enemy_count(main.current.enemy_count + 1)
        local dist = random(arena_width / 2 + 100, arena_width / 2 + 200)
        local angle = random(0, math.pi * 2)
        local px, py = (arena_width / 2) + math.cos(angle) * dist, (arena_height / 2) + math.sin(angle) * dist
        Enemy { group = main.current.main, x = px, y = py, health = self.enemy_health, max_mv_speed = self.enemy_speed,
            type = "eliteboi2" }
    end)

    self.t:after(430, function()
        main.current:set_enemy_count(main.current.enemy_count + 1)
        local dist = random(arena_width / 2 + 100, arena_width / 2 + 200)
        local angle = random(0, math.pi * 2)
        local px, py = (arena_width / 2) + math.cos(angle) * dist, (arena_height / 2) + math.sin(angle) * dist
        Enemy { group = main.current.main, x = px, y = py, health = self.enemy_health, max_mv_speed = self.enemy_speed,
            type = "eliteboi3" }
    end)

    self.t:after(300, function()
        main.current:set_enemy_count(main.current.enemy_count + 60)
        self.t:every(0.01, function()
            local dist = random(arena_width / 2 + 100, arena_width / 2 + 200)
            local angle = random(0, math.pi * 2)
            local px, py = (arena_width / 2) + math.cos(angle) * dist, (arena_height / 2) + math.sin(angle) * dist
            Enemy { group = main.current.main, x = px, y = py, health = self.enemy_health,
                max_mv_speed = self.enemy_speed, type = choose_random_type() }
        end, 60)
    end)

    self.t:after(500, function()
        main.current:set_enemy_count(main.current.enemy_count + 100)
        self.t:every(0.01, function()
            local dist = random(arena_width / 2 + 100, arena_width / 2 + 200)
            local angle = random(0, math.pi * 2)
            local px, py = (arena_width / 2) + math.cos(angle) * dist, (arena_height / 2) + math.sin(angle) * dist
            Enemy { group = main.current.main, x = px, y = py, health = self.enemy_health,
                max_mv_speed = self.enemy_speed, type = choose_random_type() }
        end, 100)
    end)
end

function Arena:set_enemy_count(value)
    self.enemy_count = value
end

function Arena:init_spawning()
    self.building_phase = false
    -- self.core:init()

    self.t:after(5, function()
        self.elapsed_time = 0
        self.ui_stuff.wave_progress.hidden = false
        self.ui_stuff.wave_text.hidden = false
        self.ui_stuff.wave_progress.max_value = self.max_time
        self.ui_stuff.wave_progress:animate()
    end)
end

function Arena:stop_spawning()
    self.building_phase = true
    -- self.core:pause_shooting()
    self.dead_enemy_count = 0
    self.enemy_count = 0
    for _, trigger in ipairs(self.triggers) do
        self.t:cancel(trigger)
    end
    self.ui_stuff.wave_progress.hidden = true
    self.ui_stuff.wave_text.hidden = true
end

function Arena:on_exit()
end

function Arena:update(dt)
    self.cam = camera


    -- if input:pressed "test" then
    --     Drop { group = main.current.drops, x = mouse_x, y = mouse_y, type = 'coin', value = 10}
    -- end
    -- if input:pressed "t1" 
    --     Enemy { group = self.main, x = mouse_x, y = mouse_y}
    -- end

    if input:pressed "space" then
        self.paused = not self.paused
        self.tutorial = false
    end

    if input:pressed "esc" then
        self.tutorial = not self.tutorial
        self.paused = self.tutorial
    end

    if not self.paused then
        self.elapsed_time = self.elapsed_time + dt * self.time_scale
        self.t:update(dt * self.time_scale)
    end

    self.particles:update(dt)
    self.drops:update(dt * self.time_scale)
    self.cam:update(dt * self.time_scale)

    local percentage = self.elapsed_time / self.max_time


    if not self.godot and percentage * 100 > 99.9 then
        self.godot = Enemy { group = self.main, x = arena_height / 2, y = arena_width, type = "godot" }
        self.ui_stuff.wave_progress.hidden = true
        self.ui_stuff.wave_text.hidden = true
        self.t:after(5, function()
            self.ui_stuff.wave_progress.hidden = false
            self.ui_stuff.wave_text.hidden = false
            self.ui_stuff.wave_progress.max_value = self.godot.health
            self.ui_stuff.wave_progress:animate()
        end)
    end

    if self.godot then
        if self.godot.dead then
            self.ui_stuff.wave_text.text = "nice the game is over plaeaes close the game"
            self.ui_stuff.wave_progress:update_value(0)
        else
            self.ui_stuff.wave_text.text = "godot_icon.png - " .. self.godot.health .. "/" .. 50000
            self.ui_stuff.wave_progress:update_value(self.godot.health)
        end
    else
        self.ui_stuff.wave_text.text = "Hacking progress: " .. string.format("%.1f", percentage * 100) .. "%"
        self.ui_stuff.wave_progress:update_value(self.elapsed_time)
    end



    self.main:update(dt * self.time_scale)

    self.ui:update(dt)
    self.game_ui:update(dt)


    if self.paused then return end
    for _, spawner in ipairs(self.spawners) do
        spawner:update(dt)
    end

    -- if input:down("space") then
    --     dragging_cam = true
    --     -- self.camx, self.camy = self.camx - mouse_x - self.prev_mouse_x, self.camy - mouse_y - self.prev_mouse_y
    --     self.camx, self.camy = self.camx + (self.prev_mouse_x - screen_mx) / (window_width / game_width),
    --         self.camy + (self.prev_mouse_y - screen_my) / (window_width / game_width)
    -- else
    --     dragging_cam = false
    -- end
    camera:follow(self.player.x, self.player.y)
    self.prev_mouse_x, self.prev_mouse_y = screen_mx, screen_my

end

function Arena:draw()
    self.cam:attach()

    self:draw_grid()
    self.particles:draw()
    self.main:draw()
    self.drops:draw()
    -- self.core:draw()
    self.player:draw()
    self.game_ui:draw()

    self.cam:detach()

    if self.paused then
        graphics.print_centered("- Simulation paused -", game_width / 2, game_height - 13, fonts.m5x7, colors.white)
    end

    if self.tutorial then
        -- love.graphics.setColor(0.0, 0.0, 0.0, 0.8)
        -- love.graphics.rectangle("fill", -200, 200, 9999, 9999)
        local w, h = game_width / 2, game_height - 100
        local accent_color = colors.white
        local padding = 20
        local top = 60
        graphics.rectangle(game_width / 2, game_height / 2, w, h, 0, 0, colors.black2)
        graphics.rectangle(game_width / 2, game_height / 2, w, h, 0, 0, colors.bg2, 1)
        graphics.print_centered("- Hacker survivors man(5) page v7.0 -", w, top + 4, fonts.m5x7, colors.blue)
        graphics.print_centered("------------------------------------------------", 175, top + (padding), fonts.m5x7,
            colors.bg2, 'left')
        graphics.print_centered("Mouse 1: ", 175, top + (padding * 2), fonts.m5x7, accent_color, 'left')
        graphics.print_centered("Build and connect nodes", 462, top + (padding * 2), fonts.m5x7, colors.white, 'right')

        graphics.print_centered("Mouse 2: ", 175, top + (padding * 3), fonts.m5x7, accent_color, 'left')
        graphics.print_centered("Shoot towards mouse position", 462, top + (padding * 3), fonts.m5x7, colors.white,
            'right')

        graphics.print_centered("Mouse 3: ", 175, top + (padding * 4), fonts.m5x7, accent_color, 'left')
        graphics.print_centered("Inspect/umount nodes", 462, top + (padding * 4), fonts.m5x7, colors.white, 'right')

        graphics.print_centered("Space: ", 175, top + (padding * 5), fonts.m5x7, accent_color, 'left')
        graphics.print_centered("Pause the simulation", 462, top + (padding * 5), fonts.m5x7, colors.white, 'right')

        graphics.print_centered("Esc: ", 175, top + (padding * 6), fonts.m5x7, accent_color, 'left')
        graphics.print_centered("Opens this dialog", 462, top + (padding * 6), fonts.m5x7, colors.white, 'right')

        graphics.print_centered("F: ", 175, top + (padding * 7), fonts.m5x7, accent_color, 'left')
        graphics.print_centered("Fullscreen (doesnt work on web or ultra-wide)", 462, top + (padding * 7), fonts.m5x7,
            colors.white, 'right')

        graphics.print_centered("You lose when you have no towers left!", w, top + (padding * 9 - 3), fonts.m5x7,
            colors.white, 'center')
        graphics.print_centered("Press space to start the game", w, top + (padding * 12 - 7), fonts.m5x7, colors.white,
            'center')

    end

    if self.game_over then
        graphics.rectangle(game_width / 2, game_height / 2, 300, 32, 0, 0, colors.black2)
        graphics.rectangle(game_width / 2, game_height / 2, 300, 32, 0, 0, colors.bg2, 1)
        graphics.print_centered("- Game Over -", game_width / 2, game_height / 2 - 9, fonts.m5x7, colors.red)
        graphics.print_centered("just restart the game, i didnt implement restarting >//<", game_width / 2,
            game_height / 2 + 4, fonts.m5x7, colors.white)
    end

    self.ui:draw()

    if cursor.visible then
        love.graphics.draw(cursor.img, screen_mx - cursor.w / 2, screen_my - cursor.h / 2)
    end
end

function Arena:draw_grid()
    local grid_size = 16
    graphics.set_color(colors.gray)
    for x = 0, arena_width / grid_size do
        love.graphics.line(x * grid_size, 0, x * grid_size, arena_height)
    end
    for y = 0, (arena_height / grid_size) do
        love.graphics.line(0, y * grid_size, arena_width, y * grid_size)
    end
    graphics.set_color()
end

Spawner = Class:extend()
function Spawner:new(enemy_health, enemy_speed, cooldown, enemy_type)
    self.enemy_health = enemy_health
    self.enemy_type = enemy_type
    self.enemy_speed = enemy_speed
    self.cooldown = cooldown
    self.spawn_timer = cooldown
end

function Spawner:update(dt)
    self.spawn_timer = self.spawn_timer - dt
    if self.spawn_timer < 0 and main.current.enemy_count < main.current.max_enemies then
        main.current:set_enemy_count(main.current.enemy_count + 1)
        self.spawn_timer = self.cooldown
        local dist = random(arena_width / 2 + 100, arena_width / 2 + 200)
        local angle = random(0, math.pi * 2)
        local px, py = (arena_width / 2) + math.cos(angle) * dist, (arena_height / 2) + math.sin(angle) * dist
        if not self.enemy_type then
            Enemy { group = main.current.main, x = px, y = py, health = self.enemy_health,
                max_mv_speed = self.enemy_speed, type = choose_random_type() }
        else
            Enemy { group = main.current.main, x = px, y = py, health = self.enemy_health,
                max_mv_speed = self.enemy_speed, type = self.enemy_type }
        end
    end
end

function choose_random_type()
    local choice = love.math.random(0, 100)
    if choice > 80 then
        return 'fastboi'
    elseif choice > 35 then
        return 'averageboi'
    else
        return 'tankboi'
    end
end

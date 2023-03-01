--
-- Name: ui.lua
-- Author: ATS

Ui = Class:extend()
Ui:implement(GameObject)

function Ui:new(args)
    self:init_game_obj(args)
    self.p_ammo_text = Text { group = self.group,
        text = "(Ammo) " .. main.current.player.ammo .. '/' .. main.current.player.max_ammo, align = 'right',
        color = colors.white }
    self.p_ammo_text.x, self.p_ammo_text.y = game_width - 10, game_height - 15
    self.p_ammo_bar = ProgressBar { group = self.group, x = game_width - 10, y = game_height - 6, w = 100, align = 'left',
        color = colors.blue, h = 1, max_value = main.current.player.max_ammo }

    -- self.p_material_text = Text { group = self.group, text = "(Material) "..(main.current.player.material or 1 )..'/'..(main.current.player.max_material or 100), align = 'right', color = colors.white}
    -- self.p_material_text.x, self.p_material_text.y = game_width-10, game_height - (15+20)
    -- self.p_material_bar = ProgressBar { group = self.group, x = game_width-10, y = game_height - (6+20), w = 100, align = 'left', color = colors.blue, h = 1}

    self.p_health_text = Text { group = self.group,
        text = "(Health) " .. main.current.player.health .. '/' .. main.current.player.max_health, align = 'left',
        color = colors.white }
    self.p_health_text.x, self.p_health_text.y = 10, game_height - 15
    self.p_health_bar = ProgressBar { group = self.group, x = 10, y = game_height - 6, w = 100, align = 'right',
        color = colors.red, h = 1, max_value = main.current.player.max_health }


    self.wave_text = Text { hidden = true, group = self.group, text = "Active viruses: ", align = 'center',
        color = colors.white }
    self.wave_text.x, self.wave_text.y = game_width / 2, 6
    self.wave_progress = ProgressBar { hidden = true, group = self.group, x = game_width / 2, y = 15, w = 350,
        align = 'center', color = colors.red, h = 1 }

    -- self.gold_text = Text { group = self.group, text = "Gold: " .. main.current.player.gold, align = 'center',
    --     color = colors.white }
    -- self.gold_text.x, self.gold_text.y = game_width / 2, game_height - 14
end

function Ui:update(dt)
    self:update_game_obj(dt)
    -- if not main.current.player then return end
    -- self.gold_text.text = "Gold: " .. main.current.player.gold

    self.p_health_bar:update_value(main.current.player.health)
    self.p_health_text.text = "(Health) " .. main.current.player.health .. "/" .. main.current.player.max_health

    self.p_ammo_text.text = "(Bytes) " .. main.current.player.gold .. "/" .. main.current.player.level_up_gold
    self.p_ammo_bar:update_value(main.current.player.gold)
    self.p_ammo_bar.max_value = main.current.player.level_up_gold
end

function Ui:draw()
end

ProgressBar = Class:extend()
ProgressBar:implement(GameObject)

function ProgressBar:new(args)
    self:init_game_obj(args)
    self.w = self.w or 100
    self.h = self.h or 2
    self.max_value = self.max_value or self.w
    self.value = self.max_value
    self.barw = self.w
    self.color = self.color or colors.white
    self.animated_p = 1
end

function ProgressBar:animate()
    self.animated_p = 0
    if self.anim_trigger then self.t:cancel(self.anim_trigger) end
    self.anim_trigger = self.t:tween(1, self, { animated_p = 1 }, 'out-quad', function() self.animated_p = 1 end)
end

function ProgressBar:update(dt)
    self:update_game_obj(dt)
    -- self:update_value(self.value)
end

function ProgressBar:update_value(value)
    self.value = value
    self.barw = self.w * (self.value / self.max_value)
end

function ProgressBar:draw()
    if self.hidden then return end
    local xx, yy = 0, 0
    local barxx, baryy = 0, 0
    local barw = self.barw
    if self.align == 'left' then
        xx = self.x - self.w
        barxx = self.x
        barw = -barw
    elseif self.align == 'right' then
        xx = self.x
        barxx = self.x
    else
        xx = self.x
        barxx = self.x
    end

    if self.align == 'center' then
        graphics.rectangle(xx, math.floor(self.y), self.w * self.animated_p, self.h, 0, 0, colors.bg2)
        graphics.rectangle(barxx, math.floor(self.y), barw * self.animated_p, self.h, 0, 0, self.color)
    else
        graphics.rectangle2(xx, math.floor(self.y), self.w, self.h, 0, 0, colors.bg2)
        graphics.rectangle2(barxx, math.floor(self.y), barw, self.h, 0, 0, self.color)
    end
    -- graphics.rectangle2(xx, self.y, self.w, self.h, 0, 0, self.color, 1)
end

----------------------------------------------------------------------------------


Text = Class:extend()
Text:implement(GameObject)
function Text:new(args)
    self:init_game_obj(args)
    self.color = self.color or colors.white
    self.font = self.font or fonts.m5x7
    self.w, self.h = self.font:getWidth(self.text), self.font:getHeight(self.text)
end

function Text:update(dt)
    self:update_game_obj(dt)
end

function Text:update_value(value)
    self.text = value
    self.w, self.h = self.font:getWidth(self.text), self.font:getHeight(self.text)
end

function Text:draw()
    if self.hidden then return end
    graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
    graphics.print_centered(self.text, self.x, self.y, self.font, self.color, self.align)
    graphics.pop()
end

Card = Class:extend()
Card:implement(GameObject)

function Card:new(args)
    self:init_game_obj(args)
    self.title = Text { group = self.group, x = self.x, y = self.y, text = '/dev/' .. self.parent.type,
        color = self.color }
    self.teste = Group()
    self.info = {
        -- Text { group = self.teste, text = '(status) '..self:get_status(), align = 'left', color = colors.green2},
        -- Text { group = self.teste, text = '(ammo) '.. self.parent.ammo .. '/' .. self.parent.max_ammo, align = 'left', color = colors.fg2},
        -- Text { group = self.teste, text = '(shield) '.. self.parent.shield .. '/'.. self.parent.max_shield, align = 'left', color = colors.fg2},
        -- Text { group = self.teste, text = '(energy) ' .. self.parent.energy..'/'..self.parent.max_energy, align = 'left', color = colors.fg2},
        -- Text { group = self.teste, text = '(upload) ' .. self.parent.upload_rate .. 'Mbps', align = 'left', color = colors.fg2},
        -- Text { group = self.teste, text = '(download) ' .. self.parent.download_rate .. 'Mbps', align = 'left', color = colors.fg2},
    }
    self.delete_btn = Button { group = self.group, node = 'explosive_gen', parent = self, cool = true, on_click = function()
        main.current.player:select_node(self.parent.type)
        self.parent:destroy()
        self:destroy()
    end }
    self.padding_x = 2
    self.margin = 4
    self.w, self.h = self:calculate_area()

    self.delete_btn.text = "- umount -"

    self.y = self.y - (self.h / 2 + self.title.h + self.delete_btn.h + 4) - self.parent.radius - 30

    self.sx, self.sy = 1, 0.7
    self.t:tween(0.1, self, { sx = 1, sy = 1 }, 'linear')
    self:add_info("status", colors.fg2)
    self:add_info("health", colors.fg2)
    self.touching_mouse = false
end

function Card:post_create()
    self:add_info("download", colors.fg2)
    self:add_info("upload", colors.fg2)
end

function Card:get_status()
    if self.parent.online then
        return 'online'
    else
        return 'offline'
    end
end

function Card:add_info(monitor, color)
    if monitor == "flame" or monitor == "shock" or monitor == "rocket" or monitor == "explosive" then
        return
    end
    table.insert(self.info,
        { text_obj = Text { group = self.group, text = "", align = 'left', color = color or color.white },
            monitor = monitor })
end

function Card:update_info()
    for _, info in ipairs(self.info) do
        if info.monitor == "status" then
            info.text_obj:update_value("(status) " .. self:get_status())
        elseif info.monitor == "health" then
            info.text_obj:update_value("(integrity) " .. self:get_integrity())
        elseif info.monitor == "ammo" then
            info.text_obj:update_value("(ammo) " .. self.parent.ammo .. '/' .. self.parent.max_ammo)
        elseif info.monitor == "shield" then
            info.text_obj:update_value("(shield) " .. self.parent.shield .. '/' .. self.parent.max_shield)
        elseif info.monitor == "energy" then
            info.text_obj:update_value("(energy) " .. self.parent.energy .. '/' .. self.parent.max_energy)
        elseif info.monitor == "material" then
            info.text_obj:update_value("(materials) " .. self.parent.materials .. '/' .. self.parent.max_materials)
        elseif info.monitor == "download" then
            info.text_obj:update_value("(download) " .. self.parent.download_rate .. ' u/s')
        elseif info.monitor == "upload" then
            info.text_obj:update_value("(upload) " .. self.parent.upload_rate .. ' u/s')
        end
    end
    --
    -- self.info = {
    --     Text { group = self.teste, text = '(status) '..self:get_status(), align = 'left', color = colors.fg2},
    --     Text { group = self.teste, text = '(integrity) '..self:get_integrity(), align = 'left', color = colors.fg2},
    --     Text { group = self.teste, text = '(ammo) '.. self.parent.ammo .. '/' .. self.parent.max_ammo, align = 'left', color = colors.fg2},
    --     Text { group = self.teste, text = '(shield) '.. self.parent.shield .. '/'.. self.parent.max_shield, align = 'left', color = colors.fg2},
    --     Text { group = self.teste, text = '(energy) ' .. self.parent.energy..'/'..self.parent.max_energy, align = 'left', color = colors.fg2},
    --     Text { group = self.teste, text = '(upload) ' .. self.parent.upload_rate .. ' Mbps', align = 'left', color = colors.fg2},
    --     Text { group = self.teste, text = '(download) ' .. self.parent.download_rate .. ' Mbps', align = 'left', color = colors.fg2},
    -- }
    --
end

function Card:get_integrity()
    return (math.floor((self.parent.health / self.parent.max_health) * 100) .. "%")
end

function Card:update(dt)
    if self.dead then return end
    self.teste:update(dt)
    self:update_game_obj(dt)
    self:update_info()
    self.title.y = self.y - self.h / 2 - self.title.h + 9
    self.delete_btn.y = self.y + self.h / 2 + self.delete_btn.h / 2 
    self.delete_btn.x = self.x
    self.w, self.h = self:calculate_area()
    self.delete_btn.w = self.w

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

function Card:is_colliding_with_point(px, py)
    return px > self.x - self.w / 2 and px < self.x + self.w - self.w / 2 and py > (self.y - (self.h / 2) - 20) and
        py < (self.y + (self.h - self.h / 2) + 20)
end


function Card:destroy()
    self.delete_btn.dead = true
    self.title.dead = true
    for _, text in ipairs(self.info) do
        text.text_obj.dead = true
    end
    self.info = {}
    self.dead = true
end

function Card:calculate_area()
    local longest = 0
    local w, h = 0, 0
    h = self.margin * 2
    for index, t in ipairs(self.info) do
        local text = t.text_obj
        h = h + (text.h)
        if text.w > longest then
            longest = text.w
            w = text.w + self.margin * 2
        end
    end

    for index, t in ipairs(self.info) do
        local text = t.text_obj
        text.x = (self.x) - w / 2 + self.margin
        text.y = ((self.y + (text.h) * index) - h / 2) - self.title.h + 8 + self.margin / 2
    end


    return w, h
end

function Card:draw()
    graphics.push(self.x, self.y, self.angle, self.sx, self.sy)
    graphics.rectangle(self.x, self.y, self.w, self.h, 0, 0, colors.black)
    self:draw_bg(self.x, self.y, self.w, self.h, 0, 0, colors.black)
    graphics.rectangle(self.x, self.y, self.w, self.h, 0, 0, colors.bg2, 1)
    self:draw_bg(self.title.x, self.title.y, self.w, self.title.h, 0, 0, colors.black)


    graphics.rectangle(self.title.x, self.title.y + 1, self.w, self.title.h, 0, 0, colors.bg2, 1)
    -- self:draw_bg(self.delete_btn.x, self.delete_btn.y + 2, self.w, self.delete_btn.h, 0, 0, colors.black)
    -- graphics.rectangle(self.delete_btn.x, self.delete_btn.y + 2, self.w, self.delete_btn.h, 0, 0, colors.bg2, 1)
    graphics.pop()

    -- graphics.push(self.x, self.y, self.angle, self.sx + self.spring.x, self.sy + self.spring.x)
    self.teste:draw()
end

function Card:draw_bg(x, y, w, h, rx, ry, color)
    graphics.rectangle(x, y, w, h, rx, ry, color)
    for i = 2, h / 2, 1 do
        graphics.rectangle(x, (y - h / 2) + (i * 2), w, 1, rx, ry, colors.gray)
    end
end

TowerChooser = Class:extend()
TowerChooser:implement(GameObject)

function TowerChooser:new(args)
    self:init_game_obj(args)
    self.buttons = {}


    self.title = Text { group = self.group, x = self.x, y = self.y - 36, text = "/dev/gunner", color = colors.green }
    self.desc = Text { group = self.group, x = self.x, y = self.y - 24, text = "shoots bullets at enemies lol" }

    table.insert(self.buttons, Button { group = self.group, node = 'gunner', parent = self })
    table.insert(self.buttons, Button { group = self.group, node = 'ranger', parent = self })
    table.insert(self.buttons, Button { group = self.group, node = 'overclock', parent = self })
    -- table.insert(self.buttons, Button { group = self.group, node = 'shield', parent = self })
    table.insert(self.buttons, Button { group = self.group, node = 'ammo', parent = self })
    -- table.insert(self.buttons, Button { group = self.group, node = 'generator', parent = self})
    -- table.insert(self.buttons, Button { group = self.group, node = 'processing_unit', parent = self})
    table.insert(self.buttons, Button { group = self.group, node = 'shock_gen', parent = self })
    table.insert(self.buttons, Button { group = self.group, node = 'flame_gen', parent = self })
    table.insert(self.buttons, Button { group = self.group, node = 'rocket_gen', parent = self })
    table.insert(self.buttons, Button { group = self.group, node = 'explosive_gen', parent = self })
    table.insert(self.buttons, Button { group = self.group, node = 'shield', parent = self })

    self.w = #self.buttons * self.buttons[1].w - (#self.buttons * 3)
    for index, button in ipairs(self.buttons) do
        button.x = (self.x - self.w / 2) + ((index - 1) * (button.w + 3)) - button.w/2
        button.y = self.y
    end

end

function TowerChooser:destroy()
    self.dead = true
    self.title.dead = true
    self.desc.dead = true
    self.title = nil
    self.desc = nil
    for index, button in ipairs(self.buttons) do
        button.dead = true
    end
end

function TowerChooser:update(dt)
    if self.dead then return end
    self:update_game_obj(dt)

    self.title.text = 'Build device:'
    self.title.color = colors.white
    self.desc.text = 'hover over a device and release the button'

    for _, button in ipairs(self.buttons) do
        if button.touching_mouse then
            self.title.text = '/dev/' .. button.node
            self.title.color = node_to_color[button.node]
            self.desc.text = node_descriptions[button.node]
            break
        end
    end
end

function TowerChooser:draw()
    love.graphics.setColor(0, 0, 0.02, 0.3)
    love.graphics.rectangle("fill", -200, -200, 9999, 9999)
    love.graphics.setColor(1, 1, 1 )
end

Button = Class:extend()
Button:implement(GameObject)

function Button:new(args)
    self:init_game_obj(args)
    self.w, self.h = 20, 20
    self.color = node_to_color[self.node]
end

function Button:update(dt)
    if self.dead then return end
    self:update_game_obj(dt)

    if self.touching_mouse then
        if input:pressed "mouse1" then
            if self.on_click then
                self.on_click()
            else
                main.current.player:select_node(self.node)
            end
        end
    end

    if self.cool then
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
            
        return
    end

    if self:is_colliding_with_point(screen_mx, screen_my) then
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

function Button:draw()
    graphics.rectangle(self.x, self.y, self.w, self.h, 0, 0, colors.black)
    self:draw_bg(self.x, self.y, self.w, self.h, 0, 0, colors.black)
    graphics.rectangle(self.x, self.y, self.w, 2, 0, 0, colors.gray)
    if not self.cool then 
        graphics.circle(self.x, self.y, 5, colors.black)
        graphics.circle(self.x, self.y, 5, self.color, 1)
    end
    graphics.rectangle(self.x, self.y, self.w, self.h, 0, 0, colors.bg2, 1)
    if self.touching_mouse then
        graphics.rectangle(self.x, self.y, self.w, self.h, 0, 0, colors.white, 1)
    end

    if self.text then
        graphics.print_centered(self.text, self.x, self.y - 2, fonts.m5x7, colors.red, 'center')
    end
end

function Button:draw_bg(x, y, w, h, rx, ry, color)
    graphics.rectangle(x, y, w, h, rx, ry, color)
    for i = 2, h / 2, 1 do
        graphics.rectangle(x, (y - h / 2) + (i * 2), w, 1, rx, ry, colors.gray)
    end
end

images          = {}
images["enemy"] = Image("enemy.png")
images["ship"] = Image("ship.png")
images["godot"] = Image("icon.png")

colors        = {}
colors.fg     = Color("#f1f1f1")
colors.fg2    = Color(120, 120, 120)
colors.black  = Color("#000000")
colors.black2  = Color(8, 8, 8)
colors.white  = Color(222, 222, 222)
colors.white2 = Color(160, 160, 160)
colors.bg2    = Color(50, 50, 50)
colors.bg3    = Color(30, 30, 30)
colors.yellow2 = Color("#75602a")
colors.gray   = Color(16, 16, 16)
colors.green  = Color(32, 222, 32)
colors.green2  = Color("#2c9c2c")
colors.purple = Color("#7d2ab8")
colors.blue2  = Color("#2f61c4")
colors.ranger = Color("#2fc488")
colors.blue   = Color("#51AFDD")
colors.yellow = Color(222, 222, 32)
colors.bg     = Color("#0d0d0d")
colors.red    = Color(222, 32, 32)
colors.red2   = Color("#ad0003")
colors.orange = Color(241, 103, 69)

fonts           = {}
-- fonts.futilepro = love.graphics.newFont('assets/fonts/FutilePro.ttf', 16)
fonts.m5x7      = love.graphics.newFont('assets/fonts/m5x7.ttf', 16)


sfx_volume   = 1
sfx          = {}
sfx.ost      = Sound('Through-the-Cosmos.ogg', { volume = .7, loop = true })

sfx.die_tower = Sound('die_tower.ogg', { volume = 0.2 })
sfx.enemy_die4 = Sound('enemy_die4.ogg', { volume = 0.2 })
sfx.enter_material = Sound('enter_material.ogg', { volume = 1 })
sfx.get_material = Sound('get_material.ogg', { volume = 0.2 })
sfx.hit = Sound('hit.ogg', { volume = 0.4 })

for _, font in pairs(fonts) do
    font:setFilter('nearest', 'nearest')
end

if not web then
    for s, _ in pairs(sfx) do
        sfx[s].default_v = sfx[s].volume
    end
end

function update_volume(v)
    for s, _ in pairs(sfx) do
        sfx[s].volume = sfx[s].default_v * sfx_volume
    end
    love.audio.setVolume(sfx.ost.volume * sfx_volume)
    sfx.fail:play()
end

web = true
local moonshine = require 'moonshine'
require 'engine'
require 'assets'
require 'effects'
require 'globals'
require 'ui'
require 'trail'
require 'node'
require 'projectile'
require 'player'
require 'enemy'
require 'arena'

window_width, window_height = 1280, 720
game_width, game_height = 640, 360

show_fps = false

function love.load()

    -- love.window.setVSync(false)

    local img = love.graphics.newImage("assets/images/cursor.png")
    local w, h = img:getDimensions()
    cursor = {
        img = img,
        w = w, h = h,
        visible = true,
    }

    love.mouse.setVisible(false)
    camera = Camera(game_width / window_width, game_height / window_height, game_width, game_height)
    effect = moonshine(moonshine.effects.chromasep)
    effect.chromasep.angle = 2
    effect.chromasep.radius = 1

    input = Input()
    input:bind('f', 'fullscreen')

    input:bind('mouse1', 'mouse1')
    input:bind('mouse2', 'mouse2')
    input:bind('mouse3', 'mouse3')

    input:bind('left', 'left')
    input:bind('right', 'right')

    input:bind('w', 'w')
    input:bind('d', 'd')
    input:bind('s', 's')
    input:bind('a', 'a')

    input:bind('c', 'test')
    input:bind('space', 'space')
    input:bind('escape', 'esc')

    main = Main()
    main:add(Arena('Arena'))
    main:go_to('Arena')
end

function love.update(dt)
    if main then main:update(dt) end

    if input:pressed('fullscreen') then
        -- love.window.setFullscreen(true, )
        push:switchFullscreen()
        camera = Camera(game_width / window_width, game_height / window_height, game_width, game_height)
        camera:follow(arena_height / 2, arena_height / 2)
        camera:setBounds(0 - game_width / 2, 0 - game_height / 2, arena_width + game_width,
            arena_height + game_height)

        camera:setFollowStyle('TOPDOWN_TIGHT')
        camera:setFollowLerp(0.2)
        window_width, window_height = love.graphics.getDimensions()
    end

end

function love.draw()
    push:start()
    effect(function()
        if main then main:draw() end
    end)
    push:finish()

    if show_fps then love.graphics.print(love.timer.getFPS(), 10, 10, 0, 3, 3) end
end

function love.resize(w, h)
    window_width, window_height = w, h
    push:resize(w, h)
end

function love.run()
    return engine_run({
        game_width    = game_width,
        game_height   = game_height,
        window_width  = window_width,
        window_height = window_height,
        game_name     = '(Debug) Hacker Survivors Tower Defense 2 Turbo Deluxe Special Edition',
        canvas        = true,
        pixel_perfect = false,
        resizable     = false,
        icon          = 'assets/images/icon.png'
    })
end

function math.remap(v, old_min, old_max, new_min, new_max)
    return ((v - old_min) / (old_max - old_min)) * (new_max - new_min) + new_min
end

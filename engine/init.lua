local path = ...
require(path .. ".libraries")
require(path .. ".game.spring")
require(path .. ".game.group")
require(path .. ".game.sound")
require(path .. ".game.physics")
require(path .. ".game.state")
require(path .. ".game.image")
require(path .. ".game.anim")
require(path .. ".game.animator")
require(path .. ".graphics.color")
require(path .. ".graphics.graphics")
require(path .. ".game.gameobject")


function engine_run(config)
    love.graphics.setDefaultFilter('nearest', 'nearest')
    local game_width, game_height = config.game_width, config.game_height
    pixel_size = window_width / game_width

    love.window.setTitle(config.game_name)
    love.graphics.setLineStyle(config.line_style or 'rough')
    if config.icon then love.window.setIcon(love.image.newImageData(config.icon)) end

    push:setupScreen(game_width,
        game_height,
        window_width,
        window_height,
        {
            fullscreen = false,
            resizable = config.resizable or false,
            pixelperfect = config.pixel_perfect or false,
            canvas = config.canvas or false,
            msaa = 1,
        })

    love.resize = function(w, h)
        push:resize(w, h)
    end

    love.load()

    if love.math then love.math.setRandomSeed(os.time()) end
    if love.timer then love.timer.step() end

    local dt = 0
    local fixed_dt = 1 / 60
    local accumulator = 0


    screen_mx, screen_my = 0, 0
    global_screen_mx, global_screen_my = 0, 0
    mouse_x, mouse_y = 0, 0

    function mouse_pos()
        return mouse_x, mouse_y
    end

    return function()
        if love.event then
            love.event.pump()
            for name, a, b, c, d, e, f in love.event.poll() do
                if name == 'quit' then
                    if not love.quit or not love.quit() then
                        return a or 0
                    end
                end
                love.handlers[name](a, b, c, d, e, f)
            end
        end

        if love.timer then
            love.timer.step()
            dt = love.timer.getDelta()
        end

        accumulator = accumulator + dt
        while accumulator >= fixed_dt do
            global_screen_mx, global_screen_my = love.mouse.getPosition()
            screen_mx, screen_my = global_screen_mx/(window_width/game_width), global_screen_my/(window_width/game_width)
            mouse_x, mouse_y = camera:toWorldCoords(push:toGame(global_screen_mx, global_screen_my))
            if not mouse_x then
                mouse_x = 0
            end
            if not mouse_y then
                mouse_y = y
            end
            love.update(fixed_dt)
            accumulator = accumulator - fixed_dt
        end

        if love.graphics and love.graphics.isActive() then
            love.graphics.clear(love.graphics.getBackgroundColor())
            love.graphics.origin()
            love.draw()
            love.graphics.present()
        end

        if love.timer then love.timer.sleep(0.001) end
    end
end

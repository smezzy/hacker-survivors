graphics = {}

function graphics.shape(shape, color, line_width, ...)
    local r, g, b, a = love.graphics.getColor()
    if not color and not line_width then
        love.graphics[shape]("line", ...)
    elseif color and not line_width then
        love.graphics.setColor(color.r, color.g, color.b, color.a)
        love.graphics[shape]("fill", ...)
    else
        if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
        love.graphics.setLineWidth(line_width)
        love.graphics[shape]("line", ...)
        love.graphics.setLineWidth(1)
    end
    love.graphics.setColor(r, g, b, a)
end

-- this draws a rectangle centered on x and y (basically, with its pivot on the center)
-- if rx and ry is passed  the rectangle will have rounded corners with that radius
-- if color is passed then the rectangle will be filled with taht color
-- if line_width is passed then the rectangle will not be filled
--color is a color object like
--white {r = 255, g = 255, b = 255, a = 255}

function graphics.rectangle(x, y, w, h, rx, ry, color, line_width)
    graphics.shape("rectangle", color, line_width, x - w / 2, y - h / 2, w, h, rx, ry)
end

-- this draws a rectangle normally just like default love2d, centered on top-left

function graphics.rectangle2(x, y, w, h, rx, ry, color, line_width)
    graphics.shape("rectangle", color, line_width, x, y, w, h, rx, ry)
end

function graphics.circle(x, y, r, color, line_width)
    graphics.shape("circle", color, line_width, x, y, r)
end

function graphics.polyline(color, line_width, ...)
    local r, g, b, a = love.graphics.getColor()
    if color then love.graphics.setColor(color.r, color.g, color.b, color.a) end
    if line_width then love.graphics.setLineWidth(line_width) end
    love.graphics.line(...)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(r, g, b, a)
end

function graphics.arc(arctype, x, y, r, r1, r2, color, line_width)
    graphics.shape("arc", color, line_width, arctype, x, y, r, r1, r2)
end

function graphics.push(x, y, r, sx, sy)
    love.graphics.push()
    love.graphics.translate(x or 0, y or 0)
    love.graphics.scale(sx or 1, sy or sx or 1)
    love.graphics.rotate(r or 0)
    love.graphics.translate(-x or 0, -y or 0)
end

function graphics.pop()
    love.graphics.pop()
end

function graphics.print_centered(text, x, y, font, color, alignment)
    if not font then font = fonts.m5x7 end
    local r, g, b, a = love.graphics.getColor()
    if color then love.graphics.setColor(color.r, color.g, color.b, color.a) else love.graphics.setColor(1, 1, 1) end
    love.graphics.push()
    local txtw, txth = font:getWidth(text), font:getHeight(text)
    if alignment == 'left' then
        txtw = 0
    elseif alignment == 'right' then
        txtw = txtw * 2
    end

    love.graphics.translate(-txtw / 2, -txth / 2)
    local pfont = love.graphics.getFont()
    love.graphics.setFont(font)
    love.graphics.print(text, x, y)
    love.graphics.setFont(pfont)
    love.graphics.pop()
    love.graphics.setColor(r, g, b, a)
end

function graphics.print(text, x, y, font, color)
    local r, g, b, a = love.graphics.getColor()
    if color then love.graphics.setColor(color.r, color.g, color.b, color.a) else love.graphics.setColor(1, 1, 1) end
    love.graphics.push()
    local pfont = love.graphics.getFont()
    love.graphics.setFont(font)
    love.graphics.print(text, x, y)
    love.graphics.setFont(pfont)
    love.graphics.pop()
    love.graphics.setColor(r, g, b, a)
end

function graphics.set_color(color)
    if not color then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(color.r, color.g, color.b)
    end
end

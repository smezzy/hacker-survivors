function uid()
    local fn = function(x)
        local r = love.math.random(16) - 1
        r = (x == "x") and (r + 1) or (r % 4) + 9
        return ("0123456789abcdef"):sub(r, r)
    end
    return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function require_files(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end

function recursive_enumerate(folder)
    local file_list = {}
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        if love.filesystem.getInfo(file).type == 'file' then
            table.insert(file_list, file)
        elseif love.filesystem.getInfo(file).type == 'directory' then
            recursive_enumerate(file)
        end
    end
    return file_list
end

function random(min, max)
    if not max then
        return love.math.random() * min
    else
        if min > max then min, max = max, min end
        return love.math.random() * (max - min) + min
    end
end

function print_table(table)
    if not table then return 'Table is nil' end
    for k, v in pairs(table) do
        print(k, v)
    end
end

function sqr_distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return dx * dx + dy * dy
end

function distance(x1, y1, x2, y2)
    local dx = x1 - x2
    local dy = y1 - y2
    return math.sqrt(dx * dx + dy * dy)
end

function copy_table(table)
    local out = {}
    for k, v in pairs(table) do
        out[k] = v
    end
    return out
end

function random_dir()
    return love.math.random() * love.math.random(-1, 1)
end

function random_dir_int()
    local rand = love.math.random(1, 51)
    if rand > 25 then return 1 else return -1 end
end

function sign(num)
    return num == 0 and 0 or math.abs(num) / num
end

function bool_to_int(bool)
    return bool and 1 or -1
end

function randomdir(min, max)
    return love.math.random() * (max - min) + min
end

function randomint(min, max)
    return (love.math.random(1, 2) - 1) * (max - min) + min
end

function lerp(a, b, t)
    return a * (1 - t) + b * t
end

--[[
    Grupos guardam todos os objetos do jogo, objetos com dead = true são excluidos do grupo
]]
Group = Class:extend()

function Group:new()
    self.objects = {}
end

function Group:update(dt)
    for _, object in ipairs(self.objects) do
        object:update(dt)
    end

    for i = #self.objects, 1, -1 do
        local obj = self.objects[i]
        if obj.dead then
            if obj.world then obj.world:remove(obj) end
            table.remove(self.objects, i)
        end
    end
end

function Group:add(obj)
    table.insert(self.objects, obj)
end

function Group:draw()
    for _, object in ipairs(self.objects) do
        object:draw()
    end
end

function Group:physics(cell_size)
    self.world = bump.newWorld(cell_size or 32)
    return self
end

function Group:y_sort()
    self.y_sort = true
    self.sortFunction = function(a, b)
        return a.y < b.y
    end
    local _draw = self.draw
    self.draw = function(self)
        table.sort(self.objects, self.sortFunction)
        _draw(self)
    end
    return self
end

function Group:query_area(fromx, fromy, radius, select_fn)
    local query = {}
    for _, obj in ipairs(self.objects) do
        if select_fn(obj) then
            local dist = sqr_distance(fromx, fromy, obj.x, obj.y)
            if dist < radius * radius then
                table.insert(query, obj)
            end
        end
    end
    return query
end

function Group:get_objects(select_fn)
    local objs = {}
    for _, obj in ipairs(self.objects) do
        if select_fn(obj) then
            table.insert(objs, obj)
        end
    end
    return objs
end

function Group:get_closest_object(fromx, fromy, radius, select_fn)
    radius = radius or 10000
    local min_dist = math.huge
    local closest
    local objs = self:query_area(fromx, fromy, radius, select_fn)
    for _, obj in ipairs(objs) do
        local dist = sqr_distance(fromx, fromy, obj.x, obj.y)
        if dist < min_dist then
            min_dist = dist
            closest = obj
        end
    end
    return closest
end

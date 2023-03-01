--[[
    Classe de Física
    A classe de fisica deve ser implementada usando Objeto:implement(Physics)
    assim o objeto heradará suas propriedades
    Alguns metodos e propriedades importantes

    self.is_on_floor -> true ou false se estiver ou não no chão
    self.is_on_wall -> 1 se estiver na parede esquerda, -1 na parede direita, e 0 pra nenhuma parede


    self:init_physics(w, h, world)     -> inicia a caixa de colisão com largura w e altura h, world é
                                          o mundo bump, iniciado com bump.newWorld


    self:move(dirx, diry, dt)          -> move o jogador e sua caixa de colisão, mudar o x e y do objeto
                                          também mudara  a posição da hitbox, desde que use self:move() depois


    self:disable_collision_with(...)   -> desabilita colisão com várias entidades usando o filter do bump
                                          ex: self:disable_collision_with("Player", "Bullet", "Circle")
                                          note que as strings são o nome das classes. Para desabilitar a colisão
                                          entre Player e Bullet, ambos Player e Bullet precisam desabilitar a
                                          colisão entre si


    self:add_filter(class, type)  -> Implementar depois, adicionar filtro (touch, slide, cross) etc para class
]]
Physics = Class:extend()

function Physics:init_physics(w, h)
    self.world = self.group.world
    self.w, self.h = w or self.w, h or self.h
    self.world:add(self, self.x - w/2, self.y - h/2, w or self.w, h or self.h)
    self.is_on_wall = 0
    self.is_on_floor = false
end

-- move o jogador
function Physics:move(dirx, diry, dt)
    local actual_x, actual_y, cols, len = self.world:move(self, self.x - self.w / 2 + dirx * dt,
        self.y - self.h / 2 + diry * dt, self.filter)
    self.x, self.y = actual_x + self.w / 2, actual_y + self.h / 2
    self.is_on_floor = false
    self.is_on_wall = 0
    if len > 0 then
        for _, col in ipairs(cols) do
            if self.on_collision_enter then self:on_collision_enter(col) end
            if col.normal.y == -1 then
                self.is_on_floor = true
            end
            if col.normal.x ~= 0 then
                self.is_on_wall = col.normal.x
            end
        end
    end
    if self.check_collisions then self:check_collisions(cols) end
    self.cols = cols
end

function Physics:disable_collision_with_obj(obj)
    if not self.filters then self.filters = {} end
    self.filters[obj.id] = true

    self.filter = function(item, other)
        if self.filters[other.class] or self.filters[other.id] then
            return nil
        else
            return 'slide'
        end
    end
end


function Physics:disable_collision_with(...)
    if not self.filters then self.filters = {} end
    local args = { ... }
    for _, v in ipairs(args) do
        self.filters[v] = true
    end

    self.filter = function(item, other)
        if self.filters[other.class] then
            return nil
        else
            return 'slide'
        end
    end
end


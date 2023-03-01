--[[
    Classe de animação hard badass
    Deve ser implementando usando Object:implement(Animator)


    Propriedades:
    Animator.sprite           -> quad atual, pode ser util para fazer uma trail por exemplo
    Animator.animation        -> string contendo a animação atual
    Animator.paused           -> pausa a animação


    Funçoes:
    Animator:draw_animation   -> desenha o quad atual
    Animator:play_anim(anim)  -> troca pra animação *anim*
]]
Animator = Class:extend()

function Animator:init_animator(default)
    self._tick = 0
    self._curr_frame = 1
    self._sprite_sx = 1
    self._sprite_sy = 1
    self.error_msg = false
    self.founded = false
    self:play_anim(default)
end

function Animator:play_anim(animation)
    if not self.anims[animation] then
        if not self.error_msg then -- temporário
            -- melhor assim, dessa forma, evitamos ter que reiniciar o
            -- jogo toda vez que uma animação dá errado
            print("Animação: " .. animation .. " não encontrada")
            self.error_msg = true -- temporário
        end -- temporário

        self.founded = false -- não achou a animação
        return
    end

    self.founded = true
    if self.animation == animation then return end

    self.error_msg = false -- temporário
    self.animation = animation
    self._curr_frame = 1
    self._tick = 0
    self._curr_anim = self.anims[animation]
    self._duration = self._curr_anim.duration

    self.sprite = self.anims[animation].quads[1]
end

function Animator:stop_anim()
    self.paused = true
end

function Animator:update_animator(dt)
    if self.paused or not self.anims[self.animation] then return end

    if self._tick >= self._duration then
        self._tick = 0

        if self._curr_anim.loop then
            self._curr_frame = self._curr_frame % self._curr_anim.frames
        else
            self._curr_frame = math.min(self._curr_frame, self._curr_anim.frames - 1)
        end

        self._curr_frame = self._curr_frame + 1

        if self._curr_frame == self._curr_anim.frames and not self.ended then
            if not self.loop then self.ended = true end
            if self.on_animation_end then self:on_animation_end(self.animation) end
        end

        self.sprite = self._curr_anim.quads[self._curr_frame]
    end


    self._tick = self._tick + dt


    if self.flip_h then
        self._sprite_sx = -1
    else
        self._sprite_sx = 1
    end

    if self.flip_v then
        self._sprite_sy = -1
    else
        self._sprite_sy = 1
    end
end

function Animator:draw_animation(x, y, angle, sx, sy, ox, oy)
    -- Caso a animação não seja encontrada/não exista, desenhe um bloco.
    -- Acredito que dessa forma o projeto flui melhor, ou seja, sem interrupções
    if self.founded then
        love.graphics.draw(
            self._curr_anim.texture,
            self.sprite,
            x, y, angle,
            self._sprite_sx * (sx or 1),
            self._sprite_sy * (sy or 1),
            ox or self._curr_anim.framew / 2,
            oy or self._curr_anim.frameh / 2
        )
    else
        graphics.rectangle2(self.x - self.w / 2, self.y - self.h / 2, self.w, self.h, 0, 0, Color(255, 255, 0))
        graphics.print_centered("nil", self.x, self.y, nil, Color(0, 0, 0))
    end
end

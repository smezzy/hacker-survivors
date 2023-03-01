function load_quads(img, spriteW, spriteH)
    local img = img
    local w, h
    local spriteSheet = {}
    local spriteCounter = 1

    if img then
        w = img:getWidth() / spriteW
        h = img:getHeight() / spriteH
    else
        error("Você esqueceu de adicionar uma imagem no 1# da função loadQuads")
    end

    for y = 0, h - 1 do
        for x = 0, w - 1 do
            spriteSheet[spriteCounter] = love.graphics.newQuad(
                x * spriteW, y * spriteH,
                spriteW, spriteH,
                img:getDimensions()
            )

            spriteCounter = spriteCounter + 1
        end
    end

    return spriteSheet
end

-- Imagem precisa ser criada usando função Image()
function Anim(texture, hframes, vframes, duration, loop)
    if not texture then error("Imagem não encontrada") end
    local s    = {}
    s.texture  = texture.image -- folha de sprite da animação
    s.quads    = load_quads(texture.image, texture.w / hframes, texture.h / vframes)
    s.framew   = texture.w / hframes
    s.frameh   = texture.h / vframes
    s.frames   = #s.quads
    s.duration = duration and 1 / duration or
        0.5 -- duração baseada em frames por segundo (30 de curação seria 30 frames por segundo)
    s.loop     = loop or false

    return s
end

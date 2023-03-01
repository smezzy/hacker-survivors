--classe de imagem massa pra desenha centralizado sem estress
function Image(name)
  local self = {}
  self.image = love.graphics.newImage('assets/images/' .. name)
  self.image:setFilter("nearest", "nearest")
  self.w, self.h = self.image:getDimensions()

  function self:draw(x, y, r, sx, sy)
    love.graphics.draw(self.image, x, y, r, sx, sy, self.w / 2, self.h / 2)
  end

  function self:draw2(x, y, r, sx, sy, ox, oy)
    love.graphics.draw(self.image, x, y, r, sx, sy, ox, oy)
  end

  return self
end

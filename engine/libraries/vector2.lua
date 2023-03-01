local Vector2 = {}

function Vector2.length(x, y)
   return math.sqrt(x * x + y * y)
end

function Vector2.normalize(x, y)
   local len = Vector2.length(x, y)
   if len > 0 then
      return x / len, y / len
   end
   return x, y
end

function Vector2.set_length(x, y, len)
   x = len / x
   y = len / y
   return x, y
end

function Vector2.clamp(x, y, max)
   if Vector2.length(x, y) > max then
      x, y = Vector2.set_length(x, y, max)
   end
   return x, y
end

return Vector2

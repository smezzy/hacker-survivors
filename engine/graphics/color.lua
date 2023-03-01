-- Colors can be created  using
--rgb
-- clr = Color(255, 255, 255, 1)
--hex
-- clr = Color("#ffffff", 1)
--or % from 0 to 1
-- clr = Color(1, 1, 1, 1)
Color = Class:extend()

function Color:new(r, g, b, a)
   if type(r) == "string" then
      r = r:gsub("#", "")
      self.r = tonumber("0x" .. r:sub(1,2))/255
      self.g = tonumber("0x" .. r:sub(3,4))/255
      self.b = tonumber("0x" .. r:sub(5,6))/255
      self.a = g or 1
   elseif r > 1 or g > 1 or b > 1 then
      self.r = r/255
      self.g = g/255
      self.b = b/255
      self.a = a or 1
   else
      self.r = r
      self.g = g
      self.b = b
      self.a = a or 1
   end

   return self
end

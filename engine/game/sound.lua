Sound = function(asset_name, options)
   if web then
      local src = love.audio.newSource('assets/sounds/' .. asset_name, 'static')
      if options.loop then src:setLooping(true) end
      return {
         src = src,
         volume = options.volume,
         default_v = options.volume,
         play = function(self)
            love.audio.setVolume(self.volume * sfx_volume)
            if not options.loop then self.src:setPitch(random(0.8, 1.2)) end
            self.src:stop()
            self.src:play()
            love.audio.setVolume(sfx_volume)
         end,
         stop = function(self)
            self.src:stop()
         end
      }
   end
   return ripple.newSound(love.audio.newSource('assets/sounds/' .. asset_name, 'static'), options)
end

function play_sound(sound, name)
   love.audio.setVolume(sound.volume * sfx_volume)
   sound.src:stop()
   sound.src:play()
   return src
end

SoundTag = ripple.newTag
Effect = love.audio.setEffect


--tag example

--sfx = SoundTag()
--sfx.volume = state.sfx_volume
--good for configuration menu

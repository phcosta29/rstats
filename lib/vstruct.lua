    function dofile (init.lua)
      local f = assert(loadfile(init.lua))
      return f()
    end


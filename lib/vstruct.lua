    function dofile ('init.lua')
      f = assert(loadfile('init.lua'))
      return f()
    end

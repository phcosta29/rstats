    function dofile (filename)
      f = assert(loadfile(filename))
      return f()
    end

    dofile("init.lua")

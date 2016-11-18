function dofile(filename)
  local f = assert (loadfile(filename))
  return f ()
end

local val = dofile("init.lua")

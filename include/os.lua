
local io_write = io.write
function os.pexecute(cmd)
    io_write(cmd)
    io_write('\n')
    return os.execute(cmd)
end

function os.capture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return string.sub(s, 1, #s - 1)
end

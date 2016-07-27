
function os.pexecute(...)
    print(...)
    os.execute(...)
end

function os.capture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return string.sub(s, 1, #s - 1)
end

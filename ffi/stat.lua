-- experimental

local ffi = require 'ffi'
ffi.cdef[[
int stat(const char *, long *);
]]

local has_ffi_bindings = false

local stat = {}

print(ffi.sizeof('long'))
local statbuf = ffi.new('long[18]')
function stat.last_modified(path)
    -- speedier for my comp
    if ffi.os == 'OSX' and ffi.arch == 'x64' then
        if ffi.C.stat(path, statbuf) == -1 then
            error('bad path for stat')
        end
        local result = statbuf[5] -- could be 7? it should be 6
        return result
    else -- fallback to slow command
        local cmd
        if ffi.os == 'OSX' then
            cmd = 'stat -f "%Sm" -t "%s" "'..path..'"'
        else
            -- linux
            cmd = 'stat -c %Y "'..path..'"'
        end
        return tonumber(os.capture(cmd))
    end
end

return stat

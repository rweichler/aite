-- experimental

local ffi = require 'ffi'
ffi.cdef[[
int stat(const char *, long *);
]]

local has_ffi_bindings = false

local stat = {}

local statbuf = ffi.new('long[18]')
local C = ffi.C
local is_64bit_osx = ffi.os == 'OSX' and ffi.arch == 'x64'

function stat.last_modified(path)
    -- speedier for my comp
    if is_64bit_osx then
        if C.stat(path, statbuf) == -1 then
            error('bad path for stat')
        end
        return statbuf[5] -- could be 7? it should be 6
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

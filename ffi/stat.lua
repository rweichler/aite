-- experimental

local ffi = require 'ffi'
ffi.cdef[[
int stat(const char *, long *);
]]

local stat = {}

if ffi.os == 'OSX' and ffi.arch == 'x64' then
    local statbuf = ffi.new('long[18]')
    local C = ffi.C
    function stat.last_modified(path)
        if C.stat(path, statbuf) == -1 then
            error('bad path for stat')
        end
        return statbuf[5] -- could be 7? it should be 6
    end
end

return stat

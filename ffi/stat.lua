-- experimental

local ffi = require 'ffi'
ffi.cdef[[
int stat(const char *, long *);
]]

local stat = {}

if ffi.os == 'OSX' and (ffi.arch == 'x64' or ffi.arch == 'arm64') then
    local statbuf = ffi.new('long[18]')
    local C = ffi.C
    function stat.last_modified(path)
        if C.stat(path, statbuf) == -1 then
            error('bad path for stat')
        end
        if ffi.arch == 'x64' then
            return statbuf[5]
        elseif ffi.arch == 'arm64' then
            return statbuf[6]
        end
    end
end

return stat

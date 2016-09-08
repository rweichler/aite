fs = {}
-- Lua implementation of PHP scandir function
function fs.scandir(directory)
    local i = 0
    local t = {}
    local pfile = io.popen('ls '..directory)
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

local find = string.find
local function lastIndexOf(haystack, needle)
    local i, j
    local k = 0
    repeat
        i = j
        j, k = find(haystack, needle, k + 1, true)
    until j == nil

    return i
end

function fs.replace_ext(path, ext)
    return string.sub(path, 1, lastIndexOf(path, '.'))..ext
end

function fs.isdir(path)
    local dir = ffi.C.opendir(path)
    if dir == ffi.NULL then
        return false
    else
        ffi.C.closedir(dir)
        return true
    end
end

-- use faster func if ffi allows it
fs.last_modified = require('ffi.stat').last_modified or function(path)
    -- fallback to slower terminal-based command if not
    local cmd
    if ffi.os == 'OSX' then
        cmd = 'stat -f "%Sm" -t "%s" "'..path..'"'
    else
        -- linux
        cmd = 'stat -c %Y "'..path..'"'
    end
    return tonumber(os.capture(cmd))
end

function fs.isfile(path)
    local f = io.open(path, 'r')
    if f then
        io.close(f)
        return true
    else
        return false
    end
end

function fs.mkdir(path, skip_last)
    if skip_last then
        path = string.sub(path, 1, lastIndexOf(path, '/') - 1)
    end
    return os.execute('mkdir -p '..path) == 0
end

ffi.cdef[[
typedef void * DIR;
DIR * opendir(const char *dirname);
int closedir(DIR *dirp);
]]

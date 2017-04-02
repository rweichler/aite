fs = {}
-- Lua implementation of PHP scandir function
function fs.scandir(directory)
    local i = 0
    local t = {}
    local cmd = 'ls'
    if ffi.os == 'Windows' then
        cmd = 'dir /b'
        directory = string.gsub(directory, '/', '\\')
    end
    local pfile = io.popen(cmd..' '..directory)
    for filename in pfile:lines() do
        i = i + 1
        t[i] = filename
    end
    pfile:close()
    return t
end

function fs.getcwd()
    if ffi.os == 'Windows' then
        return os.capture('cd')
    else
        return os.capture('pwd')
    end
end

function fs.find(directory, ext)
    if not ext then
        ext = directory
        directory = '.'
    end
    local cmd
    if ffi.os == 'Windows' then
        cmd = 'for /r '..string.gsub(directory, '/', '\\')..' %f in ('..ext..') do @echo %f'
    else
        cmd = 'find '..directory..' -type f -name "'..ext..'"'
    end
    local i = 0
    local t = {}
    local pfile = io.popen(cmd)
    local cwd = fs.getcwd()
    for filename in pfile:lines() do
        i = i + 1
        if ffi.os == 'Windows' then
            filename = string.gsub(filename, string.gsub(cwd, '%-', '%%%-')..'\\', '')
        end
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

fs.is_dir = fs.isdir

-- use faster func if ffi allows it
fs.last_modified = require('ffi.stat').last_modified or function(path)
    -- fallback to slower terminal-based command if not
    local cmd
    if ffi.os == 'OSX' or ffi.os == 'BSD' then
        cmd = 'stat -f "%Sm" -t "%s" "'..path..'"'
    elseif ffi.os == 'Windows' then
        return 0 -- TODO actually implement this
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

fs.is_file = fs.isfile

function fs.mkdir(path, skip_last)
    if skip_last then
        local last_index = lastIndexOf(path, '/') or lastIndexOf(path, '\\')
        if not last_index then
            -- means we're doing `mkdir .`
            return true
        end
        path = string.sub(path, 1, last_index - 1)
    end
    if ffi.os == 'Windows' then
        return os.execute('if not exist "'..path..'" mkdir '..path) == 0
    else
        return os.execute('mkdir -p '..path) == 0
    end
end

fs.make_dir = fs.mkdir

ffi.cdef[[
typedef void * DIR;
DIR * opendir(const char *dirname);
int closedir(DIR *dirp);
]]

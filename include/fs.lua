fs = {}
-- Lua implementation of PHP scandir function
function fs.scandir(directory, filter)
    local i = 0
    local t = {}
    local pfile = io.popen('ls "'..directory..'"')
    for filename in pfile:lines() do
        if not filter or filter(filename) then
            i = i + 1
            t[i] = filename
        end
    end
    pfile:close()
    return t
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
function fs.mkdir(path)
    local folder = ''
    local split = string.split(path, '/')
    for i,v in ipairs(split) do
        folder = folder..v..'/'
        os.execute('mkdir -p "'..folder..'"')
    end
end

ffi.cdef[[
typedef void * DIR;
DIR * opendir(const char *dirname);
int closedir(DIR *dirp);
]]

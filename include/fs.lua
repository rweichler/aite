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

function fs.wildcard(ext, folder)
    if not folder then folder = '.' end

    return fs.scandir(folder, function(path)
        local i, j =  string.find(path, ".*%."..ext)
        return i == 1 and j == #path
    end)
end

function fs.replace_ext(path, ext)
    local split = string.split(path, '.')
    split[#split] = ext
    return table.concat(split, '.')
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

function fs.isfile(path)
    local f = io.open(path, 'r')
    if f then
        io.close(f)
        return not fs.isdir(path)
    else
        return false
    end
end

function fs.mkdir(path, skip_last)
    local folder = ''
    local split = string.split(path, '/')
    for i,v in ipairs(split) do
        if skip_last and i == #split then
            break
        end
        folder = folder..v..'/'
        if os.execute('mkdir -p "'..folder..'"') ~= 0 then
            return false
        end
    end
    return true
end

ffi.cdef[[
typedef void * DIR;
DIR * opendir(const char *dirname);
int closedir(DIR *dirp);
]]

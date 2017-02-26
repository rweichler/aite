#!/usr/bin/env luajit

local start_time = os.time()
BUILD_RULES_FILENAME = 'how2build.lua'

function os.capture(cmd)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  return string.sub(s, 1, #s - 1)
end

local function get_folder_from_path(path)
    local function string_split(self, sep)
        local fields = {}
        local pattern = string.format("([^%s]+)", sep)
        string.gsub(self, pattern, function(c) fields[#fields+1] = c end)
        return fields
    end

    local separator = '/'
    if require('ffi').os == 'Windows' then
        separator = '\\'
    end

    local components = string_split(path, separator)
    components[#components] = nil
    return (string.sub(path,1,1) == separator and separator or '')..table.concat(components, separator)
end

local function where_is_main_dot_lua()
    local cmd = arg[0]
    local symlink = os.capture('readlink "'..cmd..'"')
    if #symlink == 0 then
        return get_folder_from_path(cmd)
    elseif not (string.sub(symlink, 1, 3) == '../') then
        return get_folder_from_path(symlink)
    end
    -- get absolute path
    return get_folder_from_path(get_folder_from_path(get_folder_from_path(cmd))..'/'..string.sub(symlink, 4, #symlink))
end

AITE_FOLDER = where_is_main_dot_lua()

local folder = AITE_FOLDER
local target = arg[1] or 'default'

package.path = package.path..';'..folder..'/?.lua'..
                             ';'..folder..'/?/init.lua'..
                             ';'..folder..'/deps/?.lua'..
                             ';'..folder..'/deps/?/init.lua'

local get_func
local function get_func(self, i)
    self = self or _G
    self = _G[target]
    i = i or 1
    if type(self) == 'function' then
        return self
    elseif type(self) == 'table' then
        i = i + 1
        self = self[arg[i]]
        if self then
            return get_func(self)
        else
            -- TODO this error could be better
            -- like blah.balh.balh
            -- error("No function for '"..arg[i].."' found :(")
            return nil
        end
    else
        --error(target..' is not a function')
        return nil
    end
end

require('include/init')
local f = get_func()
if f then
    io.write(GREEN())
    io.write('Running internal aite function "')
    io.write(target)
    io.write('"')
    io.write(NORMAL)
    io.write('\n')
else
    local success, err = xpcall(dofile, debug.traceback, BUILD_RULES_FILENAME)
    if not success then
        print(RED('ERROR: ')..tostring(err))
        EXITCODE = 1
        return
    end
     f = get_func()
end

if f then
    local x = {...}
    table.remove(x, 1)
    local success, err = xpcall(f, debug.traceback,  unpack(x))
    if not success then
        print(RED("ERROR: ")..tostring(err)..'\n'..GREEN('Keep in mind this might be caused by an outdated version of aite. Update aite with the command `aite update`.'))
        EXITCODE = 1
    end
else
    print("No function for '"..target.."' found :(")
    EXITCODE = 1
end

if TIME_IT then
    print('it took '..(os.time() - start_time)..' sec')
end

if finish then
    finish(...)
end

os.exit(EXITCODE or 0)

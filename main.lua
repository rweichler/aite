#!/usr/bin/env luajit

local function where_is_main_dot_lua()
    local function string_split(self, sep)
        local fields = {}
        local pattern = string.format("([^%s]+)", sep)
        string.gsub(self, pattern, function(c) fields[#fields+1] = c end)
        return fields
    end

    local components = string_split(arg[0], '/')
    components[#components] = nil
    return table.concat(components, '/')
end

local folder = where_is_main_dot_lua()
local target = arg[1] or 'default'

package.path = package.path..';'..folder..'/?.lua'
package.path = package.path..';'..folder..'/?/init.lua'

require('include/init')

dofile('targets.lua')
local f = _G[target]
if f then
    f()
else
    print("No function for '"..target.."' found :(")
end

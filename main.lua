local args = {...}

local folder = args[1]
local target = args[2]

package.path = package.path..';'..folder..'/?.lua'
package.path = package.path..';'..folder..'/?/init.lua'

require('include/init')

dofile(folder..'/targets.lua')
local f = _G[target]
if f then
    f()
else
    print("No function for '"..target.."' found :(")
end

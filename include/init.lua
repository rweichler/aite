ffi = require 'ffi'
require 'include/object'
require 'include/fs'
require 'include/os'
require 'include/builder'
require 'include/debber'
require 'include/printcolors'
require 'include/string'
require 'include/table'

function update()
    os.execute('git -C '..AITE_FOLDER..' pull origin master')
end

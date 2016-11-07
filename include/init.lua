ffi = require 'ffi'
require 'include.object'
require 'include.fs'
require 'include.os'
require 'include.builder'
require 'include.debber'
require 'include.printcolors'
require 'include.string'
require 'include.table'

function update()
    os.execute('git -C '..AITE_FOLDER..' pull origin master')
end

function quick(toolchain, ...)
    if toolchain == 'nil' then
        toolchain = nil
    end
    local b = builder(toolchain)
    b.compiler = 'gcc'
    b.src = {...}
    b.build_dir = '.aitequickbuild'
    b.output = 'a.out'
    b:link(b:compile())
    os.execute('rm -r .aitequickbuild')
end

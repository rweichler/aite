-- this is called when `make` is
-- given no arguments
function default()
    local c = builder('apple')
    c.compiler = 'clang++'
    c.include_dirs = {
        '/usr/local/include',
        '/opt/X11/include'
    }
    c.library_dirs = {
        '/usr/local/lib',
        '/opt/X11/lib'
    }
    c.libraries = {
        'glfw3',
        'glew'
    }
    c.frameworks = {
        'OpenGL',
        'Foundation'
    }
    c.sflags = '-std=c++14'
    c.src = table.merge(fs.wildcard('cpp', 'src'), fs.wildcard('mm', 'src'))
    c.src_folder = 'src'
    c.build_folder = 'out/build'
    c.output = 'out/layout/Library/MobileSubstrate/DynamicLibraries/lol.dylib'

    local d = debber()
    d.input = 'out/layout'
    d.output = 'lol.deb'
    d.packageinfo = {
        Package = 'com.yo.daddy',
        Version = 1.0,
        Architecture = 'iphoneos-arm',
    }

    c:link(c:compile())
    d:make_deb()
end

-- `make clean`
function clean()
    os.pexecute("rm -rf out")
end

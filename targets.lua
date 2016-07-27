
-- `make` or `make default`
function default()
    local b = builder('apple')
    b.compiler = 'clang++'
    b.linker = 'clang++'
    b.include_dirs = {
        '/usr/local/include',
        '/opt/X11/include'
    }
    b.library_dirs = {
        '/usr/local/lib',
        '/opt/X11/lib'
    }
    b.libraries = {
        'glfw3',
        'glew'
    }
    b.frameworks = {
        'OpenGL'
    }
    b.sflags = '-std=c++14'
    b.src_ext = 'cpp'
    b.src_folder = 'cpp'
    b.build_folder = 'build/cpp'
    b.output = 'a.out'

    b:build()
end

-- `make clean`
function clean()
    os.pexecute("rm -rf bin build")
end

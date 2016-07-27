
-- this is called when `make` is
-- given no arguments
function default()
    local c = builder('apple')
    c.compiler = 'clang++'
    c.include_dirs = {
        '/usr/local/include',
        '/opt/X11/include'
    }
    c.sflags = '-std=c++14'
    c.src_ext = 'cpp'
    c.src_folder = 'src'
    c.build_folder = 'build'

    local c_obj = c:compile()

    c.src_ext = 'm'
    local m_obj = c:compile()

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
    c:link(table.merge(c_obj, m_obj))
end

-- `make clean`
function clean()
    os.pexecute("rm -rf bin build")
end

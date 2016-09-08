-- this is called when `aite` is
-- called with no arguments
function default()
    -- cleanup old layout folder
    os.pexecute("rm -rf layout")

    -- setup compiler
    local b = builder('apple')
    b.compiler = 'clang'
    b.build_dir = 'build' -- put all .o files in 'build'
    b.src = fs.scandir('*.m') --compile all .m files in current directory
    b.frameworks = {
        'UIKit',
        'Foundation'
    }
    b.output = 'layout/MobileSubstrate/DynamicLibraries/my_sick_tweak.dylib'

    -- compile
    local objs = b:compile()
    -- link
    b:link(objs)

    -- setup debber
    local d = debber()
    d.input = 'layout'
    d.output = 'lmfao.deb'
    d.packageinfo = {
        Name = 'LMFAO',
        Package = 'com.apple.lmfao',
        Version = 1.0,
    }

    -- create deb file
    d:make_deb()
end

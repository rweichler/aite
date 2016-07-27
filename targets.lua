
-- `make` or `make default`
function default()
    local b = builder('apple')
    --b.sdk = 'iphoneos'
    --b.archs = {'armv7', 'arm64'}
    b.frameworks = {'Foundation'}
    b.src_ext = 'c'
    b.src_folder = 'c'
    b.build_folder = 'build/c'
    b.compiler = 'clang'
    b.linker = 'clang'
    b.output = 'bin/a.dylib'

    fs.mkdir('bin')
    b:build()
end

-- `make clean`
function clean()
    os.pexecute("rm -rf bin build")
end

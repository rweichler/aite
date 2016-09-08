function default()
    local b = builder()
    b.compiler = 'gcc'
    b.build_dir = 'build'
    b.src = {'main.c'}
    b.output = 'a.out'
    b:link(b:compile())
end

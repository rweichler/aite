builder = object()

function builder:new(kind)
    local self = object.new(self, kind)
    if kind then
        local sub = require('include/builders/'..kind)
        self = self:subclass(sub)
    end
    self.build_dir = self.build_dir or '.'
    self.output = self.output or 'a.out'
    return self
end


function builder:set_ldflags(ldflags)
    self._ldflags = ldflags
end

function builder:get_ldflags()
    local ldflags = self._ldflags or ''
    local libraries = ''
    if self.library_dirs then
        for i,v in ipairs(self.library_dirs) do
            libraries = libraries..' -L'..v
        end
    end
    if self.libraries then
        for i,v in ipairs(self.libraries) do
            libraries = libraries..' -l'..v
        end
    end
    return ldflags..' '..libraries
end

function builder:set_cflags(cflags)
    self._cflags = cflags
end

function builder:get_cflags()
    local cflags = self._cflags or ''
    local include = ''
    if self.include_dirs then
        for i,v in ipairs(self.include_dirs) do
            include = include..' -I'..v
        end
    end
    return cflags..' '..include
end

function builder:set_sflags(sflags)
    self._sflags = sflags
end

function builder:get_sflags()
    local sflags = self._sflags or ''
    return sflags
end

function builder:compile()
    -- args
    local compiler = assert(self.compiler, 'compiler not set (e.g. "clang" or "gcc" or "javac")')
    local src = assert(self.src, 'src not set (e.g. {"main.c"})')
    local linker = compiler or self.linker
    local build_dir = self.build_dir
    local cflags = self.cflags
    local ldflags = self.ldflags
    local sflags = self.sflags
    local output = self.output

    -- flags
    local execute = self.verbose and os.pexecute or os.execute
    local pretty_print = not self.verbose and not self.quiet
    local quiet = self.quiet

    -- printing shit
    if not quiet then
        print(PINK('building '..table.concat(self.src, ', ')..':'))
    end


    -- actual shit

    local obj = {}

    for i,v in ipairs(src) do
        fs.mkdir(build_dir..'/'..v, true)
        local o = fs.replace_ext(v, 'o')
        -- compile
        local compiler = v.compiler or compiler
        local cflags = cflags..' '..(v.cflags or '')
        if pretty_print then
            print('    '..YELLOW(compiler)..RED(' <')..DARK_RED('--- ')..v)
        end
        local command = compiler..' '..v..' -c -o '..build_dir..'/'..o..' '..cflags..' '..sflags
        local success = execute(command) == 0

        if not success then
            print(RED("ERROR: ").."Couldn't compile "..v..". Set "..YELLOW("builder.verbose = true").." for more details.")
            os.exit(1)
        end

        -- setup obj
        obj[#obj + 1] = build_dir..'/'..o
    end

    return obj

end

function builder:link(obj)
    -- args
    local linker = self.linker or assert(self.compiler, 'linker not set (e.g. "clang" or "gcc" or "javac")')
    local ldflags = self.ldflags
    local sflags = self.sflags
    local output = self.output

    -- flags
    local execute = self.verbose and os.pexecute or os.execute
    local pretty_print = not self.verbose and not self.quiet
    local quiet = self.quiet
    -- link
    if pretty_print then
        print(YELLOW('link')..DARK_RED(' ---')..RED('> ')..GREEN(output))
    end
    fs.mkdir(output, true)
    local success = execute(linker..' '..table.concat(obj, ' ')..' -o '..output..' '..ldflags..' '..sflags) == 0

    if not success then
        print(RED("ERROR: ").."Couldn't link "..output..". Set "..YELLOW("builder.verbose = true").." for more details.")
        os.exit(1)
    end
end

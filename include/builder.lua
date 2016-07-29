builder = object()

function builder:new(kind)
    local self = object.new(self, kind)
    if kind then
        local sub = require('include/builders/'..kind)
        self = self:subclass(sub)
    end
    self.src_folder = self.src_folder or '.'
    self.build_folder = self.build_folder or '.'
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
    local include = '-I'..self.src_folder
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
    local src_folder = self.src_folder
    local build_folder = self.build_folder
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
        print(PINK('building ('..table.concat(self.src, ', ')..') in '..src_folder..':'))
    end


    -- actual shit

    local obj = {}

    fs.mkdir(build_folder)
    for i,v in ipairs(src) do
        local o = fs.replace_ext(v, 'o')
        -- compile
        local compiler = v.compiler or compiler
        local cflags = cflags..' '..(v.cflags or '')
        if pretty_print then
            print('    '..YELLOW(compiler)..RED(' <')..DARK_RED('--- ')..v)
        end
        execute(compiler..' '..src_folder..'/'..v..' -c -o '..build_folder..'/'..o..' '..cflags..' '..sflags)

        -- setup obj
        obj[#obj + 1] = build_folder..'/'..o
    end

    return obj

end

function builder:link(obj)
    -- args
    local compiler = assert(self.compiler, 'compiler not set (e.g. "clang" or "gcc" or "javac")')
    local linker = compiler or self.linker
    local src_folder = self.src_folder
    local build_folder = self.build_folder
    local cflags = self.cflags
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
    execute(linker..' '..table.concat(obj, ' ')..' -o '..output..' '..ldflags..' '..sflags)
end

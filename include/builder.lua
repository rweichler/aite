builder = object()

local getsources

function builder:new(kind)
    local self = object.new(self, kind)
    if kind then
        local sub = require('include/builders/'..kind)
        self = self:subclass(sub)
    end
    return self
end

local function wildcard(pattern)
    return function(path)
        return string.find(path, pattern)
    end
end

local function getsources(self)
    local obj = {}
    for i,v in ipairs(src) do
        obj[#obj + 1] = string.gsub(v, "(.*)%."..self.src_ext, "%1.o")
    end
    return src, obj
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

function builder:get_src()
    local src_ext = assert(self.src_ext, 'src_ext not set (e.g. "c" or "cpp" or "java")')
    if self._src then
        return self._src
    end

    local r = {}
    local src = fs.scandir(self.src_folder, wildcard(".*%."..src_ext)) 
    for i,v in ipairs(src) do
        local t = {}
        r[#r + 1] = t
        t.obj = string.gsub(v, "(.*)%."..src_ext, "%1.o")
        t.src = v
    end
    return r
end

function builder:build(flags)
    -- args
    local compiler = assert(self.compiler, 'compiler not set (e.g. "clang" or "gcc" or "javac")')
    local linker = compiler or self.linker
    local src_folder = self.src_folder or '.'
    local build_folder = self.build_folder or '.'
    local cflags = self.cflags
    local ldflags = self.ldflags
    local sflags = self.sflags
    local output = self.output or 'a.out'

    -- flags
    local execute
    local pretty_print = false
    local quiet = false
    if flags == 'verbose' then
        execute = os.pexecute
    else
        execute = os.execute
        if flags == 'quiet' then
            quiet = true
        else
            pretty_print = true
        end
    end

    -- printing shit
    if not quiet then
        print('building .'..self.src_ext..' files in '..src_folder..':')
    end


    -- actual shit

    local src = self.src
    local obj = {}

    fs.mkdir(build_folder)
    for i,v in ipairs(src) do
        -- compile
        local compiler = v.compiler or compiler
        local cflags = cflags..' '..(v.cflags or '')
        if pretty_print then
            print('    '..YELLOW(compiler)..RED(' <')..DARK_RED('--- ')..v.src)
        end
        execute(compiler..' '..src_folder..'/'..v.src..' -c -o '..build_folder..'/'..v.obj..' '..cflags..' '..sflags)

        -- setup obj
        obj[#obj + 1] = build_folder..'/'..v.obj
    end

    -- link
    if pretty_print then
        print(YELLOW('link')..DARK_RED(' ---')..RED('> ')..GREEN(output))
    end
    execute(linker..' '..table.concat(obj, ' ')..' -o '..output..' '..ldflags..' '..sflags)

end

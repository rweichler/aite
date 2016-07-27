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
    return self._ldflags or ''
end

function builder:set_cflags(cflags)
    self._cflags = cflags
end

function builder:get_cflags()
    return self._cflags or ''
end

function builder:set_sflags(sflags)
    self._sflags = sflags
end

function builder:get_sflags()
    return self._sflags or ''
end

function builder:get_src()
    if self._src then
        return self._src
    end

    local r = {}
    local src = fs.scandir(self.src_folder, wildcard(".*%."..self.src_ext)) 
    for i,v in ipairs(src) do
        local t = {}
        r[#r + 1] = t
        t.obj = string.gsub(v, "(.*)%."..self.src_ext, "%1.o")
        t.src = v
    end
    return r
end

function builder:build(flags)
    -- args
    local compiler = assert(self.compiler, 'compiler not set (e.g. "clang" or "gcc")')
    local linker = assert(self.linker, 'linker not set (e.g. "clang" or "gcc"')
    local src_folder = self.src_folder or '.'
    local build_folder = self.build_folder or '.'
    local cflags = self.cflags
    local ldflags = self.ldflags
    local sflags = self.sflags
    local output = assert(self.output, 'output not set (e.g. "a.out" or "a.exe")')

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

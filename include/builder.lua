builder = object()

if ffi.os == 'OSX' then
    builder.dylib_ext = 'dylib'
elseif ffi.os == 'Windows' then
    builder.dylib_ext = 'dll'
else -- just assume its something like Linux or BSD
    builder.dylib_ext = 'so'
end

function builder:new(kind)
    if kind then
        local sub = require('include/builders/'..kind)
        self = sub:new()
    else
        self = object.new(self, kind)
    end
    if self.should_skip == nil then
        self.should_skip = true
    end
    return self
end

function builder:get_output()
    local bin = self.bin
    local output = self._output
    if bin and output then
        error('either builder.bin or builder.output must be nil', 3)
    elseif bin then
        return self.build_dir..'/'..bin
    elseif output then
        return output
    end
end

function builder:set_output(output)
    self._output = output
end

function builder:get_is_making_dylib()
    if not(self._is_making_dylib == nil) then
        return self._is_making_dylib
    end
    return  string.has_suffix(self.output, '.dylib')
        or string.has_suffix(self.output, '.so')
        or string.has_suffix(self.output, '.dll')
end

function builder:set_is_making_dylib(k)
    self._is_making_dylib = k
end

function builder:set_ldflags(ldflags)
    self._ldflags = ldflags
end

function builder:get_ldflags()
    local ldflags = self._ldflags or ''
    if self.is_making_dylib then
        if ffi.os == 'OSX' then
            ldflags = ldflags..' -dynamiclib'
        else
            ldflags = ldflags..' -shared'
        end
    end
    if self.library_dirs then
        for i,v in ipairs(self.library_dirs) do
            ldflags = ldflags..' -L'..v
        end
    end
    if self.libraries then
        for i,v in ipairs(self.libraries) do
            ldflags = ldflags..' -l'..v
        end
    end
    if self.dylib_install_name then
        if not self.is_making_dylib then
            error('builder.dylib_install_name is set, but not making a .dylib/.so/.dll')
        end
        ldflags = ldflags..' -install_name '..self.dylib_install_name
    end
    return ldflags
end

function builder:set_cflags(cflags)
    self._cflags = cflags
end

function builder:get_cflags()
    local cflags = self._cflags or ''
    if self.include_dirs then
        for i,v in ipairs(self.include_dirs) do
            cflags = cflags..' -I'..v
        end
    end
    if self.defines then
        for k,v in pairs(self.defines) do
            if type(k) == 'number' then
                cflags = cflags..' -D'..v
            else
                cflags = cflags..' -D'..k.."='"..v.."'"
            end
        end
    end
    if self.is_making_dylib and (ffi.os == 'Linux' or ffi.os == 'BSD') then
        cflags = cflags..' -fPIC'
    end
    return cflags
end

function builder:set_sflags(sflags)
    self._sflags = sflags
end

function builder:get_sflags()
    local sflags = self._sflags or ''
    return sflags
end

local math_floor = math.floor
local function num_chars(num)
    local count = 0
    while num > 0 do
        count = count + 1
        num = math_floor(num / 10)
    end
    return count
end

local io_write = io.write
local fs_isfile = fs.isfile

local build_rules_last_modified
if fs.isfile(BUILD_RULES_FILENAME) then
    build_rules_last_modified = fs.last_modified(BUILD_RULES_FILENAME)
else
    build_rules_last_modified = 0
end

function builder:compile()
    local err = ''
    -- args
    local build_dir = self.build_dir or error('builder.build_dir not set (e.g. "build")', 2)
    local output = self.output or error('builder.output not set (e.g. "tweak.dylib" or "a.out")', 2)
    local compiler = self.compiler or error('builder.compiler not set (e.g. "gcc" or "clang")')
    local src = self.src or error('builder.src not set (e.g. {"main.c"} or fs.scandir("*.c"))', 2)
    local linker = compiler or self.linker
    local cflags = self.cflags
    local ldflags = self.ldflags
    local sflags = self.sflags
    local should_skip = self.should_skip

    -- flags
    local execute = self.verbose and os.pexecute or os.execute
    local pretty_print = not self.verbose and not self.quiet
    local quiet = self.quiet

    -- actual shit

    local obj = {}

    if type(src) == 'string' then
        src = {src}
    end

    for i,v in ipairs(src) do
        local separator = '/'
        if ffi.os == 'Windows' then
            separator = '\\'
            v = string.gsub(v, '/', separator)
            build_dir = string.gsub(v, '/', separator)
        end
        local o = build_dir..separator..v..'.o'
        fs.mkdir(o, true)

        -- setup obj
        obj[#obj + 1] = o
        local o_last_modified = fs_isfile(o) and fs.last_modified(o)
        if should_skip and o_last_modified and o_last_modified > fs.last_modified(v) and o_last_modified > build_rules_last_modified then
            if pretty_print then
                io_write('    ')
                io_write(DARK_CYAN())
                io_write('skipping')
                io_write(NORMAL)
                io_write(' ')
                io_write(v)
                io_write(DARK_CYAN())
                io_write(' (already compiled)')
                io_write(NORMAL)
                io_write('\n')
            end
        else
            -- compile
            if pretty_print then
                io_write('    ')
                if self.show_count or #src > 9 and self.show_count == nil then
                    for i=1,num_chars(#src)-num_chars(i) do
                        io_write(' ')
                    end
                    io_write(PINK())
                    io_write(i)
                    io_write('/')
                    io_write(#src)
                    io_write(' ')
                end
                io_write(YELLOW())
                io_write(compiler)
                io_write(NORMAL)
                io_write(' ')
                io_write(v)
                io_write('\n')
            end
            local command = compiler..' '..v..' -c -o '..o..' '..cflags..' '..sflags
            local success = execute(command) == 0

            if not success then
                error("Couldn't compile "..v..". Set "..YELLOW("builder.verbose = true").." for more details.", 2)
            end
        end

    end

    return obj

end

function builder:link(obj)
    -- args
    local linker = self.linker or assert(self.compiler, 'linker not set (e.g. "clang" or "gcc")')
    local ldflags = self.ldflags
    local sflags = self.sflags
    local output = self.output

    -- flags
    local execute = self.verbose and os.pexecute or os.execute
    local pretty_print = not self.verbose and not self.quiet
    local quiet = self.quiet

    if self.should_skip and fs.isfile(output) and fs.last_modified(output) > build_rules_last_modified then
        local output_is_older = true
        for k,v in pairs(obj) do
            if fs.last_modified(output) < fs.last_modified(v) then
                output_is_older = false
                break
            end
        end

        if output_is_older then
            if pretty_print then
                io_write('    ')
                io_write(DARK_CYAN())
                io_write('skipping ')
                io_write(GREEN())
                io_write(output)
                io_write(NORMAL)
                io_write(DARK_CYAN())
                io_write(' (already linked)')
                io_write(NORMAL)
                io_write('\n')
            end
            return
        end
    end
    -- link
    if pretty_print then
        io_write('    ')
        io_write(YELLOW())
        if self.linker then
            io_write(linker)
            io_write(' ---> ')
        else
            io_write('---> ')
        end
        io_write(GREEN())
        io_write(output)
        io_write(NORMAL)
        io_write('\n')
    end
    fs.mkdir(output, true)
    local success = execute(linker..' '..table.concat(obj, ' ')..' -o '..output..' '..ldflags..' '..sflags) == 0

    if not success then
        error("Couldn't link "..output..". Set "..YELLOW("builder.verbose = true").." for more details.", 2)
    end
end

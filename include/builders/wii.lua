local super = builder
local builder = super()

builder.DEVKITPPC = os.getenv('DEVKITPPC') or error('$DEVKITPPC not set')
builder.DEVKITPRO = os.getenv('DEVKITPRO') or error('$DEVKITPRO not set')
builder.toolchain_prefix = builder.DEVKITPPC..'/bin/powerpc-eabi-'

function builder:get_compiler()
    return self._compiler
end

function builder:set_compiler(compiler)
    self._compiler = self.toolchain_prefix..compiler
end

function builder:get_sflags()
    local sflags = super.get_sflags(self)
    sflags = sflags..'-g -DGEKKO -mrvl -mcpu=750 -meabi -mhard-float'
    return sflags
end

function builder:get_cflags()
    local cflags = super.get_cflags(self)
    cflags = cflags..'-Wall -O2 -I'..self.DEVKITPRO..'/libogc/include'
    return cflags
end

function builder:get_ldflags()
    local ldflags = super.get_ldflags(self)
    ldflags = ldflags..'-L'..self.DEVKITPRO..'/libogc/lib/wii -lwiiuse -lbte -logc -lm'
    return ldflags
end

local function check_dol(self)
    if not string.has_suffix(self.output, '.dol') then
        error('output extension must be .dol')
    end
end

function builder:compile(...)
    check_dol(self)

    return super.compile(self, ...)
end

function builder:link(obj)
    check_dol(self)

    local pre = string.sub(self.output, 1, #self.output - 4)
    self.output = self.build_dir..'/output.elf'
    super.link(self, obj)
    print('    '..GREEN(self.output)..YELLOW(' ---> ')..GREEN(pre..'.dol'))
    os.execute(builder.DEVKITPPC..'/bin/elf2dol '..self.output..' '..pre..'.dol')
end

return builder

local super = builder
local builder = super()

builder.DEVKITARM = os.getenv('DEVKITARM') or error('$DEVKITARM not set')
builder.DEVKITPRO = os.getenv('DEVKITPRO') or error('$DEVKITPRO not set')
builder.toolchain_prefix = builder.DEVKITARM..'/bin/arm-none-eabi-'

function builder:get_compiler()
    return self._compiler
end

function builder:set_compiler(compiler)
    self._compiler = self.toolchain_prefix..compiler
end

function builder:parse_sflags()
    local sflags = super.parse_sflags(self)
    sflags = sflags..' -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft'
    return sflags
end

function builder:parse_cflags()
    local cflags = super.parse_cflags(self)
    cflags = cflags..' -g -Wall -O2 -mword-relocations -fomit-frame-pointer -ffunction-sections -I'..self.DEVKITPRO..'/libctru/include -I'..self.DEVKITPRO..'/portlibs/armv6k/include -DARM11 -D_3DS'
    return cflags
end

function builder:parse_ldflags()
    local ldflags = super.parse_ldflags(self)
    ldflags = ldflags..' -specs=3dsx.specs -g -L'..self.DEVKITPRO..'/libctru/lib -L'..self.DEVKITPRO..'/portlibs/armv6k/lib -lctru -lm'
    return ldflags
end

function builder:link(obj)
    super.link(self, obj)
end

return builder

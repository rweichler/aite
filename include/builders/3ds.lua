local super = builder
local builder = super()

local DEVKITARM = os.getenv('DEVKITARM') or error('$DEVKITARM not set')
local DEVKITPRO = os.getenv('DEVKITPRO') or error('$DEVKITPRO not set')

function builder:get_compiler()
    return self._compiler
end

function builder:set_compiler(compiler)
    self._compiler = DEVKITARM..'/bin/arm-none-eabi-'..compiler
end

function builder:get_sflags()
    local sflags = super.get_sflags(self)
    sflags = sflags..' -march=armv6k -mtune=mpcore -mfloat-abi=hard -mtp=soft'
    return sflags
end

function builder:get_cflags()
    local cflags = super.get_cflags(self)
    cflags = cflags..' -g -Wall -O2 -mword-relocations -fomit-frame-pointer -ffunction-sections -I'..DEVKITPRO..'/libctru/include -DARM11 -D_3DS'
    return cflags
end

function builder:get_ldflags()
    local ldflags = super.get_ldflags(self)
    ldflags = ldflags..' -specs=3dsx.specs -g -L'..DEVKITPRO..'/libctru/lib -lctru -lm'
    return ldflags
end

function builder:link(obj)
    super.link(self, obj)
end

return builder

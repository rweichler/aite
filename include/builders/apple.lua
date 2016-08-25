local super = builder
local builder = super()

function builder:get_sdk_path()
    if self._sdk_path then
        return self._sdk_path
    elseif self.sdk then
        assert(os.execute('command -v xcrun > /dev/null') == 0, "sdk set, but xcrun isn't found")
        return os.capture('xcrun --sdk '..self.sdk..' --show-sdk-path')
    end
end

function builder:set_sdk_path(sdk_path)
    self._sdk_path = sdk_path
end

function builder:get_sflags()
    local sflags = super.get_sflags(self)
    local arch = ''
    local isysroot = self.sdk_path and '-isysroot "'..self.sdk_path..'"' or ''
    if self.archs then
        for i,v in ipairs(self.archs) do
            arch = arch..' -arch '..v
        end
    end
    return sflags..' '..arch..' '..isysroot
end

function builder:get_is_making_dylib()
    local suffix = '.dylib'
    if string.has_suffix(self.output, '.dylib') then
        return true
    else
        return false
    end
end

function builder:get_ldflags()
    local ldflags = super.get_ldflags(self)
    local dylib = self.is_making_dylib and '-dynamiclib' or ''
    local frameworks = ''
    if self.frameworks then
        frameworks = frameworks..' -F/System/Library/PrivateFrameworks'
        for i,v in ipairs(self.frameworks) do
            frameworks = frameworks..' -framework '..v
        end
    end

    if not self.disable_ios9_workaround then
        ldflags = ldflags..' -Wl,-segalign,4000'
    end

    return ldflags..' '..frameworks..' '..dylib
end

function builder:link(obj)
    super.link(self, obj)

    -- flags
    local execute = self.verbose and os.pexecute or os.execute
    local pretty_print = not self.verbose and not self.quiet

    if pretty_print then
        print(YELLOW('sign ')..self.output)
    end

    execute("ldid -S "..self.output)

end

return builder

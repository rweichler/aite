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

function builder:parse_sflags()
    local sflags = super.parse_sflags(self)
    local arch = ''
    local isysroot = self.sdk_path and '-isysroot "'..self.sdk_path..'"' or ''
    if self.archs then
        for i,v in ipairs(self.archs) do
            arch = arch..' -arch '..v
        end
    end
    return sflags..' '..arch..' '..isysroot
end

function builder:parse_ldflags()
    local ldflags = super.parse_ldflags(self)
    local frameworks = ''
    if self.frameworks then
        local private_dir = self.sdk_path..'/System/Library/PrivateFrameworks'
        if fs.isdir(private_dir) then
            frameworks = frameworks..' -F"'..private_dir..'"'
        end
        for i,v in ipairs(self.frameworks) do
            frameworks = frameworks..' -framework '..v
        end
    end

    if not self.disable_ios9_workaround then
        ldflags = ldflags..' -Wl,-segalign,4000'
    end

    return ldflags..' '..frameworks..' '
end

local function check_array(t)
    local i = 0
    for k,v in pairs(t) do
        i = i + 1
        if not(i == k) then
            return false
        end
    end
    return true
end

local function write_plist(f, v, level)
    level = level or 0
    local indent = ''
    for i=1,level do
        indent = indent..'\t'
    end
    local type = type(v)
    if type == 'table' then
        local is_array = check_array(v)
        f:write(indent..'<'..(is_array and 'array' or 'dict')..'>\n')
        for k,v in pairs(v) do
            if not is_array then
                f:write(indent..'\t<key>'..k..'</key>\n')
            end
            write_plist(f, v, level + 1)
        end
        f:write(indent..'</'..(is_array and 'array' or 'dict')..'>\n')
    elseif type == 'boolean' then
        f:write(indent..'<'..tostring(v)..'/>\n')
    elseif type == 'string' then
        f:write(indent..'<string>'..v..'</string>\n')
    elseif type == 'number' then
        if math.floor(v) == v then
            f:write(indent..'<integer>'..v..'</integer>\n')
        else
            f:write(indent..'<real>'..v..'</real>\n')
        end
    else
        error('cannot serialize type '..type)
    end
end

function builder:sign(bin)
    local execute = self.verbose and os.pexecute or os.execute
    local ldid = (self.toolchain_prefix or '')..'ldid'

    if self.entitlements then
        local path = self.build_dir..'/aite_entitlements.plist'
        local f = io.open(path, 'w')
        f:write('<?xml version="1.0" encoding="UTF-8"?>\n')
        f:write('<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n')
        f:write('<plist version="1.0">\n')
        write_plist(f, self.entitlements)
        f:write('</plist>')
        f:close()

        execute(ldid..' -S'..path..' '..bin)

        os.remove(path)
    else
        execute(ldid..' -S '..bin)
    end
end

function builder:link(obj)
    if not super.link(self, obj) then return end

    -- flags
    local execute = self.verbose and os.pexecute or os.execute
    local pretty_print = not self.verbose and not self.quiet

    if pretty_print then
        io.write(YELLOW())
        io.write('ldid ')
        io.write(GREEN())
        io.write(self.output)
        io.write(NORMAL)
        io.write('\n')
    end

    self:sign(self.output)

    return true
end

return builder

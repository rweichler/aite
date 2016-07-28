debber = object()

function debber:new()
    local self = object.new(self)
    self.options = self.options or "-Zgzip"
    return self
end

function debber:make_deb()

    local input = self.input or error('input not set (e.g. a folder called "layout")')

    local output = self.output or (function ()
        local pwd = os.capture('pwd')
        pwd = string.split(pwd, '/')
        pwd = pwd[#pwd]
        error('output not set (e.g. a file called "'..pwd..'.deb")')
    end)()

    local execute = self.verbose and os.pexecute or os.execute
    local pretty_print = not self.verbose and not self.quiet
    local quiet = self.quiet
    if pretty_print then
        print(YELLOW('dpkg-deb')..DARK_RED(' ---')..RED('> ')..GREEN(output))
    end

    local packageinfo = self.packageinfo
    local created_DEBIAN = false
    if packageinfo then
        if not packageinfo.Version then
            error("packageinfo.Version not set")
        end
        if not packageinfo.Package then
            error("packageinfo.Package not set")
        end
        if not fs.isdir(input..'/DEBIAN') then
            created_DEBIAN = true
            if not fs.mkdir(input..'/DEBIAN') then
                error("packageinfo set, but could not create "..self.input.."/DEBIAN folder")
            end
        end
        local f = io.open(input..'/DEBIAN/control', 'w')
        for k,v in pairs(packageinfo) do
            f:write(k..': '..v..'\n')
        end
        io.close(f)
    elseif fs.isfile(input..'/DEBIAN/control')  then
        print(RED("Warning:").." using a DEBIAN/control file is deprecated. Use debber.packageinfo instead.")
    else
        error('packageinfo not set (e.g. {Package = "lol.wut", Version = "1.0"})')
    end

    local tail = ''
    if not self.verbose then
        tail = ' &> /dev/null'
    end
    local success = execute("dpkg-deb "..self.options.." -b "..input.." "..output..tail) == 0

    if created_DEBIAN then
        os.execute('rm -r '..input..'/DEBIAN')
    elseif packageinfo then
        os.execute('rm '..input..'/DEBIAN/control')
    end

    if not success then
        local lol = ""
        if not packageinfo then
            lol = "Probably because you're using a DEBIAN/control file."
        end
        error("Couldn't create "..output..". "..lol.." Use make_deb('verbose') for more details.")
    end

    return success
end

local md5 = require 'md5'
debber = object()

function debber:new()
    local self = object.new(self)
    self.options = self.options or "-Zgzip"
    self.command = self.command or 'dpkg-deb'
    return self
end

function debber:print_packageinfo()
    local packageinfo = self.packageinfo
    local debfile = self.output
    if not packageinfo then
        error("packageinfo not set", 2)
    elseif not debfile then
        error("output not set", 2)
    end
    if not packageinfo.Package then
        error("packageinfo.Package not set", 2)
    elseif not packageinfo.Version then
        error("packageinfo.Version not set", 2)
    end
    local f, err = io.open(debfile, 'r')
    if not f then
        error("could not open output file '"..debfile.."' ("..err..")", 2)
    end


    local first = {Package = true, Name = true, Version = true}
    print('Package: '..packageinfo.Package)
    if packageinfo.Name then
        print('Name: '..packageinfo.Name)
    end
    print('Version: '..packageinfo.Version)
    for k,v in pairs(packageinfo) do
        if not first[k] then
            print(k..': '..v)
        end
    end
    local contents = f:read("*all")
    local md5sum = md5.sumhexa(contents)
    local size = f:seek("end")
    io.close(f)
    print('MD5sum: '..md5sum)
    print('Size: '..size)
    print('Filename: ./debs/'..debfile)
end

function debber:make_deb()

    local input = self.input or error('input not set (e.g. a folder called "layout")', 2)

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
        print(YELLOW(self.command)..DARK_RED(' ---')..RED('> ')..GREEN(output))
    end

    local packageinfo = self.packageinfo
    if packageinfo then
        if not packageinfo.Version then
            error("packageinfo.Version not set", 2)
        end
        if not packageinfo.Package then
            error("packageinfo.Package not set", 2)
        end
        if not fs.isdir(input..'/DEBIAN') then
            if not fs.mkdir(input..'/DEBIAN') then
                error("packageinfo set, but could not create "..self.input.."/DEBIAN folder", 2)
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
        error('packageinfo not set (e.g. {Package = "lol.wut", Version = "1.0"})', 2)
    end

    local result = execute(self.command.." "..(self.options or "").." -b "..input.." "..output)
    local success = result == 0 or result == true

    if not success then
        local lol = packageinfo and "" or " Probably because you're using a DEBIAN/control file."
        error("Couldn't create "..output.."."..lol.." Set "..YELLOW("debber.verbose = true").." for more details.", 2)
    end

    return success
end

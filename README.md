# Aite

i know you're probably groaning right now, and im sorry. i am. but makefiles BLOW. and this isnt that hard to install, its just 4 commands:

(remember to change `/some/directory` to an actual directory on your computer)

```bash
cd /some/directory
git clone https://github.com/rweichler/aite
cd /usr/local/bin
ln -s /some/directory/aite/main.lua aite
```

boom. now you can say `aite` to your computer.

# Dependencies

* macOS
* LuaJIT (`brew install luajit`)
* dpkg-deb (`brew install dpkg-deb`)

## WTF is `how2build.lua`?

its basically `Makefile`.

right now its way uglier than theos, but LOOK AT THE LEVEL OF CONTROL YOU HAVE. HOLY SHIT!!

```lua
-- this is called when `aite` is
-- called with no arguments
function default()
    -- cleanup old layout folder
    os.pexecute("rm -rf layout")

    -- setup compiler
    local b = builder('apple')
    b.compiler = 'clang'
    b.build_dir = 'build' -- put all .o files in 'build'
    b.src = fs.scandir('*.m') --compile all .m files in current directory
    b.frameworks = {
        'UIKit',
        'Foundation'
    }
    b.output = 'layout/MobileSubstrate/DynamicLibraries/my_sick_tweak.dylib'

    -- compile
    local objs = b:compile()
    -- link
    b:link(objs)

    -- setup debber
    local d = debber()
    d.input = 'layout'
    d.output = 'lmfao.deb'
    d.packageinfo = {
        Name = 'LMFAO',
        Package = 'com.apple.lmfao',
        Version = 1.0,
    }

    -- create deb file
    d:make_deb()
end
```

You can have multiple functions in there, for different stuff. You'd call it with `aite function_name`. `aite` by itself translates to `aite default`.

# Documentation

## Using builder

So there are two ways to do this.

* `local b = builder()`
* `local b = builder('apple')`

I'd recommend always having 'apple' in there. That way you get these:

* `b.frameworks`: Apple frameworks you want to link with. Public or private.
* `b.archs`: table listing of the archs you want to use (e.g. `armv7`, `arm64`, `x86_64`)
* `b.sdk`: name of the SDK you wanna link against (e.g. `iphoneos` or `macosx`)
* `b.sdk_path`: the full path to the iPhoneOS8.1.sdk (or whatever), in case if you don't have Xcode.


These are the ones included by default, no matter what:

* `b.compiler` (string): e.g. `gcc` or `clang`
* `b.src` (table): The source files you'll be compiling
* `b.build_dir` (string): The folder where you want all the ugly `.o` files to go.
* `b.output` (string): Where the executable should go. Add `.dylib` to the end to make a dylib that can be dynamically loaded.
* `b.defines` (table): What you want `#define`d at compile time.

Advanced ones: 

* `b.linker` (string): The linker. If this isn't set, it will use `b.compiler`.
* `b.include_dirs` (table): the folders you wanna include from (like rpetrich's iphoneheaders or something)
* `b.library_dirs` (table): the folders you wanna look in for libraries.
* `b.libraries` (table): the libraries you want to link to.

## Using debber

Create it using this:

```lua
local d = debber()
d.input = 'layout' -- folder where the "layout" of the deb will be
d.output = 'package.deb' -- self-explanitory
d.packageinfo = { -- equivalent of the DEBIAN/control file
    Name = 'Yeee',
    Package = 'yee.yee.yee',
    Version = '1.0',
}
```

Run it using this:

```lua
d:make_deb()
```

Calculate the md5sum, size, etc so you can put it in your repo and print it out like this:

```lua
d:print_packageinfo()
```


# Things to keep in mind

* Logos isn't supported yet. Maybe it never will be.

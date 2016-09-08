# Aite

this is my personal build system I use to make all of my projects (and sometimes other people's)

i promise this isnt that hard to install, its just 4 commands:

(remember to change `/some/directory` to an actual directory on your computer)

```bash
cd /some/directory
git clone https://github.com/rweichler/aite
cd /usr/local/bin
ln -s /some/directory/aite/main.lua aite
```

boom. now you can say `aite` to your computer.

# Compatibility

* Mac OS X
* Linux
* Windows?? (It worked in Cygwin... you need to do `luajit.exe /some/directory/main.lua` though instead of `aite`)

# Dependencies

* LuaJIT

## WTF is `how2build.lua`?

its basically `Makefile`. heres an example:

```lua
function default()
    local b = builder()
    b.compiler = 'gcc'
    b.build_dir = 'build'
    b.src = {'main.c'}
    b.output = 'a.out'
    b:link(b:compile())
end
```

Check out the examples folder for more.

Also, can have multiple functions in there, for different stuff. You'd call it with `aite function_name`. `aite` by itself translates to `aite default`.

# Documentation

## Using builder

```lua
local b = builder()
```

* `b.compiler` (string): e.g. `'gcc'` or `'clang'`
* `b.src` (table): The source files you'll be compiling. e.g. `{'main.m'}` or `fs.scandir('*.m')`
* `b.build_dir` (string): The folder where you want all the ugly `.o` files to go. e.g. `'build'`
* `b.output` (string): Where the executable should go. Add `.dylib` or `.so` or `.dll` to the end to make a dynamic library.
* `b.defines` (table): What you want `#define`d at compile time.

Advanced ones: 

* `b.linker` (string): The linker. If this isn't set, it will use `b.compiler`.
* `b.include_dirs` (table): the folders you wanna include from (like rpetrich's iphoneheaders or something)
* `b.library_dirs` (table): the folders you wanna look in for libraries.
* `b.libraries` (table): the libraries you want to link to.

## Convenience functions

Let's say you're trying to build some monolithic codebase with a bunch of nested C++ files.

```lua
b.src = table.merge(
            fs.scandir('*.cpp'),
            fs.scandir('*/*.cpp'),
            fs.scandir('*/*/*.cpp'),
            fs.scandir('*/*/*/*.cpp')
        )
```

`os.pexecute` is exactly like `os.execute` but it also prints out the command, like with Makefiles.

`os.capture` is like `os.execute`, except that it returns whatever the command prints out as a string.

Add `TIME_IT = true` to the very top of your file in order to print out how long your build took.

## Making jailbreak tweaks

### Builder

```lua
local b = builder('apple')
```

* `b.frameworks` (table): Public/Private Apple frameworks you want to link with. e.g. `{'Foundation', 'UIKit', 'AppSupport'}`
* `b.archs` (table): table listing of the archs you want to use. e.g. `{'armv7', 'arm64'}` or `{'x86_64'}`
* `b.sdk` (string): name of the SDK you wanna link against. e.g. `'iphoneos'` or `'macosx'`
* `b.sdk_path` (string): Optional. The full path to the iPhoneOS8.1.sdk (or whatever), in case if you don't have Xcode.

Remember to have `b.output` be something that ends with `.dylib`. And you probably want to link with libsubstrate.dylib too.

### Debber

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
d:make_deb()
```

Calculate the md5sum, size, etc so you can put it in your repo and print it out like this:

```lua
d:print_packageinfo()
```


### Things to keep in mind

* Logos isn't supported yet.

This is basically my own personal build system.
It's entirely in LuaJIT because I like LuaJIT.
And it targets the platforms I like. And also Windows.

# Installing

You actually don't need to install it. Just clone it somewhere and run `luajit /path/to/aite/main.lua`.

But, if typing that huge command gets old, just do this:

```bash
git clone https://github.com/rweichler/aite /some/directory/aite
ln -s /some/directory/aite/main.lua /usr/local/bin/aite
```

boom. now you can say `aite` to your computer.


# Dependencies

* LuaJIT

# Compatibility (host)

* Mac
* iOS (jailbreak required)
* Linux
* Windows 7 (MinGW needs to be installed, and you need to do `luajit.exe C:\some\directory\aite\main.lua` instead of `aite`)
* FreeBSD

# Available targets

* Whatever the host is
* iOS (if on Mac)
* 3DS homebrew (if on Mac/Linux)
* Wii homebrew (if on Mac/Linux)

# WTF is `how2build.lua`?

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

Let's say you're trying to build some monolithic codebase with a bunch of nested C++ files in one folder,
and then a random other file, and then just the top-level contents of some random directory.

```lua
b.src = table.merge(
            fs.find('nested_folder', '*.cpp'),
            'random_file.cpp',
            fs.scandir('some_other_folder/*.cpp')
        )
```

`os.pexecute` is exactly like `os.execute` but it also prints out the command, like with Makefiles.

`os.capture` is like `os.execute`, except that it returns whatever the command prints out as a string.

Add `TIME_IT = true` to the very top of your file in order to print out how long your build took.

## Caveats

In order to make how2build.lua nicer to read, I have opted to not have file dependencies (other than mapping source files to object files, and object files to binaries)

What I mean by this is, let's say you have a file `lol.c` and `lol.h`. The c file #include's the h file. If you change the h file, then the c file will not be recompiled. The only way the c file will be recompiled is if you edit the c file.

#### Mitigating this

* run `touch lol.c` after editing lol.h.
* if more than one file depends on the .h file (and `touch`ing them all would be a pain), then run `touch how2build.lua`. That will cause a complete rebuild.

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

Note this must be done after making the .deb, because the md5sum and size are dependent on it.


### Things to keep in mind

* Logos isn't supported yet.

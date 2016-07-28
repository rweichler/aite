# Sexy Lua build system for iOS jb dev

This will be used to build Lucy and HamannBoard. And eventually MoonBoard.

# Dependencies

* LuaJIT (`package-manager install luajit`)

# Usage

Just clone this directory into your project, then do:

```
ln -s LEOS/main.lua make
cp LEOS/targets.lua .
```


And then edit `targets.lua` to your needs. Then run:

```
./make NAME_OF_FUNCTION_HERE
```

To run the corresponding function in `targets.lua`.

(You can instead `ln -s Makefile .` if you dont want to type the `./`)

## `targets.lua` example

```lua
-- this is called when `make` is
-- called with no arguments
function default()
    local b = builder('apple')
    b.compiler = 'clang'
    b.src = fs.wildcard('m') --compile all m files in current directory
    b.frameworks = {
        'UIKit',
        'Foundation'
    }
    b.output = 'my_sick_tweak.dylib'

    local objs = b:compile()
    b:link(objs)
end
```

If your project was just a bunch of `.m` files, it would compile all of them and then link them with UIKit, and then give you a dylib.

A more practical example can be found in the `targets.lua` file in this repo.

## Available options

So there are two ways to do this. Either with the 'apple' helper or not. I'd recommend always having 'apple' in there. That way you get these:

* `b.frameworks`: public Apple frameworks you want to link with. Private framework support coming soon.
* `b.archs`: table listing of the archs you want to use (e.g. `armv7`, `arm64`, `x86_64`)
* `b.sdk`: name of the SDK you wanna link against (e.g. `iphoneos` or `macosx`)
* `b.sdk_path`: the full path to the iPhoneOS8.1.sdk (or whatever), in case if you don't have Xcode.


These are the ones included by default, no matter what:

* `b.compiler`: e.g. `gcc` or `clang`
* `b.src_folder`: The folder where all your code is.
* `b.src`: Table of all the source files you'll be compiling, relative to `src_folder`.
* `b.build_folder`: The folder where you want all the ugly `.o` files to go.
* `b.output`: Where the executable should go. Default is `a.out`. Add `.dylib` to the end to make a dylib that can be dynamically loaded.

Advanced ones: 

* `b.linker`: The linker. If this isn't set, it will use `b.compiler`.
* `b.include_dirs`: table listing all of the folders you wanna include from (like rpetrich's iphoneheaders or something)
* `b.library_dirs`: table listing of all the folders you wanna look in for libraries.
* `b.libraries`: table listing of the libraries you want to link to.

## Things to keep in mind

* This only works with C/C++/Objective-C code. Logos isn't supported yet.
* In my example I only had one builder. But you can have as many as you want! If you have `c` and `cpp` files that require different compilers, then you can just use two builders to compile them, and then `table.merge` them and pass them to a linker.

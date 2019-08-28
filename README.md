# Gtk-D testing

This is probably not useful at all. It's purpose is to evaluate [Gtk-D](https://gtkd.org)
(Gtk+ bindings for the D language) for a particular project, I'm currently planning. Since
Gtk-D is somewhat sparsely documented and not overly popular, experimenting with it seems
like a good strategy. My experience with Gtk+ is also somewhat limited but I've been using
it in the past on some occasions.

So far, Gtk-D looks like the most feature complete and usable GUI toolkit for D and the
availability of Glade is also a strong point.

## Getting rid of the console on Windows

One problem I faced was that compiled apps were opening a console window on Windows, even
though GUI applications normally should not. This might be useful for debugging purposes,
because Gtk+, by default, prints debugging info to the console, but for release builds it
is not desireable at all.

Avoiding the console is possible though, just a bit tricky:

1. the app must be linked with **Subsystem:Windows**. Just put `lflags
   "-Subsystem:Windows"` in your **dub.sdl** (or the equivalent in your **dub.json**).

2. The application must provide a *WinMain()* function. See **main.d** for more. The
   function must be declared **extern(Windows)** and must have the proper signature. Call
   your real main from this function, but don't use the name *main()* for it. To make this
   portable, you can use **version()** for conditional compilation. Because there is no
   *main()*, you must manually initialize the D runtime, using *Runtime.initialize()*.
   Simply return from this function when the event loop terminates and
   *GApplication.run()* returns.

## Requirements

* a D compiler (DMD, LDC2, both work)
* dub
* A GTK+ runtime for Windows. I suggest the [MSYS2](https://www.msys2.org/) version, but others may work.

## Build

    dub build --build=debug|release --config=winmain --compiler=dmd --arch=x86_64 
    
To build the version using WinMain. Omit the **--config=winmain** to build an executable
using a standard *main()* function. This will open a text console. It's particularly
useful for debugging purposes, because some Gtk+ related debug output will go to the
console.


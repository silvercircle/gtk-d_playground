# Gtk-D testing

Probably not useful at all, but it shows one important thing: How to prevent a Gtk-D application from opening a console window under Windows. Two things are necessary:

1. the app must be linked with **Subsystem:Windows**. Just put `lflags "-Subsystem:Windows"` in your **dub.sdl** (or the equivalent in your **dub.json**).

2. The application must provide a *WinMain()* function. See **main.d** for more. The function must be declared **extern(Windows)** and must have the proper signature. Call your real main from this function, but don't use the name *main()* for it. To make this portable, you can use **version(Windows)** conditional compilation. Because there is no *main()*, you must manually initialize the D runtime, using *Runtime.initialize()*. Simply call exit() to terminate the program when the event loop terminates and *GApplication.run()* returns.

## Requirements

* a D compiler (DMD, LDC2, both work)
* dub
* A GTK+ runtime for Windows. I suggest the [MSYS2](https://www.msys2.org/) version, but others may work.

## Build

Use

    dub build --build=debug|release --config=winmain --compiler=dmd --arch=x86_64
To build the version using WinMain. Omit the **--config=winmain** to build an executable using a standard *main()* function. This will open a text console. It's particularly useful for debugging purposes, because some Gtk+ related debug output will go to the console. 

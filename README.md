# Gtk-D testing

Probably not useful at all, but it shows one important thing: How to prevent a Gtk-D application from opening a console window under Windows. Two things are necessary:

1. the app must be linked with **Subsystem:Windows**. Just put `lflags "-Subsystem:Windows"` in your **dub.sdl** (or the equivalent in your **dub.json**).

2. The application must provide a *WinMain()* function. See **main.d** for more. The function must be declared extern(Windows) and must have the proper signature. Call your real *main()* from this function. To make this portable, you can use **version(Windows)** conditional compilation.
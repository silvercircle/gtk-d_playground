module main;

/++
 + Gtk-D sample. Provide a WinMain() and link with Subsystem:Windows to eliminate the
 + windows console from a Gtk-D GUI application.
 + 
 + © 2019, Alex Vie <silvercircle@gmail.com>
 + License: MIT
 +
 + Build the WinMain() version:
 + dub build --build=release --config=winmain --compiler=ldc2|dmd --arch=x86_64
 +
 + Build the standard version (non-windows systems or if you need the console on Win)
 + dub build --build=release --compiler=ldc2|dmd --arch=x86_64
 +/

import std.file;
import std.conv;
import std.string;

import gtk.MainWindow;
import appwindow, context;
import gtk.Main;

version(WINMAIN) {
	import core.sys.windows.windows, std.array: split;
	import core.runtime, core.stdc.stdlib: exit;
	import glib.OptionContext;
	// a WinMain() function as an entry point for a GUI application
	// it is called before the D runtime is initialized, so you must manually do this
	extern (Windows) int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
	{
		int result = 0;
		try {
			// since the lpCmdLine is a standard char* string, we need to construct a D-style
			// args[] array and pass it to GtkD
			// there might be a better way?
			string cmdLine = to!string(lpCmdLine);
			string[] args;
			string[] cmdargs = cmdLine.split(" --");

			Runtime.initialize();
			args ~= std.file.thisExePath();
			args ~= cmdargs;
			const GlobalContext ctx = GlobalContext.getInstance(args);
			result = myMain(args);
			//Runtime.terminate();
		} catch (Throwable e) {
			// this normally should not happen, because myMain() should not throw, but Runtime.* may in case
			// of a bug..
			MessageBoxA(null, e.toString().toStringz(), null, MB_ICONEXCLAMATION);
			result = 0;     // failed
		}
		return result;
	}

	int myMain(string[] args)
	{
		GlobalContext ctx = GlobalContext.getInstance(args);
		Main.init(args);
		MainWindow win = new MyMainWindow(args);
		Main.run();
		ctx.saveConfig();
		return 0;
	}
} else {
	// this is for non-windows systems, or when in need for a text console under Windows.
	// can be useful for debug builds, because Gtk warnings will then be visible on the console
	// no need for the WinMain() hack here.
	int main(string[] args)
	{
		GlobalContext ctx = GlobalContext.getInstance(args);
		Main.init(args);
		MainWindow win = new MyMainWindow(args);
		Main.run();
		ctx.saveConfig();
		return 0;
	}
}

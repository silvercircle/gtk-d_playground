module main;

/++
 + Gtk-D sample. Provide a WinMain() and link with Subsystem:Windows to eliminate the
 + windows console from a Gtk-D GUI application.
 + 
 + © 2019, Alex Vie <silvercircle@gmail.com>
 + License: MIT
 +/

import std.file;
import std.conv;
import std.stdio;
import std.string;

import gio.Application : GioApplication = Application;
import gtk.Application;
import gtk.ApplicationWindow;
import gtk.Label;

import gtk.MainWindow;
import gtk.Box;
import gtk.MenuBar;
import gtk.MenuItem, gdk.Event, gtk.Widget;

class HelloWorld : ApplicationWindow
{
	this(Application application, ref string[] args)
	{
		super(application);
		this.m_args = args;
		setTitle("GtkD");
		setBorderWidth(10);
		add(new Label("Hello World"));
		this.setDefaultSize(600, 400);

		MenuBar menuBar = new MenuBar();
		MenuItem fileMenuItem = new MenuItem("File");
	
		MenuItem exitMenuItem = new MenuItem("Exit");
		//exitMenuItem.addOnActivate(&exit);
		//fileMenuItem.append(exitMenuItem);
			
		menuBar.append(fileMenuItem);
	
		Box box = new Box(Orientation.VERTICAL, 10);
		box.packStart(menuBar, false, false, 0);

		showAll();
	}

private:
	string[] m_args;
}

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
			args ~= std.file.thisExePath().dup;
			args ~= cmdargs;
			MessageBoxA(null, "In WinMain(), now starting the real app", lpCmdLine, MB_ICONEXCLAMATION);
			result = myMain(args);
			Runtime.terminate();
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
		auto application = new Application("org.gtkd.demo.helloworld", GApplicationFlags.FLAGS_NONE);
		application.addOnActivate(delegate void(GioApplication app) { new HelloWorld(application, args); });
		return application.run(args);
	}
} else {
	// this is for non-windows systems, or when in need for a text console under Windows.
	// can be useful for debug builds, because Gtk warnings will then be visible on the console
	// no need for the WinMain() hack here.
	int main(string[] args)
	{
		writeln(args);
		auto application = new Application("org.gtkd.demo.helloworld", GApplicationFlags.FLAGS_NONE);
		application.addOnActivate(delegate void(GioApplication app) { new HelloWorld(application, args); });
		return application.run(args);
	}
}

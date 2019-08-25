module main;

/++
 + Gtk-D sample. Provide a WinMain() and link with Subsystem:Windows to whack the
 + windows console from a Gtk-D GUI application
 + 
 + © 2019, Alex Vie <silvercircle@gmail.com>
 + License: MIT
 +/

import std.file;
import std.conv;
import std.stdio;

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
	this(Application application)
	{
		super(application);
		setTitle("GtkD");
		setBorderWidth(10);
		add(new Label("Hello World"));
		this.setDefaultSize(500, 400);

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
}

version(Windows) {
	import core.sys.windows.windows, core.runtime;
	extern (Windows) int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
	{
		int result;
		try
		{
			string[] args = [];
			Runtime.initialize();
			result = myMain(args);
			Runtime.terminate();
		}
		catch (Throwable e) 
		{
			//MessageBoxA(null, e.toString().toStringz(), null, MB_ICONEXCLAMATION);
			result = 0;     // failed
		}
		return result;
	}

	int myMain(string[] args)
	{
		auto application = new Application("org.gtkd.demo.helloworld", GApplicationFlags.FLAGS_NONE);
		application.addOnActivate(delegate void(GioApplication app) { new HelloWorld(application); });
		return application.run(args);
	}

} else {
	int main(string[] args)
	{
		auto application = new Application("org.gtkd.demo.helloworld", GApplicationFlags.FLAGS_NONE);
		application.addOnActivate(delegate void(GioApplication app) { new HelloWorld(application); });
		return application.run(args);
	}
}

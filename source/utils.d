/++
 + Gtk-D sample. Provide a WinMain() and link with Subsystem:Windows to eliminate the
 + windows console from a Gtk-D GUI application.
 + 
 + © 2019, Alex Vie <silvercircle@gmail.com>
 + License: MIT
 +
 + attempts to use localization via gettext
 +/

module utils;

import glib.Internationalization, std.stdio;
import context;

static this()
{
	auto foo = Internationalization.getLanguageNames();
	writeln(foo);
}

string _(string text)
{
	return Internationalization.dgettext(_textdomain, text);
}

private {
	string _textdomain = "gtkdtest";
}

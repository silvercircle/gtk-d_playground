/++
 + Gtk-D sample. Provide a WinMain() and link with Subsystem:Windows to eliminate the
 + windows console from a Gtk-D GUI application.
 + 
 + © 2019, Alex Vie <silvercircle@gmail.com>
 + License: MIT
 +/
 
module menu;

import gtk.Widget, gtk.MenuBar, gtk.Menu, gtk.MenuItem;
import context, appwindow, aboutdialog, utils;

class MainMenuBar :  MenuBar 
{
	enum { ID_EXIT = 1, ID_HELPABOUT = 2 }
	this(MyMainWindow w)
	{
		super();

		m_fileMenuItem = new MenuItem(utils._("File"));
		m_editMenuItem = new MenuItem("Edit");
		m_helpMenuItem = new MenuItem("Help");
		m_helpMenu = new Menu();
		m_fileMenu = new Menu();

		MenuItem aboutMenuItem = new MenuItem(&menuHandler, "About");
		aboutMenuItem.setData("id", cast(void*) ID_HELPABOUT);
		MenuItem exitMenuItem = new MenuItem(&menuHandler, "Exit");
		exitMenuItem.setData("id", cast(void *) ID_EXIT);
		m_helpMenu.append(aboutMenuItem);
		m_fileMenu.append(exitMenuItem);

		m_helpMenuItem.setSubmenu(m_helpMenu);
		m_fileMenuItem.setSubmenu(m_fileMenu);

		append(m_fileMenuItem);
		append(m_editMenuItem);
		append(m_helpMenuItem);

		m_Window = w;
		m_ctx = GlobalContext.getInstance();
	}

	void menuHandler(MenuItem m)
	{
		uint the_id = cast(uint)(m.getData("id"));

		final switch(the_id) {
			case ID_EXIT:
				m_Window.close();
				break;
			case ID_HELPABOUT:
				AboutDialog dlg = AboutDialog.getInstance(m_Window);
				dlg.showDialog();
				break;
		}
	}

public:
	MenuItem 		m_fileMenuItem, m_editMenuItem, m_helpMenuItem;
	Menu			m_helpMenu, m_fileMenu;
	GlobalContext 	m_ctx;
	MyMainWindow	m_Window;
}

module menu;

import gtk.Widget, gtk.MenuBar, gtk.Menu, gtk.MenuItem;
import context, appwindow;

class MainMenuBar :  MenuBar 
{
	this(MainWindow w)
	{
		super();

		m_fileMenuItem = new MenuItem("File");
		m_editMenuItem = new MenuItem("Edit");
		m_helpMenuItem = new MenuItem("Help");
		m_helpMenu = new Menu();
		m_fileMenu = new Menu();

		MenuItem aboutMenuItem = new MenuItem(&menuHandler, "About");
		aboutMenuItem.setData("id", cast(void*) 1);
		MenuItem exitMenuItem = new MenuItem(&menuHandler, "Exit");
		exitMenuItem.setData("id", cast(void *) 2);
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
		if(m.getData("id") == cast(void*) 1)
			m_ctx.log(LOG.WARN, "filemenuhandler");
	}

public:
	MenuItem 		m_fileMenuItem, m_editMenuItem, m_helpMenuItem;
	Menu			m_helpMenu, m_fileMenu;
	GlobalContext 	m_ctx;
	MainWindow		m_Window;
}

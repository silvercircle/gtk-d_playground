module appwindow;

import gtk.ApplicationWindow;
import gtk.Label;

import gtk.MainWindow, gtk.Application;
import gtk.Box, gtk.Button, gtk.MessageDialog;
import gtk.Widget, gdk.Event, gtk.Widget, gtk.MenuBar;

import context, menu;

class MainWindow : ApplicationWindow
{
	this(Application application, ref string[] args)
	{
		super(application);
		this.m_ctx = GlobalContext.getInstance();

		this.m_args = args;
		setTitle("GtkD Test application");
		this.setDefaultSize(m_ctx.cfg.pos_mainwindow.width, m_ctx.cfg.pos_mainwindow.height);
		this.move(m_ctx.cfg.pos_mainwindow.left, m_ctx.cfg.pos_mainwindow.top);

		MenuBar menuBar = new MainMenuBar(this);
		
		m_box = new Box(Orientation.VERTICAL, 10);
		m_box.packStart(menuBar, false, false, 0);
		m_box.packStart(new Label("Hello World"), false, false, 0);
		m_quitbutton = new Button("Quit");
		m_quitbutton.setMarginRight(10);
		m_quitbutton.setMarginLeft(10);
		m_quitbutton.addOnClicked(&buttonclicked1);
		m_quitbutton.addOnClicked(&buttonclicked2);
		m_box.packStart(m_quitbutton, false, false, 0);
		this.add(m_box);
		this.addOnDelete(&preclose);
		showAll();
		m_ctx.mainwindow = this;
	}

	~this()
	{
	}

	// fired onDelete, record window geometry in our config object
	private bool preclose(Event e, Widget w) {
		m_ctx.log(LOG.WARN, "Closing main window, recording geometry");
		this.getSize(m_ctx.cfg.pos_mainwindow.width, m_ctx.cfg.pos_mainwindow.height);
		this.getPosition(m_ctx.cfg.pos_mainwindow.left, m_ctx.cfg.pos_mainwindow.top);

		return false;
	}

	private void buttonclicked1(Button b)
	{
		m_ctx.log(LOG.WARN, "First handler activated");
	}
	
	private void buttonclicked2(Button b)
	{
		auto foo = new MessageDialog(this, GtkDialogFlags.MODAL | GtkDialogFlags.DESTROY_WITH_PARENT, GtkMessageType.INFO,
			GtkButtonsType.YES_NO, true, "%s", "foo");
		foo.setTitle("Application quit requested");
		foo.setMarkup("Do you really want to <b>quit</b>?");
		foo.setBorderWidth(10);
		foo.setDefaultSize(300, 100);
		if(foo.run() == GtkResponseType.YES) {
			m_ctx.log(LOG.WARN, "Requested app exit");
			this.close();
		}
		foo.destroy();
	}

private:
	string[] 		m_args;
	Box		 		m_box;
	Button			m_quitbutton;
	GlobalContext 	m_ctx;
}

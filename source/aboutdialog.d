/++
 + Gtk-D sample. Provide a WinMain() and link with Subsystem:Windows to eliminate the
 + windows console from a Gtk-D GUI application.
 + 
 + © 2019, Alex Vie <silvercircle@gmail.com>
 + License: MIT
 +/

module aboutdialog;

import gtk.MessageDialog;
import appwindow, context, utils;

class AboutDialog : MessageDialog
{
	this(MyMainWindow w = null)
	{
		if(w !is null)
			m_Window = w;

		m_ctx = GlobalContext.getInstance();

		super(w, GtkDialogFlags.MODAL | GtkDialogFlags.DESTROY_WITH_PARENT | GtkDialogFlags.USE_HEADER_BAR, GtkMessageType.INFO,
			GtkButtonsType.OK, true, "%s", "<b>FOOBAR</b>");

		setTitle(utils._("About this Application"));
//		setMarkup(q"[<span size="100"><b>GtkD</b> Test application
//©2019 Alex Vie &lt;silvercircle@gmail.com&gt;
//License: MIT</span>]");
		setBorderWidth(10);
		setDefaultSize(400, 100);
		m_ctx.log(LOG.WARN, "Constructed the About Dialog");
	}

	void showDialog()
	{
		showAll();
		run();
		hide();
	}

	static AboutDialog getInstance(MyMainWindow w = null)
	{
		if (!isInstantiated) {
			synchronized (AboutDialog.classinfo) {
				if (!instance_) {
					instance_ = new AboutDialog(w);
				}
				isInstantiated = true;
			}
		}
		return instance_;
	}

private:
	static bool 	isInstantiated = false;
	__gshared 		AboutDialog instance_;

	MyMainWindow	m_Window;
	GlobalContext	m_ctx;
}

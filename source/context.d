module context;

import std.process, std.path, std.stdio, std.file, std.string, std.conv;
import vibe.data.json, vibe.data.serialization, std.datetime :Clock, SysTime;
import vibe.core.log;

import appwindow;

enum LOG { TRACE, DEBUG, FATAL, WARN }

/**
 * app configuration class
 * implemented as thread safe singleton
 * used for config storage via JSON, logging. 
 */
final class GlobalContext
{
private:

	/* 
	 * example of a config data object with sub-structures representable
	 * in Json
	 */
	struct WindowPos {
		@optional @name("left")			int			left;
		@optional @name("top")			int			top;
		@optional @name("width")		int			width;
		@optional @name("height")		int			height;
	}
	struct Config {
		@optional @name("appname") 		string      myName = "gtk-d playground";
		@optional @name("firstrun") 	SysTime		firstRun;
		@optional @name("lastrun")		SysTime		lastRun;
		@optional @name("datadir") 		string		dataDir;
		@optional @name("is_portable")	bool		isPortable = true;
		@optional @name("testvalue")	int			testvalue = 1;

		@optional @name("pos_mainwindow") WindowPos	pos_mainwindow = {100, 100, 600, 400};
	}

	this(ref string[] args)
	{
		this.exePath = std.path.dirName(std.file.thisExePath());
		version(Windows) {
			this.homeDir = std.process.environment["APPDATA"];
			homeDir = buildPath(this.homeDir, "gtk-d_playground");
		}
		else {
			this.homeDir = std.process.environment["HOME"];
			this.homeDir = buildPath(this.homeDir, ".local/share/gtk-d_playground");
		}       
		try {
			std.file.isDir(this.homeDir);
		}
		catch (FileException e) {
			std.file.mkdirRecurse(this.homeDir);
		}

		if(args != null && !this.isInitialized) 
			this.initContext(args);	
	}

	~this()
	{
		this.saveConfig();
	}

	// TLS flag, each thread has its own
	static bool 	isInstantiated = false;
	// "True" global
	__gshared 		GlobalContext instance_;
	string      	homeDir;
	bool        	isInitialized = false;
	bool        	isPortable = true;
	string      	portableDir;
	string      	exePath;
	string      	configFilePath, logfilePath;
	shared      	FileLogger logger;
	MainWindow		m_MainWindow;
public:
	/**
	 * the configuration object
	 */
	Config      		cfg;

	static GlobalContext getInstance(string[] args = null)
	{
		if (!isInstantiated) {
			synchronized (GlobalContext.classinfo) {
				if (!instance_) {
					instance_ = new GlobalContext(args);
				}
				isInstantiated = true;
			}
		}
		return instance_;
	}

	/**
	 * initialize the context, parse command line arguments, determine data
	 * directory
	 */
	void initContext(ref string[] args) {
		if(this.isInitialized)
			return;

		this.isInitialized = true;

		if(this.isPortable && this.portableDir.length == 0)
			this.portableDir = "_data";

		if(this.portableDir.length > 0) {
			this.isPortable = true;
			if(!std.path.isAbsolute(this.portableDir))
				this.homeDir = buildPath(this.exePath, this.portableDir);
			else
				this.homeDir = this.portableDir;

			try {
				std.file.isDir(this.homeDir);
			} catch (FileException e) {
				std.file.mkdirRecurse(this.homeDir);
			}
			
		}
		this.logfilePath = buildPath(this.homeDir, "gtkd_playground.log");
		this.logger = cast(shared) new vibe.core.log.FileLogger(this.logfilePath);
		this.logger.useColors = true;
		this.logger.format = FileLogger.Format.threadTime;
		this.logger.minLevel = LogLevel.debug_;
	   
		vibe.core.log.registerLogger(this.logger);

		this.configFilePath = buildPath(this.homeDir, "config.json");
		try {
			std.file.isFile(this.configFilePath);
			string rawJson = std.file.readText(this.configFilePath);
			try
				this.cfg = deserializeJson!Config(rawJson);
			catch (Throwable e) {
				writef("exception while deserialize\n%s\n", e);
			}
		} catch(FileException e) {
			File f = File(this.configFilePath, "w");
			this.cfg = Config();
			this.cfg.firstRun = Clock.currTime();
			Json s = cfg.serializeToJson();
			f.write(s.toPrettyString());
			f.close();
			destroy(s);
		}   
		cfg.dataDir = this.homeDir;
		log(LOG.TRACE, "Successfully initizalised the global context");
		log(LOG.TRACE, "The data directory is: %s", this.homeDir);
	}

	/**
	 * preshutdown
	 */
	void preShutdown() const {
		//logf("GlobalContext: preShutdown()");
	}

	/**
	 * logging helper
	 */
	
	void log(Args...)(LOG level, string format, Args args) const nothrow
	{
		final switch(level) {
			case LOG.TRACE:
				vibe.core.log.logInfo(format, args);
				break;
			case LOG.DEBUG:
				vibe.core.log.logDebug(format, args);
				break;
			case LOG.FATAL:
				vibe.core.log.logFatal(format, args);
				break;
			case LOG.WARN:
				vibe.core.log.logWarn(format, args);
				break;
		}
	}

	/**
	 * save configuration
	 */
	void saveConfig() {
		this.cfg.lastRun = Clock.currTime();
		this.cfg.isPortable = this.isPortable;
		Json s = this.cfg.serializeToJson();
		try {
			log(LOG.TRACE, "Saving configuration to: %s", this.configFilePath);
			File f = File(this.configFilePath, "w");
			f.write(s.toPrettyString());
			f.close();
		} catch (FileException e) {
			log(LOG.FATAL, "Exception while saving configuration: %s\n", e);
		}
	}

	/**
	 * the data directory
	 */
	@property homedir() const { return this.homeDir; }
	@property mainwindow() const { return this.m_MainWindow; }
	@property void mainwindow(MainWindow w) { this.m_MainWindow = w; }
}

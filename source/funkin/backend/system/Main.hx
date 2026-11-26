package funkin.backend.system;

	#if sys
import sys.io.File;
	#end
	#if sys
import sys.FileSystem;
	#end
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.ui.FlxSoundTray;
import funkin.backend.assets.AssetsLibraryList;
import funkin.backend.assets.ModsFolder;
import funkin.backend.system.framerate.Framerate;
import funkin.backend.assets.AssetSource;
import funkin.backend.system.framerate.SystemInfo;
import funkin.backend.system.modules.*;
import funkin.editors.SaveWarning;
import openfl.Assets;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.text.TextFormat;
import openfl.utils.AssetLibrary;
import lime.system.System as LimeSystem;

#if ALLOW_MULTITHREADING
import sys.thread.Thread;
#end

class Main extends Sprite
{
	public static var instance:Main;

	public static var modToLoad:String = #if web "" #else "dustin" #end;
	public static var forceGPUOnlyBitmapsOff:Bool = #if (desktop || mobile) false #else true #end;
	public static var noTerminalColor:Bool = false;
	public static var verbose:Bool = false;

	public static var scaleMode:FunkinRatioScaleMode;
	
	public static var framerateSprite:Framerate;

	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels).
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var game:FunkinGame;

	/**
	 * The time since the game was focused last time in seconds.
	 */
	public static var timeSinceFocus(get, never):Float;
	public static var time:Int = 0;

	// You can pretty much ignore everything from here on - your code should go in your states.

	#if ALLOW_MULTITHREADING
	public static var gameThreads:Array<Thread> = [];
	#end

	public static function preInit() {
		funkin.backend.utils.NativeAPI.registerAsDPICompatible();
		#if !html5
		funkin.backend.system.CommandLineHandler.parseCommandLine(Sys.args());
		#end
		funkin.backend.system.Main.fixWorkingDirectory();
	}

	public function new()
	{
		super();

		instance = this;

		#if mobile
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end

		CrashHandler.init();

		framerateSprite = new Framerate();

		addChild(game = new FunkinGame(gameWidth, gameHeight, MainState, Options.framerate, Options.framerate, skipSplash, startFullscreen));

		#if web
		try {
			var __sample:Int->Void = null;
			__sample = function(__n:Int) {
				try {
					var __c = FlxG.stage.window.context;
					var __bd = openfl.utils.Assets.getBitmapData('assets/images/menus/titlescreen/logo.png');
					var __msg = 'ctx=' + (__c == null ? 'NULL' : Std.string(__c.type))
						+ ' bd=' + (__bd == null ? 'null' : (__bd.width + 'x' + __bd.height))
						+ ' tile=' + FlxG.renderTile + ' blit=' + FlxG.renderBlit;
					var __doc = js.Browser.document;
					var __div = __doc.getElementById('cne-diag');
					if (__div == null) {
						__div = __doc.createElement('div');
						__div.id = 'cne-diag';
						__div.style.cssText = 'position:fixed;top:0;left:0;z-index:999999;background:#000;color:#0f0;font:12px monospace;padding:2px 4px;pointer-events:none';
						__doc.body.appendChild(__div);
					}
					__div.innerText = __msg;
					try {
						var __txt = openfl.utils.Assets.getText('assets/data/languages/en.xml');
						var __rep = __msg
							+ ';img=' + (__bd == null ? 'null' : Std.string(__bd.image != null))
							+ ';txt=' + (__txt == null ? 'null' : Std.string(__txt.length))
							+ ';rm=' + Std.string(FlxG.renderMethod);
						js.Browser.window.fetch('/__diag?n=' + __n + '&m=' + StringTools.urlEncode(__rep));
					} catch (e:Dynamic) {}
				} catch (e:Dynamic) {}
				if (__n < 3) haxe.Timer.delay(function() __sample(__n + 1), 7000);
			};
			haxe.Timer.delay(function() __sample(0), 5000);
		} catch (e:Dynamic) {}
		#end


		#if android FlxG.android.preventDefaultKeys = [BACK]; #end

		#if !web
		#if mobile
		FlxG.stage.window.onResize.add((w:Int, h:Int) -> framerateSprite.setScale());
		#end
		SystemInfo.init();
		#end
		addChild(framerateSprite);
	}

	@:dox(hide)
	public static var audioDisconnected:Bool = false;

	public static var changeID:Int = 0;
	public static var pathBack = #if (windows || linux)
			"../../../../"
		#elseif mac
			"../../../../../../../"
		#else
			"../../../../"
		#end;
	public static var startedFromSource:Bool = #if TEST_BUILD true #else false #end;


	private static var __threadCycle:Int = 0;
	public static function execAsync(func:Void->Void) {
		#if ALLOW_MULTITHREADING
		var thread = gameThreads[(__threadCycle++) % gameThreads.length];
		thread.events.run(func);
		#else
		func();
		#end
	}

	private static function getTimer():Int {
		return time = Lib.getTimer();
	}

	public static function loadGameSettings() {
		WindowUtils.init();
		SaveWarning.init();
		MemoryUtil.init();
		@:privateAccess
		FlxG.game.getTimer = getTimer;
		#if ALLOW_MULTITHREADING
		for(i in 0...4)
			gameThreads.push(Thread.createWithEventLoop(function() {Thread.current().events.promise();}));
		#end
		FunkinCache.init();
		Paths.assetsTree = new AssetsLibraryList();

		#if UPDATE_CHECKING
		funkin.backend.system.updating.UpdateUtil.init();
		#end
		ShaderResizeFix.init();
		Logs.init();
		Paths.init();

		hscript.Interp.importRedirects = funkin.backend.scripting.Script.getDefaultImportRedirects();

		#if GLOBAL_SCRIPT
		funkin.backend.scripting.GlobalScript.init();
		#end

		var lib = new AssetLibrary();
		@:privateAccess
		lib.__proxy = Paths.assetsTree;

		#if web
		// Web: openfl already parsed the manifest and registered the real library as
		// "default". Assets.registerLibrary would unload it (wiping the manifest data),
		// so swap the pointer by hand and hand the real library to the asset tree.
		var __map = @:privateAccess lime.utils.Assets.libraries;
		var __realLib:Dynamic = __map.get('default');
		if (__realLib != null && __realLib != lib) {
			var __arr:Dynamic = Reflect.field(Paths.assetsTree, "libraries");
			if (__arr != null) __arr.unshift(__realLib);
			__map.set('default', lib);
			trace('CNE_REAL_LIB attached');
		} else {
			Assets.registerLibrary('default', lib);
		}
		#else
		Assets.registerLibrary('default', lib);
		#end

		funkin.options.PlayerSettings.init();
		Options.load();

		FlxG.fixedTimestep = false;

		FlxG.scaleMode = scaleMode = new FunkinRatioScaleMode();

		Conductor.init();
		AudioSwitchFix.init();
		EventManager.init();
		FlxG.signals.focusGained.add(onFocus);
		FlxG.signals.preStateSwitch.add(onStateSwitch);
		FlxG.signals.postStateSwitch.add(onStateSwitchPost);

		FlxG.mouse.useSystemCursor = !Controls.instance.touchC;
		#if DARK_MODE_WINDOW
		if(funkin.backend.utils.NativeAPI.hasVersion("Windows 10")) funkin.backend.utils.NativeAPI.redrawWindowHeader();
		#end

		ModsFolder.init();
		#if MOD_SUPPORT
		if (FileSystem.exists(#if mobile StorageUtil.getStorageDirectory(true) + #end "mods/autoload.txt"))
			modToLoad = File.getContent(#if mobile StorageUtil.getStorageDirectory(true) + #end "mods/autoload.txt").trim();

		ModsFolder.switchMod(modToLoad.getDefault(Options.lastLoadedMod));
		#end

		initTransition();
		
		#if mobile
		LimeSystem.allowScreenTimeout = Options.screenTimeOut;
		#end
	}

	public static function refreshAssets() @:privateAccess {
		FunkinCache.instance.clearSecondLayer();

		var game = FlxG.game;
		var daSndTray = Type.createInstance(game._customSoundTray = funkin.menus.ui.FunkinSoundTray, []);
		var index:Int = game.numChildren - 1;

		if(game.soundTray != null)
		{
			var newIndex:Int = game.getChildIndex(game.soundTray);
			if(newIndex != -1) index = newIndex;
			game.removeChild(game.soundTray);
			game.soundTray.__cleanup();
		}

		game.addChildAt(game.soundTray = daSndTray, index);
	}

	public static function initTransition() {
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
			new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, 0.7, new FlxPoint(0, 1),
			{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
	}

	public static function onFocus() {
		_tickFocused = FlxG.game.ticks;
	}

	private static function onStateSwitch() {
		scaleMode.resetSize();
	}

	private static function onStateSwitchPost() {
		// manual asset clearing since base openfl one does'nt clear lime one
		// does'nt clear bitmaps since flixel fork does it auto

		@:privateAccess {
			// clear uint8 pools
			for(length=>pool in openfl.display3D.utils.UInt8Buff._pools) {
				for(b in pool.clear())
					b.destroy();
			}

			openfl.display3D.utils.UInt8Buff._pools.clear();
		}

		MemoryUtil.clearMajor();
	}

	public static var noCwdFix:Bool = false;
	public static function fixWorkingDirectory() {
		#if windows
		if (!noCwdFix && !sys.FileSystem.exists('manifest/default.json')) {
			Sys.setCwd(haxe.io.Path.directory(Sys.programPath()));
		}
		#elseif switch
		Sys.setCwd(haxe.io.Path.addTrailingSlash(openfl.filesystem.File.applicationStorageDirectory.nativePath));
		#end
	}

	private static var _tickFocused:Float = 0;
	public static function get_timeSinceFocus():Float {
		return (FlxG.game.ticks - _tickFocused) / 1000;
	}
}

class Sys {
	public static var args:Void->Array<String> = function() return [];
	public static var command:(String, Array<String>)->Int = function(_c, _a) return -1;
	public static var exit:(Int)->Void = function(_code) {};
	public static var getEnv:String->String = function(_name) return null;
	public static var putEnv:(String, String)->Void = function(_name, _value) {};
	public static var environment:Void->Map<String, String> = function() return new Map();
	public static var programPath:Void->String = function() return "";
	public static var setCwd:String->Void = function(_dir) {};
	public static var cwd:Void->String = function() return "";
	public static var sleep:Float->Void = function(_sec) {};
	public static var stdin:Void->sys.io.FileInput = function() return null;
	public static var stdout:Void->sys.io.FileOutput = function() return null;
	public static var stderr:Void->sys.io.FileOutput = function() return null;
	public static var time:Void->Float = function() return Date.now().getTime() / 1000.0;
	public static var cpuTime:Void->Float = function() return 0.0;
	public static var systemName:Void->String = function() return "HTML5";
	public static var sysName:Void->String = function() return "html5";
}

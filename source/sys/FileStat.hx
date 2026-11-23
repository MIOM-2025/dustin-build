package sys;

class FileStat {
	public var gid(default, null):Int = 0;
	public var uid(default, null):Int = 0;
	public var atime(default, null):Date = Date.now();
	public var mtime(default, null):Date = Date.now();
	public var ctime(default, null):Date = Date.now();
	public var dev(default, null):Int = 0;
	public var ino(default, null):Int = 0;
	public var nlink(default, null):Int = 0;
	public var rdev(default, null):Int = 0;
	public var mode(default, null):Int = 0;
	public var size(default, null):Int = 0;

	public function new(path:String) {}
}

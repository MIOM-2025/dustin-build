package sys.io;

class Process {
	public var stdin(default, null):FileOutput = null;
	public var stdout(default, null):FileInput = null;
	public var stderr(default, null):FileInput = null;

	public function new(command:String, ?args:Array<String>) {}
	public function close():Void {}
	public function exitCode():Int return 0;
	public function kill():Void {}
}

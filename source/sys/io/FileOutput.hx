package sys.io;

class FileOutput {
	public function new(path:String) {}
	public function writeByte(c:Int):Void {}
	public function writeBytes(buf:haxe.io.Bytes, pos:Int, len:Int):Int return 0;
	public function writeString(s:String):Void {}
	public function seek(p:Int, pos:FileSeek):Void {}
	public function tell():Int return 0;
	public function close():Void {}
	public function flush():Void {}
}

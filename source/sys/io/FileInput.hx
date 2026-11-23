package sys.io;

class FileInput {
	public function new(path:String) {}
	public function readByte():Int return 0;
	public function readBytes(buf:haxe.io.Bytes, pos:Int, len:Int):Int return 0;
	public function readLine():String return "";
	public function readAll(?buf:haxe.io.Bytes):haxe.io.Bytes return haxe.io.Bytes.alloc(0);
	public function seek(p:Int, pos:FileSeek):Void {}
	public function tell():Int return 0;
	public function eof():Bool return true;
	public function close():Void {}
}

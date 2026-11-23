package sys.io;

import haxe.io.Bytes;

class File {
	public static function getContent(path:String):String return "";
	public static function getBytes(path:String):Bytes return Bytes.alloc(0);
	public static function saveContent(path:String, content:String):Void {}
	public static function saveBytes(path:String, bytes:Bytes):Void {}
	public static function read(path:String, binary:Bool = false):FileInput return null;
	public static function write(path:String, binary:Bool = false):FileOutput return null;
	public static function append(path:String, binary:Bool = false):FileOutput return null;
	public static function update(path:String, binary:Bool = false):FileOutput return null;
	public static function copy(src:String, dst:String):Void {}
}

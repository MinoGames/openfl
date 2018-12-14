package openfl._internal.symbols;


import lime.graphics.ImageChannel;
import lime.math.Vector2;
import lime.Assets in LimeAssets;
import openfl._internal.swf.SWFLite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.Assets;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

#if !macro
class BitmapSymbol extends SWFSymbol {
	
	
	public var alpha:String;
	public var path:String;
	public var smooth:Null<Bool>;
	
	
	public function new () {
		
		super ();
		
	}
	
	
	private override function __createObject (swf:SWFLite):Bitmap {

		var image = swf.library.getImage (path);
		var bmp = new Bitmap (BitmapData.fromImage (image), PixelSnapping.AUTO, smooth != false);

		if (openfl._internal.swf.SWFLiteLibrary.scaleFactor != 1.0) {
			var ratioX = image.originalWidth / (image.width * (1 / openfl._internal.swf.SWFLiteLibrary.scaleFactor));
			var ratioY = image.originalHeight / (image.height * (1 / openfl._internal.swf.SWFLiteLibrary.scaleFactor));
			
			bmp.scaleX = 1 / openfl._internal.swf.SWFLiteLibrary.scaleFactor * ratioX;
			bmp.scaleY = 1 / openfl._internal.swf.SWFLiteLibrary.scaleFactor * ratioY;
		}

		return bmp;
		
	}
	
	
}
#end
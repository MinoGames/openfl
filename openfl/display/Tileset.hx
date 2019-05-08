package openfl.display;


import openfl.geom.Point;
import openfl.geom.Rectangle;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


class Tileset {
	
	public var renderId = -1;

	public var bitmapData (default, set):BitmapData;
	
	private var __data:Array<TileData>;
	
	
	// TODO: Add support for adding uniform tile rectangles (margin, spacing, width, height)
	
	public function new (bitmapData:BitmapData, rects:Array<Rectangle> = null) {
		
		__data = new Array ();
		
		this.bitmapData = bitmapData;
		
		if (rects != null) {
			
			for (rect in rects) {
				
				addRect (rect);
				
			}
			
		}
		
	}
	
	
	public function addRect (rect:Rectangle):Int {
		
		if (rect == null) return -1;
		
		var tileData = new TileData (rect);
		tileData.__update (bitmapData);
		__data.push (tileData);
		
		return __data.length - 1;
		
	}
	
	
	public function clone ():Tileset {
		
		var tileset = new Tileset (bitmapData, null);
		var rect = new Rectangle ();
		
		for (tileData in __data) {
			
			rect.setTo (tileData.x, tileData.y, tileData.width, tileData.height);
			tileset.addRect (rect);
			
		}
		
		return tileset;
		
	}
	
	
	var tempRect:Rectangle;
	public inline function getRect (id:Int, ?temp:Rectangle):Rectangle {
		
		#if use_temp
		if (temp == null) {
			if (tempRect == null) tempRect = new Rectangle();
			temp = tempRect;
		}
		#end

		return if (id < __data.length && id >= 0) {
			
			#if use_temp
			temp.setTo(__data[id].x, __data[id].y, __data[id].width, __data[id].height);
			temp;
			#else
			new Rectangle (__data[id].x, __data[id].y, __data[id].width, __data[id].height);
			#end
			
		} else {
			null;
		}
		
	}

	public inline function getData (id:Int):TileData {
		
		return if (id < __data.length && id >= 0) {
			
			__data[id];
			
		} else {

			null;

		}
		
	}

	public function updateRect(id:Int, x:Int, y:Int, width:Int, height:Int) {
		if (id < __data.length && id >= 0) {
			
			var data = __data[id];
			data.x = x;
			data.y = y;
			data.width = width;
			data.height = height;

			data.__update(bitmapData);
		}
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function set_bitmapData (value:BitmapData):BitmapData {
		
		bitmapData = value;
		
		for (data in __data) {
			
			data.__update (bitmapData);
			
		}
		
		return value;
		
	}
	
	
}


#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


@:allow(openfl.display.Tileset) @:dox(hide) private class TileData {
	
	
	public var height:Int;
	public var width:Int;
	public var x:Int;
	public var y:Int;
	
	public var __bitmapData:BitmapData;
	public var __uvHeight:Float;
	public var __uvWidth:Float;
	public var __uvX:Float;
	public var __uvY:Float;
	
	
	public function new (rect:Rectangle = null) {
		
		if (rect != null) {
			
			x = Std.int (rect.x);
			y = Std.int (rect.y);
			width = Std.int (rect.width);
			height = Std.int (rect.height);
			
		}
		
	}
	
	
	private function __update (bitmapData:BitmapData, skip = false):Void {
		
		if (bitmapData != null) {
			
			__uvX = x / bitmapData.width;
			__uvY = y / bitmapData.height;
			__uvWidth = (x + width) / bitmapData.width;
			__uvHeight = (y + height) / bitmapData.height;
			
			#if flash
			if (!skip) {
				__bitmapData = new BitmapData (width > 0 ? width : 1, height > 0 ? height : 1);
				__bitmapData.copyPixels (bitmapData, new Rectangle (x, y, width, height), new Point ());
			}
			#end
			
		}
		
	}
	
	
}
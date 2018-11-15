package openfl.display;

import openfl.geom.Rectangle;
import openfl.geom.Matrix;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl.geom.Matrix)
@:access(openfl.geom.Rectangle)

class Tile {
	
	public var drawableTiles:Int = 0;
	public var parent:TileContainer = null;
	
	public var alpha (default, set):Float;
	public var data:Dynamic;
	public var id (default, set):Int;
	public var matrix (default, set):Matrix;
	public var originX (default, set):Float;
	public var originY (default, set):Float;
	public var rotation (get, set):Float;
	public var scaleX (get, set):Float;
	public var scaleY (get, set):Float;
	public var tileset (default, set):Tileset;
	public var visible:Bool;
	public var x (get, set):Float;
	public var y (get, set):Float;
	
	private var __length:Int;
	private var __alphaDirty:Bool;
	private var __rotation:Null<Float>;
	private var __rotationCosine:Float;
	private var __rotationSine:Float;
	private var __scaleX:Null<Float>;
	private var __scaleY:Null<Float>;
	private var __sourceDirty:Bool;
	private var __transform:Array<Float>;
	private var __transformDirty:Bool;






	/*var matA : Float;
	var matB : Float;
	var matC : Float;
	var matD : Float;
	var absX : Float;
	var absY : Float;

	var posChanged : Bool;
	var allocated : Bool;
	var lastFrame : Int;

	function sync() {
		var changed = posChanged;
		if( changed ) {
			calcAbsPos();
			posChanged = false;
		}

		lastFrame = ctx.frame;
		var p = 0, len = children.length;
		while( p < len ) {
			var c = children[p];
			if( c == null )
				break;
			if( c.lastFrame != ctx.frame ) {
				if( changed ) c.posChanged = true;
				c.sync(ctx);
			}
			// if the object was removed, let's restart again.
			// our lastFrame ensure that no object will get synched twice
			if( children[p] != c ) {
				p = 0;
				len = children.length;
			} else
				p++;
		}
	}

	function syncPos() {
		if( parent != null ) parent.syncPos();
		if( posChanged ) {
			calcAbsPos();
			for( c in children )
				c.posChanged = true;
			posChanged = false;
		}
	}

	function calcAbsPos() {
		if( parent == null ) {
			var cr, sr;
			if( rotation == 0 ) {
				cr = 1.; sr = 0.;
				matA = scaleX;
				matB = 0;
				matC = 0;
				matD = scaleY;
			} else {
				cr = Math.cos(rotation);
				sr = Math.sin(rotation);
				matA = scaleX * cr;
				matB = scaleX * sr;
				matC = scaleY * -sr;
				matD = scaleY * cr;
			}
			absX = x;
			absY = y;
		} else {
			// M(rel) = S . R . T
			// M(abs) = M(rel) . P(abs)
			if( rotation == 0 ) {
				matA = scaleX * parent.matA;
				matB = scaleX * parent.matB;
				matC = scaleY * parent.matC;
				matD = scaleY * parent.matD;
			} else {
				var cr = Math.cos(rotation);
				var sr = Math.sin(rotation);
				var tmpA = scaleX * cr;
				var tmpB = scaleX * sr;
				var tmpC = scaleY * -sr;
				var tmpD = scaleY * cr;
				matA = tmpA * parent.matA + tmpB * parent.matC;
				matB = tmpA * parent.matB + tmpB * parent.matD;
				matC = tmpC * parent.matA + tmpD * parent.matC;
				matD = tmpC * parent.matB + tmpD * parent.matD;
			}
			absX = x * parent.matA + y * parent.matC + parent.absX;
			absY = x * parent.matB + y * parent.matD + parent.absY;
		}
	}*/

















	
	
	public function new (id:Int = 0, x:Float = 0, y:Float = 0, scaleX:Float = 1, scaleY:Float = 1, rotation:Float = 0, originX:Float = 0, originY:Float = 0) {
		
		this.id = id;
		
		this.matrix = new Matrix ();
		if (x != 0) this.x = x;
		if (y != 0) this.y = y;
		if (scaleX != 1) this.scaleX = scaleX;
		if (scaleY != 1) this.scaleY = scaleY;
		if (rotation != 0) this.rotation = rotation;
		this.originX = originX;
		this.originY = originY;
		
		alpha = 1;
		visible = true;
		
		__length = 0;
		__alphaDirty = true;
		__sourceDirty = true;
		__transformDirty = true;
		__transform = [];
		
	}
	
	function __findTileset() {
		if (tileset != null) return tileset;
		if (parent != null) return parent.__findTileset();
		return null;
	}

	function __getWorldTransform():Matrix
	{
		var retval = matrix.clone();
		if (parent != null)
		{
			retval.concat(parent.__getWorldTransform());
		}
		return retval;
	}

	public function getBounds (targetCoordinateSpace:Tile):Rectangle {
		
		var result:Rectangle;
		
		if (tileset == null) {
			
			var parentTileset = parent.__findTileset ();
			if (parentTileset == null) return new Rectangle ();
			result = parentTileset.getRect (id);
			if (result == null) return new Rectangle ();
			
		} else {
			
			result = tileset.getRect (id);
			
		}

		result.x = 0;
		result.y = 0;

		var matrix = new Matrix();
		
		if (targetCoordinateSpace != null && targetCoordinateSpace != this) {
			
			matrix.copyFrom (__getWorldTransform ());
			
			var targetMatrix = new Matrix ();
			
			targetMatrix.copyFrom (targetCoordinateSpace.__getWorldTransform ());
			targetMatrix.invert ();
			
			matrix.concat (targetMatrix);
			
		} else {
			
			matrix.copyFrom (__getWorldTransform ());
			
		}
		
		#if flash
		function __transform (rect:Rectangle, m:Matrix):Void {
			
			var tx0 = m.a * rect.x + m.c * rect.y;
			var tx1 = tx0;
			var ty0 = m.b * rect.x + m.d * rect.y;
			var ty1 = ty0;
			
			var tx = m.a * (rect.x + rect.width) + m.c * rect.y;
			var ty = m.b * (rect.x + rect.width) + m.d * rect.y;
			
			if (tx < tx0) tx0 = tx;
			if (ty < ty0) ty0 = ty;
			if (tx > tx1) tx1 = tx;
			if (ty > ty1) ty1 = ty;
			
			tx = m.a * (rect.x + rect.width) + m.c * (rect.y + rect.height);
			ty = m.b * (rect.x + rect.width) + m.d * (rect.y + rect.height);
			
			if (tx < tx0) tx0 = tx;
			if (ty < ty0) ty0 = ty;
			if (tx > tx1) tx1 = tx;
			if (ty > ty1) ty1 = ty;
			
			tx = m.a * rect.x + m.c * (rect.y + rect.height);
			ty = m.b * rect.x + m.d * (rect.y + rect.height);
			
			if (tx < tx0) tx0 = tx;
			if (ty < ty0) ty0 = ty;
			if (tx > tx1) tx1 = tx;
			if (ty > ty1) ty1 = ty;
			
			rect.setTo (tx0 + m.tx, ty0 + m.ty, tx1 - tx0, ty1 - ty0);
			
		}
		__transform (result, matrix);
		#else
		result.__transform (result, matrix);
		#end
	
		return result;
		
	}


	public function clone ():Tile {
		
		var tile = new Tile (id);
		tile.matrix = matrix.clone ();
		tile.tileset = tileset;
		return tile;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function set_alpha (value:Float):Float {
		
		__alphaDirty = true;
		return alpha = value;
		
	}
	
	
	private function set_id (value:Int):Int {
		
		__sourceDirty = true;
		return id = value;
		
	}
	
	
	private function set_matrix (value:Matrix):Matrix {
		
		__rotation = null;
		__scaleX = null;
		__scaleY = null;
		__transformDirty = true;
		return this.matrix = value;
		
	}
	
	
	private function set_originX (value:Float):Float {
		
		__transformDirty = true;
		return this.originX = value;
		
	}
	
	
	private function set_originY (value:Float):Float {
		
		__transformDirty = true;
		return this.originY = value;
		
	}
	
	
	private function get_rotation ():Float {
		
		if (__rotation == null) {
			
			if (matrix.b == 0 && matrix.c == 0) {
				
				__rotation = 0;
				__rotationSine = 0;
				__rotationCosine = 1;
				
			} else {
				
				var radians = Math.atan2 (matrix.d, matrix.c) - (Math.PI / 2);
				
				__rotation = radians * (180 / Math.PI);
				__rotationSine = Math.sin (radians);
				__rotationCosine = Math.cos (radians);
				
			}
			
		}
		
		return __rotation;
		
	}
	
	
	private function set_rotation (value:Float):Float {
		
		if (value != __rotation) {
			
			__rotation = value;
			var radians = value * (Math.PI / 180);
			__rotationSine = Math.sin (radians);
			__rotationCosine = Math.cos (radians);
			
			var __scaleX = this.scaleX;
			var __scaleY = this.scaleY;
			
			matrix.a = __rotationCosine * __scaleX;
			matrix.b = __rotationSine * __scaleX;
			matrix.c = -__rotationSine * __scaleY;
			matrix.d = __rotationCosine * __scaleY;
			
			__transformDirty = true;
			
		}
		
		return value;
		
	}
	
	
	private function get_scaleX ():Float {
		
		if (__scaleX == null) {
			
			if (matrix.b == 0) {
				
				__scaleX = matrix.a;
				
			} else {
				
				__scaleX = Math.sqrt (matrix.a * matrix.a + matrix.b * matrix.b);
				
			}
			
		}
		
		return __scaleX;
		
	}
	
	
	private function set_scaleX (value:Float):Float {
		
		if (__scaleX != value) {
			
			__scaleX = value;
			
			if (matrix.b == 0) {
				
				matrix.a = value;
				
			} else {
				
				var rotation = this.rotation;
				
				var a = __rotationCosine * value;
				var b = __rotationSine * value;
				
				matrix.a = a;
				matrix.b = b;
				
			}
			
			__transformDirty = true;
			
		}
		
		return value;
		
	}
	
	
	private function get_scaleY ():Float {
		
		if (__scaleY == null) {
			
			if (matrix.c == 0) {
				
				__scaleY = matrix.d;
				
			} else {
				
				__scaleY = Math.sqrt (matrix.c * matrix.c + matrix.d * matrix.d);
				
			}
			
		}
		
		return __scaleY;
		
	}
	
	
	private function set_scaleY (value:Float):Float {
		
		if (__scaleY != value) {
			
			__scaleY = value;
			
			if (matrix.c == 0) {
				
				matrix.d = value;
				
			} else {
				
				var rotation = this.rotation;
				
				var c = -__rotationSine * value;
				var d = __rotationCosine * value;
				
				matrix.c = c;
				matrix.d = d;
				
			}
			
			__transformDirty = true;
			
		}
		
		return value;
		
	}
	
	
	private function set_tileset (value:Tileset):Tileset {
		
		__sourceDirty = true;
		return tileset = value;
		
	}
	
	
	private function get_x ():Float {
		
		return matrix.tx;
		
	}
	
	
	private function get_y ():Float {
		
		return matrix.ty;
		
	}
	
	
	private function set_x (value:Float):Float {
		
		__transformDirty = true;
		return matrix.tx = value;
		
	}
	
	
	private function set_y (value:Float):Float {
		
		__transformDirty = true;
		return matrix.ty = value;
		
	}
	
	
}
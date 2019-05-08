package openfl.display;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;


#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:access(openfl.geom.Matrix)
@:access(openfl.geom.Rectangle)

/**
 * OpenFL 4+ compatible TileContainer
 */
class TileContainer extends Tile {
	
	public var numTiles (get, never):Int;
	
	@:noCompletion private var __tiles:Array<Tile>;
	
	public function new (x:Float = 0, y:Float = 0, scaleX:Float = 1, scaleY:Float = 1, rotation:Float = 0, originX:Float = 0, originY:Float = 0) {
		
		super (-1, x, y, scaleX, scaleY, rotation, originX, originY);
		
		__tiles = new Array ();
		__length = 0;
		
	}


	function __setRenderDirty() {
		// TODO: Do it!
	}
	
	
	public function addTile (tile:Tile):Tile {
		
		if (tile == null) return null;
		
		var _drawableTiles = drawableTiles;

		if (tile.parent == this) {
			
			__tiles.remove (tile);
			__length--;

			if (tile.__length == 0) {
				drawableTiles--;
			} else {
				drawableTiles -= tile.drawableTiles;
			}
			
		}
		
		__tiles[numTiles] = tile;
		tile.parent = this;
		__length++;

		if (tile.__length == 0) {
			drawableTiles++;
		} else {
			drawableTiles += tile.drawableTiles;
		}

		addDrawableToParent(parent, drawableTiles - _drawableTiles);
		
		__setRenderDirty ();
		
		return tile;
		
	}
	

	inline function addDrawableToParent(parent:TileContainer, n:Int) {
		if (n != 0)  {
			while (parent != null) {
				parent.drawableTiles += n;
				parent = parent.parent;
			}
		}
	}
	
	
	public function addTileAt (tile:Tile, index:Int):Tile {
		
		if (tile == null) return null;

		var _drawableTiles = drawableTiles;
		
		if (tile.parent == this) {
			
			__tiles.remove (tile);
			__length--;

			if (tile.__length == 0) {
				drawableTiles--;
			} else {
				drawableTiles -= tile.drawableTiles;
			}
			
		}
		
		__tiles.insert (index, tile);
		tile.parent = this;
		__length++;

		if (tile.__length == 0) {
			drawableTiles++;
		} else {
			drawableTiles += tile.drawableTiles;
		}

		addDrawableToParent(parent, drawableTiles - _drawableTiles);
		
		__setRenderDirty ();
		
		return tile;
		
	}
	
	
	public function addTiles (tiles:Array<Tile>):Array<Tile> {
		
		for (tile in tiles) {
			addTile (tile);
		}
		
		return tiles;
		
	}
	
	
	public override function clone ():TileContainer {
		
		var group = new TileContainer ();
		for (tile in __tiles) {
			group.addTile (tile.clone ());
		}
		return group;
		
	}
	
	
	public function contains (tile:Tile):Bool {
		
		return (__tiles.indexOf (tile) > -1);
		
	}
	
	
	/**
	 * Override from tile. A single tile, just has his rectangle.
	 * A container must get a rectangle that contains all other rectangles.
	 * 
	 * @param targetCoordinateSpace The tile that works as a coordinate system.
	 * @return Rectangle The bounding box. If no box found, this will return {0,0,0,0} rectangle instead of null.
	 */
	var tempRect:Rectangle = null;
	public override function getBounds (targetCoordinateSpace:Tile):Rectangle {
		
		#if use_temp
		if (tempRect == null) tempRect = new Rectangle();
		tempRect.setTo(0, 0, 0, 0);
		var result = tempRect;
		#else
		var result = new Rectangle ();
		#end

		var rect = null;
		
		for (tile in __tiles) /*if (tile.visible)*/ {
			
			rect = tile.getBounds (targetCoordinateSpace);
			
			inline function union (rect:Rectangle, toUnion:Rectangle):Rectangle {
				
				return if (rect.width == 0 || rect.height == 0) {
					
					rect.setTo(toUnion.x, toUnion.y, toUnion.width, toUnion.height);
					rect;
					
				} else if (toUnion.width == 0 || toUnion.height == 0) {
					
					rect;
					
				} else {

					var x0 = rect.x > toUnion.x ? toUnion.x : rect.x;
					var x1 = rect.right < toUnion.right ? toUnion.right : rect.right;
					var y0 = rect.y > toUnion.y ? toUnion.y : rect.y;
					var y1 = rect.bottom < toUnion.bottom ? toUnion.bottom : rect.bottom;
					
					rect.setTo(x0, y0, x1 - x0, y1 - y0);
					rect;
				}

			}

			result = union (result, rect);

			/*#if flash
			inline function __expand (rect:Rectangle, x:Float, y:Float, width:Float, height:Float):Void {
		
				if (rect.width == 0 && rect.height == 0) {
					
					rect.x = x;
					rect.y = y;
					rect.width = width;
					rect.height = height;
					
				} else {
					var cacheRight = rect.right;
					var cacheBottom = rect.bottom;
					
					if (rect.x > x)
					{
						rect.x = x;
						rect.width = cacheRight - x;
					}
					if (rect.y > y)
					{
						rect.y = y;
						rect.height = cacheBottom - y;
					}
					if (cacheRight < x + width) rect.width = x + width - rect.x;
					if (cacheBottom < y + height) rect.height = y + height - rect.y;
				}
				
			}

			__expand (result, rect.x, rect.y, rect.width, rect.height);
			//result = result.union (rect);

			#else
			result.__expand (rect.x, rect.y, rect.width, rect.height);
			#end*/

			// __expand doesn't works!!!!! LOST SO MUCH TIME HOLY SHIT
			
		}
			
		return result;
		
	}

	/*public function globalToLocal(pos:Point):Point {

		pos = pos.clone ();

		#if flash

		function __transformInversePoint(matrix:Matrix, point:Point):Void {
			var norm = matrix.a * matrix.d - matrix.b * matrix.c;
			
			if (norm == 0) {
				point.x = -matrix.tx;
				point.y = -matrix.ty;
			} else {
				var px = (1.0 / norm) * (matrix.c * (matrix.ty - point.y) + matrix.d * (point.x - matrix.tx));
				point.y = (1.0 / norm) * ( matrix.a * (point.y - matrix.ty) + matrix.b * (matrix.tx - point.x) );
				point.x = px;
			}
		}

		__transformInversePoint(__getWorldTransform(), pos);

		#else
		
		__getWorldTransform().__transformInversePoint(pos);
		
		#end

		return pos;

	}*/

	//public function localToGlobal(point:Point):Point {

		//return __getWorldTransform().transformPoint(point);

		/*var result:Rectangle = new Rectangle(0, 0, 1, 1);

		result.x = x;
		result.y = y;

		var matrix = new Matrix();
		
		matrix.copyFrom (__getWorldTransform ());

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
	
		return new Point(result.x, result.y);*/

	//}
	
	
	public function getTileAt (index:Int):Tile {
		
		if (index >= 0 && index < numTiles) {
			
			return __tiles[index];
			
		}
		
		return null;
		
	}
	
	
	public function getTileIndex (tile:Tile):Int {
		
		for (i in 0...__tiles.length) {
			if (__tiles[i] == tile) return i;
		}
		
		return -1;
		
	}
	
	
	public function removeTile (tile:Tile):Tile {
		
		if (tile != null && tile.parent == this) {
			
			var _drawableTiles = drawableTiles;

			tile.parent = null;
			__tiles.remove (tile);
			__length--;

			if (tile.__length == 0) {
				drawableTiles--;
			} else {
				drawableTiles -= tile.drawableTiles;
			}

			addDrawableToParent(parent, drawableTiles - _drawableTiles);

			__setRenderDirty ();

		}
		
		return tile;
		
	}
	
	
	public function removeTileAt (index:Int):Tile {
		
		if (index >= 0 && index < numTiles) {
			return removeTile (__tiles[index]);
		}
		
		return null;
		
	}
	
	
	public function removeTiles (beginIndex:Int = 0, endIndex:Int = 0x7fffffff):Void {
		
		if (beginIndex < 0) beginIndex = 0;
		if (endIndex > __tiles.length - 1) endIndex = __tiles.length - 1;
		
		var _drawableTiles = drawableTiles;

		var removed = __tiles.splice (beginIndex, endIndex - beginIndex + 1);
		for (tile in removed) {
			tile.parent = null;

			if (tile.__length == 0) {
				drawableTiles--;
			} else {
				drawableTiles -= tile.drawableTiles;
			}
		}
		__length = __tiles.length;

		addDrawableToParent(parent, drawableTiles - _drawableTiles);
		
		__setRenderDirty ();
		
	}
	
	
	public function setTileIndex (tile:Tile, index:Int):Void {
		
		if (index >= 0 && index <= numTiles && tile.parent == this) {
			
			__tiles.remove (tile);
			__tiles.insert (index, tile);
			__setRenderDirty ();
			
		}
		
	}
	
	
	public function swapTiles (tile1:Tile, tile2:Tile):Void {
		
		if (tile1.parent == this && tile2.parent == this) {
			
			var index1 = __tiles.indexOf (tile1);
			var index2 = __tiles.indexOf (tile2);
			
			__tiles[index1] = tile2;
			__tiles[index2] = tile1;
			
			__setRenderDirty ();
			
		}
		
	}
	
	
	public function swapTilesAt (index1:Int, index2:Int):Void {
		
		var swap = __tiles[index1];
		__tiles[index1] = __tiles[index2];
		__tiles[index2] = swap;
		swap = null;
		
		__setRenderDirty ();
		
	}
	
	
	
	
	// Event Handlers
	
	
	
	
	@:noCompletion private function get_numTiles ():Int {
		
		return __length;
		
	}
	
	
}
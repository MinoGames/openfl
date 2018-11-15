package openfl._internal.renderer.flash;


import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.display.Tilemap;
import openfl.display.TileContainer;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

@:access(openfl.display.Tilemap)
@:access(openfl.display.TileContainer)
@:access(openfl.display.Tile)
@:access(openfl.display.Tileset)


class FlashTilemap {
	
	
	private static var colorTransform = new ColorTransform ();
	private static var destPoint = new Point ();
	private static var sourceRect = new Rectangle ();
	private static var tileMatrix = new Matrix ();
	
	
	public static inline function render (tilemap:Tilemap):Void {
		
		#if flash
		if (tilemap.stage == null || !tilemap.visible || tilemap.alpha <= 0) return;
		
		var bitmapData = tilemap.bitmapData;
		
		bitmapData.lock ();
		bitmapData.fillRect (bitmapData.rect, 0);
		
		var worldAlpha = tilemap.alpha;
		var parentTransform = new Matrix();

		renderGroup(bitmapData, tilemap, tilemap.__group, worldAlpha, tilemap.visible, parentTransform);
		
		bitmapData.unlock ();
		#end
		
	}

	#if flash
	static function renderGroup(bitmapData:BitmapData, tilemap:Tilemap, group:TileContainer, worldAlpha:Float, worldVisible:Bool, matrix:Matrix) {

		var smoothing = tilemap.smoothing;

		var tileTransform = new Matrix();
		
		var tiles, count, tile, alpha, visible, tileset, tileData, sourceBitmapData;
		
		if (group.__tiles.length > 0) {
			
			tiles = group.__tiles;
			count = tiles.length;

			for (i in 0...count) {
				
				tile = tiles[i];
				
				alpha = worldAlpha * tile.alpha;
				visible = worldVisible && tile.visible;
				
				if (!visible || alpha <= 0) continue;

				tileTransform.setTo (1, 0, 0, 1, -tile.originX, -tile.originY);
				tileTransform.concat (tile.matrix);
				tileTransform.concat (matrix);

				if (tile.__length > 0) {

					renderGroup(bitmapData, tilemap, cast tile, alpha, visible, tileTransform);

				} else {
				
					tileset = (tile.tileset != null) ? tile.tileset : tilemap.tileset;
					
					if (tileset == null) continue;
					
					tileData = tileset.__data[tile.id];
					
					if (tileData == null) continue;
					
					sourceBitmapData = tileData.__bitmapData;
					
					if (sourceBitmapData == null || alpha == 0) continue;
					
					if (alpha == 1 && tileTransform.a == 1 && tileTransform.b == 0 && tileTransform.c == 0 && tileTransform.d == 1) {
						
						destPoint.x = tileTransform.tx;
						destPoint.y = tileTransform.ty;
						
						bitmapData.copyPixels (sourceBitmapData, sourceBitmapData.rect, destPoint, null, null, true);
						
					} else {
						
						colorTransform.alphaMultiplier = alpha;
						
						bitmapData.draw (sourceBitmapData, tileTransform, colorTransform, null, null, smoothing);
						
					}

				}
				
			}
			
		}

	}
	#end
	
	
}
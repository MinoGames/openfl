package openfl._internal.renderer;


import openfl.display.BitmapData;
import openfl.display.CapsStyle;
import openfl.display.GradientType;
import openfl.display.GraphicsPathWinding;
import openfl.display.InterpolationMethod;
import openfl.display.JointStyle;
import openfl.display.LineScaleMode;
import openfl.display.Shader;
import openfl.display.SpreadMethod;
import openfl.display.TriangleCulling;
import openfl.geom.Rectangle;
import openfl.geom.Matrix;
import openfl.Vector;

@:allow(openfl._internal.renderer.DrawCommandReader)


class DrawCommandBuffer {
	
	
	private static var empty:DrawCommandBuffer = new DrawCommandBuffer ();
	
	public var length (get, never):Int; 
	public var types:Array<DrawCommandType>;
	
	public var requiresSoftware:Bool;
	public var bitmapDraws:Array<{bd:BitmapData, transform:Matrix}>;
	
	private var b:Array<Bool>;
	private var copyOnWrite:Bool;
	private var f:Array<Float>;
	private var ff:Array<Array<Float>>;
	private var i:Array<Int>;
	private var ii:Array<Array<Int>>;
	private var o:Array<Dynamic>;
	
	
	public function new () {
		
		if (empty == null) {
			
			types = [];
			
			b = [];
			i = [];
			f = [];
			o = [];
			ff = [];
			ii = [];
			
			copyOnWrite = true;
			bitmapDraws = [];
			
		} else {
			
			clear ();
			
		}
		
	}
	
	public function updateBitmapDraws():Void {
		
		var reader = new DrawCommandReader (this);
		var bitmap = null;
		var points = [];
		
		bitmapDraws = [];
		requiresSoftware = false;
		
		for(type in types) {
			
			switch(type){
			
				case BEGIN_BITMAP_FILL:
					var c = reader.readBeginBitmapFill();
					bitmap = c.bitmap;
					
				case END_FILL : 
					reader.skip(type);
					points = [];
					bitmap = null;
					
				case DRAW_RECT :
					var c = reader.readDrawRect();
					var transform = new Matrix();
					transform.translate(c.x, c.y);
					transform.scale(c.width / bitmap.width, c.height / bitmap.height);
					bitmapDraws.push({bd:bitmap, transform:transform});		
					
				case LINE_TO : 
					var point = reader.readLineTo();
					points.push({x:point.x, y:point.y});
					
					if(points.length == 4) {
						if(bitmap != null){
							var minX = Math.POSITIVE_INFINITY;
							var minY = Math.POSITIVE_INFINITY;
							var maxX = Math.NEGATIVE_INFINITY;
							var maxY = Math.NEGATIVE_INFINITY;
							var transform = new Matrix();
							
							for(p in points){
								if(p.x < minX) minX = p.x;
								if(p.y < minY) minY = p.y;
								if(p.x > maxX) maxX = p.x;
								if(p.y > maxY) maxY = p.y;
							}
							
							transform.translate(minX, minY);
							transform.scale(Math.abs(maxX - minX) / bitmap.width, Math.abs(maxY - minY) / bitmap.height);
							bitmapDraws.push({bd:bitmap, transform:transform});	
						}
						points = [];
					}
					
				case MOVE_TO, LINE_STYLE : 
					reader.skip(type);
				
				default : 
					requiresSoftware = true;
					reader.skip(type);
					
					break;
			}
		}
		
		
		
		reader.destroy();
	}
	
	
	public function append (other:DrawCommandBuffer):DrawCommandBuffer {
		
		if (length == 0) {
			
			this.types = other.types;
			this.b = other.b;
			this.i = other.i;
			this.f = other.f;
			this.o = other.o;
			this.ff = other.ff;
			this.ii = other.ii;
			this.copyOnWrite = other.copyOnWrite = true;
			this.bitmapDraws = other.bitmapDraws.copy();
			this.requiresSoftware = other.requiresSoftware;
			
			return other;
			
		}
		
		var data = new DrawCommandReader (other);
		
		for (type in other.types) {
			
			switch (type) {
				
				case BEGIN_BITMAP_FILL: var c = data.readBeginBitmapFill (); beginBitmapFill (c.bitmap, c.matrix, c.repeat, c.smooth);
				case BEGIN_FILL: var c = data.readBeginFill (); beginFill (c.color, c.alpha);
				case BEGIN_GRADIENT_FILL: var c = data.readBeginGradientFill (); beginGradientFill (c.type, c.colors, c.alphas, c.ratios, c.matrix, c.spreadMethod, c.interpolationMethod, c.focalPointRatio);
				case CUBIC_CURVE_TO: var c = data.readCubicCurveTo (); cubicCurveTo (c.controlX1, c.controlY1, c.controlX2, c.controlY2, c.anchorX, c.anchorY);
				case CURVE_TO: var c = data.readCurveTo (); curveTo (c.controlX, c.controlY, c.anchorX, c.anchorY);
				case DRAW_CIRCLE: var c = data.readDrawCircle (); drawCircle (c.x, c.y, c.radius);
				case DRAW_ELLIPSE: var c = data.readDrawEllipse (); drawEllipse (c.x, c.y, c.width, c.height);
				case DRAW_RECT: var c = data.readDrawRect (); drawRect (c.x, c.y, c.width, c.height);
				case DRAW_ROUND_RECT: var c = data.readDrawRoundRect (); drawRoundRect (c.x, c.y, c.width, c.height, c.ellipseWidth, c.ellipseHeight);
				case DRAW_TRIANGLES: var c = data.readDrawTriangles (); drawTriangles (c.vertices, c.indices, c.uvtData, c.culling);
				case END_FILL: var c = data.readEndFill (); endFill ();
				case LINE_BITMAP_STYLE: var c = data.readLineBitmapStyle (); lineBitmapStyle (c.bitmap, c.matrix, c.repeat, c.smooth);
				case LINE_GRADIENT_STYLE: var c = data.readLineGradientStyle (); lineGradientStyle (c.type, c.colors, c.alphas, c.ratios, c.matrix, c.spreadMethod, c.interpolationMethod, c.focalPointRatio);
				case LINE_STYLE: var c = data.readLineStyle (); lineStyle (c.thickness, c.color, c.alpha, c.pixelHinting, c.scaleMode, c.caps, c.joints, c.miterLimit);
				case LINE_TO: var c = data.readLineTo (); lineTo (c.x, c.y);
				case MOVE_TO: var c = data.readMoveTo (); moveTo (c.x, c.y);
				case OVERRIDE_MATRIX: var c = data.readOverrideMatrix (); overrideMatrix (c.matrix);
				default:
				
			}
			
		}
		
		data.destroy ();
		
		updateBitmapDraws();
		return other;
		
	}
	
	
	public function beginBitmapFill(bitmap:BitmapData, matrix:Matrix, repeat:Bool, smooth:Bool):Void {
		
		prepareWrite ();
		
		types.push (BEGIN_BITMAP_FILL);
		o.push (bitmap);
		o.push (matrix);
		b.push (repeat);
		b.push (smooth);
		
		updateBitmapDraws();
		
	}
	
	public function beginFill (color:Int, alpha:Float):Void {
		
		prepareWrite ();
		
		types.push (BEGIN_FILL);
		updateBitmapDraws();
		i.push (color);
		f.push (alpha);
		
	}
	
	
	public function beginGradientFill (type:GradientType, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, matrix:Matrix, spreadMethod:SpreadMethod, interpolationMethod:InterpolationMethod, focalPointRatio:Float):Void {
		
		prepareWrite ();
		
		types.push (BEGIN_GRADIENT_FILL);
		updateBitmapDraws();
		o.push (type);
		ii.push (colors);
		ff.push (alphas);
		ii.push (ratios);
		o.push (matrix);
		o.push (spreadMethod);
		o.push (interpolationMethod);
		f.push (focalPointRatio);
		
	}
	
	
	public function clear ():Void {
		
		types = empty.types;
		updateBitmapDraws();
		
		b = empty.b;
		i = empty.i;
		f = empty.f;
		o = empty.o;
		ff = empty.ff;
		ii = empty.ii;
		
		copyOnWrite = true;
		
	}
	
	
	public function copy ():DrawCommandBuffer {
		
		var copy = new DrawCommandBuffer ();
		copy.append (this);
		return copy;
		
	}
	
	
	public function cubicCurveTo (controlX1:Float, controlY1:Float, controlX2:Float, controlY2:Float, anchorX:Float, anchorY:Float):Void {
		
		prepareWrite ();
		
		types.push (CUBIC_CURVE_TO);
		updateBitmapDraws();
		f.push (controlX1);
		f.push (controlY1);
		f.push (controlX2);
		f.push (controlY2);
		f.push (anchorX);
		f.push (anchorY);
		
	}
	
	public function curveTo (controlX:Float, controlY:Float, anchorX:Float, anchorY:Float):Void {
		
		prepareWrite ();
		
		types.push (CURVE_TO);
		updateBitmapDraws();
		f.push (controlX);
		f.push (controlY);
		f.push (anchorX);
		f.push (anchorY);
		
	}
	
	
	public function destroy ():Void {
		
		clear ();
		
		types = null;
		
		b = null;
		i = null;
		f = null;
		o = null;
		ff = null;
		ii = null;
		
	}
	
	
	public function drawCircle (x:Float, y:Float, radius:Float):Void {
		
		prepareWrite ();
		
		types.push (DRAW_CIRCLE);
		updateBitmapDraws();
		f.push (x);
		f.push (y);
		f.push (radius);
		
	}
	
	
	public function drawEllipse (x:Float, y:Float, width:Float, height:Float):Void {
		
		prepareWrite ();
		
		types.push (DRAW_ELLIPSE);
		updateBitmapDraws();
		f.push (x);
		f.push (y);
		f.push (width);
		f.push (height);
		
	}
	
	
	public function drawRect (x:Float, y:Float, width:Float, height:Float):Void {
		
		prepareWrite ();
		
		types.push (DRAW_RECT);
		updateBitmapDraws();
		f.push (x);
		f.push (y);
		f.push (width);
		f.push (height);
		
	}
	
	public function drawRoundRect (x:Float, y:Float, width:Float, height:Float, ellipseWidth:Float, ellipseHeight:Null<Float>):Void {
		
		prepareWrite ();
		
		types.push (DRAW_ROUND_RECT);
		updateBitmapDraws();
		f.push (x);
		f.push (y);
		f.push (width);
		f.push (height);
		f.push (ellipseWidth);
		o.push (ellipseHeight);
		
	}
	
	
	public function drawTriangles (vertices:Vector<Float>, indices:Vector<Int>, uvtData:Vector<Float>, culling:TriangleCulling):Void {
		
		prepareWrite ();
		
		types.push (DRAW_TRIANGLES);
		updateBitmapDraws();
		o.push (vertices);
		o.push (indices);
		o.push (uvtData);
		o.push (culling);
		
	}
	
	
	public function endFill ():Void {
		
		prepareWrite ();
		
		types.push (END_FILL);
		updateBitmapDraws();
		
	}
	
	
	public function lineBitmapStyle (bitmap:BitmapData, matrix:Matrix, repeat:Bool, smooth:Bool):Void {
		
		prepareWrite ();
		
		types.push (LINE_BITMAP_STYLE);
		updateBitmapDraws();
		o.push (bitmap);
		o.push (matrix);
		b.push (repeat);
		b.push (smooth);
		
	}
	
	
	public function lineGradientStyle (type:GradientType, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Int>, matrix:Matrix, spreadMethod:SpreadMethod, interpolationMethod:InterpolationMethod, focalPointRatio:Float):Void {
		
		prepareWrite ();
		
		types.push (LINE_GRADIENT_STYLE);
		updateBitmapDraws();
		o.push (type);
		ii.push (colors);
		ff.push (alphas);
		ii.push (ratios);
		o.push (matrix);
		o.push (spreadMethod);
		o.push (interpolationMethod);
		f.push (focalPointRatio);
		
	}
	
	
	public function lineStyle (thickness:Null<Float>, color:Int, alpha:Float, pixelHinting:Bool, scaleMode:LineScaleMode, caps:CapsStyle, joints:JointStyle, miterLimit:Float):Void {
		
		prepareWrite ();
		
		types.push (LINE_STYLE);
		updateBitmapDraws();
		o.push (thickness);
		i.push (color);
		f.push (alpha);
		b.push (pixelHinting);
		o.push (scaleMode);
		o.push (caps);
		o.push (joints);
		f.push (miterLimit);
		
	}
	
	
	public function lineTo (x:Float, y:Float):Void {
		
		prepareWrite ();
		
		types.push (LINE_TO);
		updateBitmapDraws();
		f.push (x);
		f.push (y);
		
	}
	
	
	public function moveTo (x:Float, y:Float):Void {
		
		prepareWrite ();
		
		types.push (MOVE_TO);
		updateBitmapDraws();
		f.push (x);
		f.push (y);
		
	}
	
	
	private function prepareWrite ():Void {
		
		if (copyOnWrite) {
			
			types = types.copy ();
			b = b.copy ();
			i = i.copy ();
			f = f.copy ();
			o = o.copy ();
			ff = ff.copy ();
			ii = ii.copy ();
			
			copyOnWrite = false;
			
		}
		
	}
	
	
	public function overrideMatrix (matrix:Matrix):Void {
		
		prepareWrite ();
		
		types.push (OVERRIDE_MATRIX);
		updateBitmapDraws();
		o.push (matrix);
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function get_length ():Int {
		
		return types.length;
		
	}
	
	
}
package openfl._internal.symbols;


import openfl._internal.swf.SWFLite;
import openfl._internal.timeline.Frame;
import openfl.display.MovieClip;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl.display.MovieClip)

#if !macro
class SpriteSymbol extends SWFSymbol {

	
	public var frames:Array<Frame>;
	
	
	public function new () {
		
		super ();
		
		frames = new Array<Frame> ();
		
	}
	
	
	private override function __createObject (swf:SWFLite):MovieClip {
		
		var movieClip:MovieClip = null;
		
		if (className != null) {
			
			var symbolType = Type.resolveClass (className);
			
			if (symbolType != null) {
				
				movieClip = Type.createInstance (symbolType, []);
				
			} else {
				
				//Log.warn ("Could not resolve class \"" + className + "\"");
				
			}
			
		}
		
		if (movieClip == null) {
			
			movieClip = new MovieClip ();
		}
		
		movieClip.__fromSymbol(swf, this);

		return movieClip;
		
	}
	
	
}
#end
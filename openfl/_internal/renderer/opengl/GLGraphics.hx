package openfl._internal.renderer.opengl;


import lime.utils.Float32Array;
import openfl._internal.renderer.cairo.CairoGraphics;
import openfl._internal.renderer.canvas.CanvasGraphics;
import openfl.display.Graphics;
import openfl.display.Bitmap;
import openfl.display.Shader;
import openfl.geom.Matrix;

@:access(openfl.display.Graphics)


class GLGraphics {


	public static function render (graphics:Graphics, renderSession:RenderSession, parentTransform:Matrix, worldAlpha:Float):Void {

		
		// if (graphics.__commands.requiresSoftware) {
		if (true) {
			#if (js && html5)
			CanvasGraphics.render (graphics, renderSession, parentTransform);
			#elseif lime_cairo
			CairoGraphics.render (graphics, renderSession, parentTransform);
			#end

		} else {
			

			graphics.__update ();

			var bounds = graphics.__bounds;
			var width = graphics.__width;
			var height = graphics.__height;

			if (bounds != null && width >= 1 && height >= 1) {

				var renderer:GLRenderer = cast renderSession.renderer;
				var gl = renderSession.gl;
				
				for(draws in graphics.__commands.bitmapDraws){
					
					var bitmap = draws.bd;
					var transform = draws.transform;
					// transform.concat(parentTransform);
					
					var shader = new Shader();
					shader.data.uImage0.input = bitmap;
					// shader.data.uImage0.smoothing =  true;//renderSession.allowSmoothing;
					shader.data.uMatrix.value = renderer.getMatrix (transform);

					renderSession.shaderManager.setShader (shader);

					gl.bindBuffer (gl.ARRAY_BUFFER, bitmap.getBuffer (gl, worldAlpha));
					gl.vertexAttribPointer (shader.data.aPosition.index, 3, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 0);
					gl.vertexAttribPointer (shader.data.aTexCoord.index, 2, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
					gl.vertexAttribPointer (shader.data.aAlpha.index, 1, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
					gl.drawArrays (gl.TRIANGLE_STRIP, 0, 4);	
					// */
				}
			}

			graphics.__dirty = false;

		}

	}


}
package;

import flixel.system.FlxAssets.FlxShader;

class ChromaticAberration extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float rOffsetX;
		uniform float rOffsetY;
		uniform float gOffsetX;
		uniform float gOffsetY;
		uniform float bOffsetX;
		uniform float bOffsetY;

		void main()
		{
			vec4 col1 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(rOffsetX, rOffsetY));
			vec4 col2 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(gOffsetX, gOffsetY));
			vec4 col3 = texture2D(bitmap, openfl_TextureCoordv.st - vec2(bOffsetX, bOffsetY));
			vec4 toUse = texture2D(bitmap, openfl_TextureCoordv);
			toUse.r = col1.r;
			toUse.g = col2.g;
			toUse.b = col3.b;
			//float someshit = col4.r + col4.g + col4.b;

			gl_FragColor = toUse;
		}')
	public function new()
	{
		super();
	}
}
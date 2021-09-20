package;

import flixel.system.FlxAssets.FlxShader;

class Bright extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float contrast;

		void main()
		{
			vec4 fUse = texture2D(bitmap, openfl_TextureCoordv);
			vec3 contrasted = fUse.rgb * contrast;
			fUse.rgb = contrasted;

			gl_FragColor = fUse;
		}
	')
	public function new()
	{
		super();
	}
}
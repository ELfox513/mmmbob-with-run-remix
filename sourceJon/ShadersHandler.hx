package;

import openfl.filters.ShaderFilter;

class ShadersHandler
{
	public static var chromaticAberration:ShaderFilter = new ShaderFilter(new ChromaticAberration());
	public static var brightShader:ShaderFilter = new ShaderFilter(new Bright());
	
	public static function setContrast(contrast:Float):Void
    {
		/**
        if (Highscore.getPhoto())
		{
			contrast = 1.0;
		}
        **/
		brightShader.shader.data.contrast.value = [contrast];
	}

    public static function setChrome(rOffX:Float, rOffY:Float, gOffX:Float, gOffY:Float, bOffX:Float, bOffY:Float):Void {            
        chromaticAberration.shader.data.rOffsetX.value = [rOffX];
        chromaticAberration.shader.data.rOffsetY.value = [rOffY];
        chromaticAberration.shader.data.gOffsetX.value = [gOffX];
        chromaticAberration.shader.data.gOffsetY.value = [gOffY];
        chromaticAberration.shader.data.bOffsetX.value = [bOffX];
        chromaticAberration.shader.data.bOffsetY.value = [bOffY];
    
    }
}
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;

class ThankYouState extends MusicBeatState
{
	override function create()
	{
		super.create();
		var thx:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('bob/thankers', 'shared'));
		add(thx);
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
	}

	override function update(elapsed:Float)
	{
		var touched:Bool = false;

		#if mobile
		for (touch in FlxG.touches.list) {
			if (touch.justPressed) {
				touched = true;
			}
		}
		#end

		if (controls.ACCEPT || touched)
		{
			FlxG.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}
}

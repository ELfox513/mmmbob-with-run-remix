package;

import flixel.FlxG;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;
import flixel.util.FlxDestroyUtil;
import flixel.ui.FlxButton;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import flixel.graphics.FlxGraphic;
import openfl.utils.ByteArray;

enum DPadMode {
    NONE;   UP_DOWN;    LEFT_RIGHT; UP_LEFT_RIGHT;  L_FULL; R_FULL; CUSTOM; HITBOX;
}

enum ActionMode {
	NONE;   A;  A_B;    A_B_C;  A_B_X_Y;
}

@:keep @:bitmap("assets/preload/images/virtual-input.png")
class GraphicVirtualInput extends BitmapData {}
 
@:file("assets/preload/images/virtual-input.txt")
class VirtualInputData extends #if (lime_legacy || nme) ByteArray #else ByteArrayData #end {}

class VirtualPad extends FlxSpriteGroup
{
	public var btn_A:FlxButton;
	public var btn_B:FlxButton;
	public var btn_C:FlxButton;
	public var btn_Y:FlxButton;
	public var btn_X:FlxButton;
	public var btn_Left:FlxButton;
	public var btn_Up:FlxButton;
	public var btn_Right:FlxButton;
	public var btn_Down:FlxButton;

	public var dpad:FlxSpriteGroup;
	public var actions:FlxSpriteGroup;

    public var button_coords:Array<Array<Int>> = [for (button in 0...9) [for (coord in 0...1) 0]];
    public var button_scale:Array<Array<Int>> = [for (button in 0...9) [for (coord in 0...1) 0]];
    public var button_alpha:Array<Array<Int>> = [for (button in 0...9) [for (coord in 0...1) 0]];

	public function new(?dpad_mode:DPadMode, ?action_mode:ActionMode) {
		super();
        
		scrollFactor.set();

		if (dpad_mode == null) dpad_mode = L_FULL;
		if (action_mode == null) action_mode = A_B_C;

		dpad = new FlxSpriteGroup();
		dpad.scrollFactor.set();
		actions = new FlxSpriteGroup();
		actions.scrollFactor.set();

		switch (dpad_mode) {
			case UP_DOWN:
				dpad.add(add(btn_Up    = createButton(0,   FlxG.height - 255, 132, 135, "up")));
				dpad.add(add(btn_Down  = createButton(0,   FlxG.height - 135, 132, 135, "down")));
			case LEFT_RIGHT:
				dpad.add(add(btn_Left  = createButton(0,   FlxG.height - 135, 132, 135, "left")));
				dpad.add(add(btn_Right = createButton(126, FlxG.height - 135, 132, 135, "right")));
			case UP_LEFT_RIGHT:
				dpad.add(add(btn_Up    = createButton(105, FlxG.height - 243, 132, 135, "up")));
				dpad.add(add(btn_Left  = createButton(0,   FlxG.height - 135, 132, 135, "left")));
				dpad.add(add(btn_Right = createButton(207, FlxG.height - 135, 132, 135, "right")));
			case L_FULL:
				dpad.add(add(btn_Up    = createButton(105, FlxG.height - 348, 132, 135, "up")));
				dpad.add(add(btn_Left  = createButton(0,   FlxG.height - 243, 132, 135, "left")));
				dpad.add(add(btn_Right = createButton(207, FlxG.height - 243, 132, 135, "right")));
				dpad.add(add(btn_Down  = createButton(105, FlxG.height - 135, 132, 135, "down")));
			case R_FULL:
				dpad.add(add(btn_Up    = createButton(FlxG.width - 258, FlxG.height - 414, 132, 135, "up")));
				dpad.add(add(btn_Left  = createButton(FlxG.width - 390, FlxG.height - 309, 132, 135, "left")));
				dpad.add(add(btn_Right = createButton(FlxG.width - 132, FlxG.height - 309, 132, 135, "right")));
				dpad.add(add(btn_Down  = createButton(FlxG.width - 258, FlxG.height - 201, 132, 135, "down")));
			case CUSTOM:
            case HITBOX:
            case NONE: // do nothing
		}

        // dpad.add(add(btn_Up    = createButton(FlxG.width - 258, FlxG.height - 414, 132, 135, "up")));
		// dpad.add(add(btn_Left  = createButton(FlxG.width - 390, FlxG.height - 309, 132, 135, "left")));
		// dpad.add(add(btn_Right = createButton(FlxG.width - 132, FlxG.height - 309, 132, 135, "right")));
		// dpad.add(add(btn_Down  = createButton(FlxG.width - 258, FlxG.height - 201, 132, 135, "down")));

		switch (action_mode)
		{
			case A:
				actions.add(add(btn_A = createButton(FlxG.width - 132, FlxG.height - 135, 132, 135, "a")));
			case A_B:
				actions.add(add(btn_A = createButton(FlxG.width - 132, FlxG.height - 135, 132, 135, "a")));
				actions.add(add(btn_B = createButton(FlxG.width - 258, FlxG.height - 135, 132, 135, "b")));
			case A_B_C:
				actions.add(add(btn_A = createButton(FlxG.width - 132, FlxG.height - 135, 132, 135, "a")));
				actions.add(add(btn_B = createButton(FlxG.width - 258, FlxG.height - 135, 132, 135, "b")));
				actions.add(add(btn_C = createButton(FlxG.width - 396, FlxG.height - 135, 132, 135, "c")));
			case A_B_X_Y:
				actions.add(add(btn_Y = createButton(FlxG.width - 258, FlxG.height - 255, 132, 135, "y")));
				actions.add(add(btn_X = createButton(FlxG.width - 132, FlxG.height - 255, 132, 135, "x")));
				actions.add(add(btn_A = createButton(FlxG.width - 132, FlxG.height - 135, 132, 135, "a")));
				actions.add(add(btn_B = createButton(FlxG.width - 258, FlxG.height - 135, 132, 135, "b")));
			case NONE: // do nothing
		}
	}

	override public function destroy():Void {
		super.destroy();

		dpad = FlxDestroyUtil.destroy(dpad);
		actions = FlxDestroyUtil.destroy(actions);

		dpad = null;
		actions = null;
		btn_A = null;
		btn_B = null;
		btn_C = null;
		btn_Y = null;
		btn_X = null;
		btn_Left = null;
		btn_Up = null;
		btn_Down = null;
		btn_Right = null;
	}

    public function createButton(X:Float, Y:Float, Width:Int, Height:Int, Graphic:String, ?OnClick:Void->Void):FlxButton {
		var button = new FlxButton(X, Y);
		var frame = getVirtualInputFrames().getByName(Graphic);
		button.frames = FlxTileFrames.fromFrame(frame, FlxPoint.get(Width, Height));
		button.resetSizeFromFrame();
		button.solid = false;
		button.immovable = true;
		button.scrollFactor.set();

		#if FLX_DEBUG
		button.ignoreDrawDebug = true;
		#end

		if (OnClick != null) button.onDown.callback = OnClick;

		return button;
	}

	public static function getVirtualInputFrames():FlxAtlasFrames {
        #if !web
        var bitmapData = new GraphicVirtualInput(0, 0);
        #end
        
        #if !web
        var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmapData);
        return FlxAtlasFrames.fromSpriteSheetPacker(graphic, Std.string(new VirtualInputData()));
        #else
        var graphic:FlxGraphic = FlxGraphic.fromAssetKey(Paths.image('virtual-input'));
        return FlxAtlasFrames.fromSpriteSheetPacker(graphic, Std.string(new VirtualInputData()));
        #end
	}
}
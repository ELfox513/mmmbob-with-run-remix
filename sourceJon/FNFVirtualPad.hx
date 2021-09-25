package;

#if VIRT_CONTROLS
import flixel.ui.FlxVirtualPad;
#end

class FNFVirtualPad extends FlxVirtualPad {

    #if VIRT_CONTROLS
    #end

    public function new(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
        #if VIRT_CONTROLS
        super(DPad, Action);
        #end
    }

    override function update(elapsed:Float) {
        #if VIRT_CONTROLS
        super.update(elapsed);
        #end
    }

    override public function destroy():Void {
        #if VIRT_CONTROLS
        super.destroy();
        #end
    }
}
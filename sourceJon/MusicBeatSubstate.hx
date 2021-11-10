package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxCamera;
import flixel.ui.FlxVirtualPad;
import flixel.input.actions.FlxActionInput;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	// ELabel begin
	public var v_pad:FlxVirtualPad;

	var trackedinputs:Array<FlxActionInput> = [];

	public var v_pad_cam:FlxCamera;

	// adding virtualpad to state
	public function addVirtualPad(?DPad:FlxDPadMode, ?Action:FlxActionMode) {
		v_pad = new FlxVirtualPad(DPad, Action);
		v_pad.alpha = 0.75;
		v_pad_cam = new FlxCamera();
		FlxG.cameras.add(v_pad_cam);
		v_pad_cam.bgColor.alpha = 0;
		v_pad.cameras = [v_pad_cam];
		add(v_pad);
		controls.setVirtualPad(v_pad, DPad, Action);
		trackedinputs = controls.trackedinputs;
		controls.trackedinputs = [];

		#if mobile
		controls.addAndroidBack();
		#end
	}

	override function destroy() {
		controls.removeFlxInput(trackedinputs);

		super.destroy();
	}
	// ELabel end

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		curBeat = Math.floor(curStep / 4);

		if (oldStep != curStep && curStep > 0)
			stepHit();


		super.update(elapsed);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.songPosition - lastChange.songTime) / Conductor.stepCrochet);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}

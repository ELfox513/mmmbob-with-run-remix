package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.math.FlxRandom; // ELabel
import lime.utils.Assets;

import flixel.tweens.FlxTween; // ELabel
import flixel.FlxCamera; 
import openfl.filters.BitmapFilter;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var diffText:FlxText;
	var diffText2:FlxText; // ELabel
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	var random:FlxRandom; // ELabel
	var bg:FlxSprite; 
	var bg2:FlxSprite; 
	var scoreBG:FlxSprite; 
	var numForRunIter:Int = 0;  
	var mainCam:FlxCamera;
	var filters:Array<BitmapFilter>;
	var chromeValue:Float = 0;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		mainCam = new FlxCamera(); // ELabel 
		FlxG.cameras.reset(mainCam);
		FlxCamera.defaultCameras = [mainCam];
		filters = [ShadersHandler.chromaticAberration];
		FlxG.camera.setFilters(filters);
		FlxG.camera.filtersEnabled = true;

		var initSonglist = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		random = new FlxRandom(); // ELabel

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		}

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		 #if windows
		 // Updating Discord Rich Presence
		 DiscordClient.changePresence("In the Menus", null);
		 #end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuBGBlue')); // ELabel
		add(bg);
		bg2 = new FlxSprite().loadGraphic(Paths.image('bobscreen')); // ELabel
		bg2.alpha = 0;
		add(bg2);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000); // ELabel
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText2 = new FlxText(scoreText.x, scoreText.y + 54, 0, "", 24); // ELabel
		diffText2.font = scoreText.font;
		add(diffText);
		add(diffText2);

		add(scoreText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.LEFT_P)
			changeDiff(-1);
		if (controls.RIGHT_P)
			changeDiff(1);

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

		if (songs[curSelected].songName == 'run-remix-because-its-cool') { // ELabel for BIG BLOCK
			for (item in grpSongs.members) {
				item.offset.set(random.float(-5, 5), random.float(-5, 5)); // Some shaking for songs titles, I mean
			}
			for (i in 0...iconArray.length) {
				iconArray[i].offset.set(random.float(-5, 5), random.float(-5, 5)); // Some shaking for icons
			}
			curDifficulty = 1;
			diffText.text = "";

			if (numForRunIter < 351) { // So many RUNs, so litte FPS. Agree?           //RUNRUNRUNRUNRUNRUN
				if (numForRunIter == 0) scoreText.text = "";                           //RUNRUNRUNRUNRUNRUN
				if (numForRunIter % 14 == 13) scoreText.text = scoreText.text + "\n";  //RUNRUNRUNRUNRUNRUN
				if (numForRunIter % 2 == 0) scoreText.text = scoreText.text + "RUN";   //RUNRUNRUNRUNRUNRUN
			}                                                                          //RUNRUNRUNRUNRUNRUN
			numForRunIter++;                                                           //RUNRUNRUNRUNRUNRUN

			scoreText.offset.set(random.float(-5, 5), random.float(-5, 5)); // You already know :)
			scoreBG.offset.set(random.float(-5, 5), random.float(-5, 5));
			FlxTween.cancelTweensOf(bg2);
			FlxTween.tween(bg2, {alpha: 1}, 0.25); // Bobscreen

			chromeValue = 0.005;
			ShadersHandler.setChrome(random.float(-0.005, 0.005), random.float(-0.005, 0.005),
			                         random.float(-0.005, 0.005), random.float(-0.005, 0.005),
			                         random.float(-0.005, 0.005), random.float(-0.005, 0.005)); // Trying create shader stuff\
		} else {
			for (item in grpSongs.members) item.offset.set(0, 0);
			for (i in 0...iconArray.length) iconArray[i].offset.set(0);

			scoreText.text = "PERSONAL BEST:" + lerpScore;

			numForRunIter = 0; 
			scoreText.offset.set(0, 0);
			scoreBG.offset.set(0, 0);
			FlxTween.cancelTweensOf(bg2);
			FlxTween.tween(bg2, {alpha: 0}, 0.5);

			FlxTween.tween(this, {chromeValue: 0}, 0.5);
			ShadersHandler.setChrome(chromeValue, chromeValue, -chromeValue, -chromeValue, -chromeValue, chromeValue);
		}

		if (songs[curSelected].songName == 'run-original') { // I'm too lazy for linking run-original data and run music :/
			curDifficulty = 1;
			diffText.text = "the chart that acutally";
			diffText2.text = "has 400 notes per secod";
		} else diffText2.text = ""; // *.visible = false - will better...

		if (accepted)
		{
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);

			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = curDifficulty;
			PlayState.storyWeek = songs[curSelected].week;
			trace('CUR WEEK' + PlayState.storyWeek);
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		#end

		switch (curDifficulty)
		{
			case 0:
				diffText.text = "EASY";
			case 1:
				diffText.text = 'NORMAL';
			case 2:
				diffText.text = "HARD";
		}
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		if (songs[curSelected].songName == 'run')
		{
			
		}
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		changeDiff(); // ELabel // For returning diffTitle to normal

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}

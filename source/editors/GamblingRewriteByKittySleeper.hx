package editors;

import openfl.Lib;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;

class GamblingRewriteByKittySleeper extends MusicBeatState {
	var roll:FlxText;
	var quit:FlxText;
	var song:FlxText;
	var canRoll:Bool = true;
	var randomShitFuck:Bool = false;
	var switchTextTime:Bool = true;
	var timeSwitch:Float = 0.1;
    var finalSong:String;

	override public function create() {
		super.create();

		Discord.DiscordClient.changePresence("Gambling", null);
		Lib.application.window.title = "Friday Night Funkin': This GC's Insanity | IM FUCKING GAMBLING";
		FlxG.mouse.visible = true;

		var gambleThing = new FlxSprite().loadGraphic(Paths.image("gamble/gamblelayout"));
		gambleThing.screenCenter();
		add(gambleThing);

		song = new FlxText(175, 300, FlxG.width, "SLOT MACHINE", 65);
		song.color = 0xff000000;
		add(song);

		roll = new FlxText(FlxG.width * 0.7, 185, FlxG.width, "ROLL", 65);
		roll.color = 0xff000000;
		add(roll);

		quit = new FlxText(FlxG.width * 0.7, 450, FlxG.width, "QUIT", 65);
		quit.color = 0xff000000;
		add(quit);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.mouse.overlaps(roll) && FlxG.mouse.justPressed && canRoll) {
			canRoll = false;
			FlxG.sound.play(Paths.sound("gamble"));
			randomShitFuck = true;
            finalSong = FlxG.random.getObject(sys.FileSystem.readDirectory("./assets/data/songData"));
		}

		if (randomShitFuck && switchTextTime) {
			FlxG.sound.play(Paths.sound("scrollMenu"));

			song.text = FlxG.random.getObject(sys.FileSystem.readDirectory("./assets/data/songData"));
			switchTextTime = false;

			new flixel.util.FlxTimer().start(timeSwitch, function(time) {
				if (timeSwitch > 0.19) {
                    song.text = finalSong;
					new flixel.util.FlxTimer().start(0.75, function(time) {
						PlayState.SONG =  Song.loadFromJson(finalSong.toLowerCase(), finalSong.toLowerCase());
						PlayState.isStoryMode = false;
						LoadingState.loadAndSwitchState(new PlayState());	
					});
				} else {
                    switchTextTime = true;
					if (FlxG.random.bool(65))
						timeSwitch += 0.0015;
                } 
			});
		}

		if (FlxG.mouse.overlaps(quit) && FlxG.mouse.justPressed)
			FlxG.switchState(new MainMenuState());
	}
}
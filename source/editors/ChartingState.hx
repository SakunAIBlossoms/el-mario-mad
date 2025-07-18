package editors;

#if desktop
import Discord.DiscordClient;
#end
import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import haxe.format.JsonParser;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
import lime.utils.Assets;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.ByteArray;

using StringTools;
#if MODS_ALLOWED
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;
#end


class ChartingState extends MusicBeatState
{
	public static var noteTypeList:Array<String> = //Used for backwards compatibility with 0.1 - 0.3.2 charts, though, you should add your hardcoded custom note types here too.
	[
		'',
		'Alt Animation',
		'Hey!',
		'Hurt Note',
		'GF Sing',
		'No Animation',
		'Nota veneno',
		'Nota boo',
		'Nota bomba',
		'Bullet',
		'Coin Note',
		'Yoshi Note',
		'AS Bud Note',
		'Ring Note',
		'GF Duet',
		'jumpscareM',
		'Water Note',
		'Bullet Bill',
		'Bullet2',
		'Bad Poison'
	];
	private var noteTypeIntMap:Map<Int, String> = new Map<Int, String>();
	private var noteTypeMap:Map<String, Null<Int>> = new Map<String, Null<Int>>();

	var eventStuff:Array<Dynamic> =
	[
		['', "Nothing. Yep, that's right."],
		['Show Song', ""],
		['Add Camera Zoom', "Used on MILF on that one \"hard\" part\nValue 1: Camera zoom add (Default: 0.015)\nValue 2: UI zoom add (Default: 0.03)\nLeave the values blank if you want to use Default."],
		['Camera Zoom Chain', "Value 1: Camera Zoom Values (0.015, 0.03)\n(also you can add another two values to make it\nzoom screen shake(0.015, 0.03, 0.01, 0.01))\n\nValue 2: Total Amount of Beat Cam Zooms and\nthe space with eachother (4, 1)"],
		['Play Animation', "Plays an animation on a Character,\nonce the animation is completed,\nthe animation changes to Idle\n\nValue 1: Animation to play.\nValue 2: Character (Dad, BF, GF)"],
		['Camera Follow Pos', "Value 1: X\nValue 2: Y\n\nThe camera won't change the follow point\nafter using this, for getting it back\nto normal, leave both values blank."],
		['Alt Idle Animation', "Sets a speciied suffix after the idle animation name.\nYou can use this to trigger 'idle-alt' if you set\nValue 2 to -alt\n\nValue 1: Character to set (Dad, BF or GF)\nValue 2: New suffix (Leave it blank to disable)"],
		['Screen Shake', "Value 1: Camera shake\nValue 2: HUD shake\n\nEvery value works as the following example: \"1, 0.05\".\nThe first number (1) is the duration.\nThe second number (0.05) is the intensity."],
		['Screen Shake Chain', "Value 1: Screen Shake Values (0.003, 0.0015)\n\nValue 2: Total Amount of Screen Shake per beat]"],
		['Change Character', "Value 1: Character to change (BF: 0, Dad: 1, GF: 2)\nValue 2: New character's name"],
		['Set Cam Zoom', "Value 1: "],
		['Set Cam Pos', ""],
		['Change Window Title', 'Value 1 is the new title\n\nValue 2 is the reset.\nSet it to 0 to change the name,\nset it to 1 to reset the name to default'],
		['Ocultar HUD', "oculta el HUD del juego (duh).\nValue 1: Alternar entre ocultar y mostrar\n(pon 0 para ocultar el HUD y pon 1 para mostrarlo)"],
		['Char Attack', "Only Works on Powerdown and Last Course"],
		['Write DS', "value1: 0 para mostrar 1 para sacar\nvalue2: texto si vas a mostrar"],
		['Sacar Lava', "Utilizado en I Hate You\nValue 1: cambiar coordenada Y (default 716)\n(dejarlo en blanco lo ocultará)\n\n(SOLO FUNCIONA EN EL ESCENARIO DE\nIHY, USARLO EN OTRO ESCENARIO CRASHEA)"],
		['Timebar Gimmick', ""],
		['Add Subtitle', ""],
		['ycbu text', ""],
		['Triggers Universal', 'refer to songevents.txt for\nindividual song events and their\nassociated values'],
	];

	var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	public static var curSection:Int = 0;
	public static var lastSection:Int = 0;
	private static var lastSong:String = '';

	var bpmTxt:FlxText;

	var camPos:FlxObject;
	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	public static var GRID_SIZE:Int = 40;
	var CAM_OFFSET:Int = 360;

	var dummyArrow:FlxSprite;

	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedNoteType:FlxTypedGroup<FlxText>;

	var nextRenderedSustains:FlxTypedGroup<FlxSprite>;
	var nextRenderedNotes:FlxTypedGroup<Note>;

	var gridBG:FlxSprite;
	var gridMult:Int = 2;

	var _song:SwagSong;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	var vocals:FlxSound = null;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var value1InputText:FlxUIInputText;
	var value2InputText:FlxUIInputText;
	var currentSongName:String;
	
	var zoomTxt:FlxText;
	var curZoom:Int = 1;

	#if !html5
	var zoomList:Array<Float> = [
		0.5,
		1,
		2,
		4,
		8,
		12,
		16,
		24
	];
	#else //The grid gets all black when over 1/12 snap
	var zoomList:Array<Float> = [
		0.5,
		1,
		2,
		4,
		8,
		12
	];
	#end

	private var blockPressWhileTypingOn:Array<FlxUIInputText> = [];
	private var blockPressWhileScrolling:Array<FlxUIDropDownMenuCustom> = [];

	var waveformSprite:FlxSprite;
	var gridLayer:FlxTypedGroup<FlxSprite>;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Chart Editor", StringTools.replace(PlayState.SONG.song, '-', ' '));
		#end

			if(Lib.application.window.width == 800 && Lib.application.window.height == 600){
				Lib.application.window.move(Lib.application.window.x - 240, Lib.application.window.y - 60);
				Lib.application.window.resize(1280, 720);
			}
			else if(Lib.application.window.width == 512 && Lib.application.window.height == 768)
			{
				Lib.application.window.resize(1280, 720);
				Lib.application.window.move(PlayState.ogwinX, PlayState.ogwinY);
			}

			Lib.current.scaleX = 1;
			Lib.current.scaleY = 1;

			if(PlayState.curStage == 'virtual'){
				Lib.application.window.resize(1280, 720);
				CppAPI.setWallpaper('old');
			}

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.set();
		bg.color = 0xFF222222;
		add(bg);

		gridLayer = new FlxTypedGroup<FlxSprite>();
		add(gridLayer);

		waveformSprite = new FlxSprite(GRID_SIZE, 0).makeGraphic(FlxG.width, FlxG.height, 0x00FFFFFF);
		add(waveformSprite);

		var eventIcon:FlxSprite = new FlxSprite(-GRID_SIZE - 5, -90).loadGraphic(Paths.image('eventArrow'));
		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		eventIcon.scrollFactor.set(1, 1);
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		eventIcon.setGraphicSize(30, 30);
		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(eventIcon);
		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(GRID_SIZE + 10, -100);
		rightIcon.setPosition(GRID_SIZE * 5.2, -100);

		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedNoteType = new FlxTypedGroup<FlxText>();

		nextRenderedSustains = new FlxTypedGroup<FlxSprite>();
		nextRenderedNotes = new FlxTypedGroup<Note>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150.0,
				needsVoices: true,
				arrowSkin: '',
				splashSkin: '',
				player1: 'bf',
				player2: 'dad',
				player3: 'gf',
				speed: 1,
				stage: 'stage',
				validScore: false
			};
		}
		
		if(curSection >= _song.notes.length) curSection = _song.notes.length - 1;

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		currentSongName = Paths.formatToSongPath(_song.song);
		loadAudioBuffer();
		reloadGridLayer();
		loadSong();
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 50, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(GRID_SIZE * 9), 4);
		add(strumLine);

		camPos = new FlxObject(0, 0, 1, 1);
		camPos.setPosition(strumLine.x + CAM_OFFSET, strumLine.y);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
			{name: "Events", label: 'Events'},
			{name: "Charting", label: 'Charting'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 + GRID_SIZE / 2;
		UI_box.y = 25;

		var text:String =
		"W/S or Mouse Wheel - Change Conductor's strum time
		\nA or Left/D or Right - Go to the previous/next section
		\nHold Shift to move 4x faster
		\nHold Control and click on an arrow to select it
		\nZ/X - Zoom in/out
		\n
		\nEsc - Test your chart inside Chart Editor
		\nEnter - Play your chart
		\nQ/E - Decrease/Increase Note Sustain Length
		\nSpace - Stop/Resume song";

		var tipTextArray:Array<String> = text.split('\n');
		for (i in 0...tipTextArray.length) {
			var tipText:FlxText = new FlxText(UI_box.x, UI_box.y + UI_box.height + 8, 0, tipTextArray[i], 16);
			tipText.y += i * 14;
			tipText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
			//tipText.borderSize = 2;
			tipText.scrollFactor.set();
			add(tipText);
		}
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addEventsUI();
		addChartingUI();
		updateHeads();
		updateWaveform();
		UI_box.selected_tab = 4;

		add(curRenderedSustains);
		add(curRenderedNotes);
		add(curRenderedNoteType);
		add(nextRenderedSustains);
		add(nextRenderedNotes);

		if(lastSong != currentSongName) {
			changeSection();
		}
		lastSong = currentSongName;

		zoomTxt = new FlxText(10, 10, 0, "Zoom: 1x", 16);
		zoomTxt.scrollFactor.set();
		add(zoomTxt);
		
		updateGrid();
		super.create();
	}

	var check_mute_inst:FlxUICheckBox = null;
	var playSoundBf:FlxUICheckBox = null;
	var playSoundDad:FlxUICheckBox = null;
	var UI_songTitle:FlxUIInputText;
	var noteSkinInputText:FlxUIInputText;
	var noteSplashesInputText:FlxUIInputText;
	var stageDropDown:FlxUIDropDownMenuCustom;
	function addSongUI():Void
	{
		UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		blockPressWhileTypingOn.push(UI_songTitle);
		
		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + 90, saveButton.y, "Reload Audio", function()
		{
			currentSongName = Paths.formatToSongPath(UI_songTitle.text);
			loadSong();
			loadAudioBuffer();
			updateWaveform();
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'Load Autosave', function()
		{
			PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
			MusicBeatState.resetState();
		});

		var loadEventJson:FlxButton = new FlxButton(loadAutosaveBtn.x, loadAutosaveBtn.y + 30, 'Load Events', function()
		{
			var songName:String = Paths.formatToSongPath(_song.song);
			var file:String = Paths.json('songData/' + songName + '/events');
			#if sys
			if (#if MODS_ALLOWED FileSystem.exists(Paths.modsJson(songName + '/events')) || #end FileSystem.exists(file))
			#else
			if (OpenFlAssets.exists(file))
			#end
			{
				clearEvents();
				var events:SwagSong = Song.loadFromJson('events', songName);
				for (sec in 0...events.notes.length) {
					for (noteId in 0...events.notes[sec].sectionNotes.length) {
						var note:Array<Dynamic> = events.notes[sec].sectionNotes[noteId];
						if(note != null && note[1] < 0) {
							_song.notes[sec].sectionNotes.push([note[0], note[1], note[2], note[3], note[4]]);
						}
					}
				}
				changeSection(curSection);
			}
		});

		var saveEvents:FlxButton = new FlxButton(110, reloadSongJson.y, 'Save Events', function ()
		{
			saveEvents();
		});

		var clear_events:FlxButton = new FlxButton(320, 310, 'Clear events', function()
			{
				clearEvents();
			});
		var clear_notes:FlxButton = new FlxButton(320, clear_events.y + 30, 'Clear notes', function()
			{
				for (sec in 0..._song.notes.length) {
					var count:Int = 0;
					while(count < _song.notes[sec].sectionNotes.length) {
						var note:Array<Dynamic> = _song.notes[sec].sectionNotes[count];
						if(note != null && note[1] > -1) {
							_song.notes[sec].sectionNotes.remove(note);
						} else {
							count++;
						}
					}
				}
				updateGrid();
			});

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 70, 1, 1, 1, 339, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, stepperBPM.y + 35, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		#if MODS_ALLOWED
		var directories:Array<String> = [Paths.mods('characters/'), Paths.mods(Paths.currentModDirectory + '/characters/'), Paths.getPreloadPath('characters/')];
		#else
		var directories:Array<String> = [Paths.getPreloadPath('characters/')];
		#end

		var tempMap:Map<String, Bool> = new Map<String, Bool>();
		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		for (i in 0...characters.length) {
			tempMap.set(characters[i], true);
		}

		#if MODS_ALLOWED
		for (i in 0...directories.length) {
			var directory:String = directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json')) {
						var charToCheck:String = file.substr(0, file.length - 5);
						if(!charToCheck.endsWith('-dead') && !tempMap.exists(charToCheck)) {
							tempMap.set(charToCheck, true);
							characters.push(charToCheck);
						}
					}
				}
			}
		}
		#end

		var player1DropDown = new FlxUIDropDownMenuCustom(10, stepperSpeed.y + 45, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player1 = characters[Std.parseInt(character)];
			updateHeads();
		});
		player1DropDown.selectedLabel = _song.player1;
		blockPressWhileScrolling.push(player1DropDown);

		var player3DropDown = new FlxUIDropDownMenuCustom(player1DropDown.x, player1DropDown.y + 40, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player3 = characters[Std.parseInt(character)];
			updateHeads();
		});
		player3DropDown.selectedLabel = _song.player3;
		blockPressWhileScrolling.push(player3DropDown);

		var player2DropDown = new FlxUIDropDownMenuCustom(player1DropDown.x, player3DropDown.y + 40, FlxUIDropDownMenuCustom.makeStrIdLabelArray(characters, true), function(character:String)
		{
			_song.player2 = characters[Std.parseInt(character)];
			updateHeads();
		});
		player2DropDown.selectedLabel = _song.player2;
		blockPressWhileScrolling.push(player2DropDown);

		#if MODS_ALLOWED
		var directories:Array<String> = [Paths.mods('stages/'), Paths.mods(Paths.currentModDirectory + '/stages/'), Paths.getPreloadPath('stages/')];
		#else
		var directories:Array<String> = [Paths.getPreloadPath('stages/')];
		#end

		tempMap.clear();
		var stageFile:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
		var stages:Array<String> = [];
		for (i in 0...stageFile.length) { //Prevent duplicates
			var stageToCheck:String = stageFile[i];
			if(!tempMap.exists(stageToCheck)) {
				stages.push(stageToCheck);
			}
			tempMap.set(stageToCheck, true);
		}
		#if MODS_ALLOWED
		for (i in 0...directories.length) {
			var directory:String = directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.json')) {
						var stageToCheck:String = file.substr(0, file.length - 5);
						if(!tempMap.exists(stageToCheck)) {
							tempMap.set(stageToCheck, true);
							stages.push(stageToCheck);
						}
					}
				}
			}
		}
		#end

		if(stages.length < 1) stages.push('stage');

		stageDropDown = new FlxUIDropDownMenuCustom(player1DropDown.x + 140, player1DropDown.y, FlxUIDropDownMenuCustom.makeStrIdLabelArray(stages, true), function(character:String)
		{
			_song.stage = stages[Std.parseInt(character)];
		});
		stageDropDown.selectedLabel = _song.stage;
		blockPressWhileScrolling.push(stageDropDown);

		var skin = PlayState.SONG.arrowSkin;
		if(skin == null) skin = '';
		noteSkinInputText = new FlxUIInputText(player2DropDown.x, player2DropDown.y + 50, 150, skin, 8);
		blockPressWhileTypingOn.push(noteSkinInputText);
	
		noteSplashesInputText = new FlxUIInputText(noteSkinInputText.x, noteSkinInputText.y + 35, 150, _song.splashSkin, 8);
		blockPressWhileTypingOn.push(noteSplashesInputText);

		var reloadNotesButton:FlxButton = new FlxButton(noteSplashesInputText.x + 5, noteSplashesInputText.y + 20, 'Change Notes', function() {
			_song.arrowSkin = noteSkinInputText.text;
			updateGrid();
		});

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(clear_events);
		tab_group_song.add(clear_notes);
		tab_group_song.add(saveButton);
		tab_group_song.add(saveEvents);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(loadEventJson);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(reloadNotesButton);
		tab_group_song.add(noteSkinInputText);
		tab_group_song.add(noteSplashesInputText);
		tab_group_song.add(new FlxText(stepperBPM.x, stepperBPM.y - 15, 0, 'Song BPM:'));
		tab_group_song.add(new FlxText(stepperSpeed.x, stepperSpeed.y - 15, 0, 'Song Speed:'));
		tab_group_song.add(new FlxText(player2DropDown.x, player2DropDown.y - 15, 0, 'Opponent:'));
		tab_group_song.add(new FlxText(player3DropDown.x, player3DropDown.y - 15, 0, 'Girlfriend:'));
		tab_group_song.add(new FlxText(player1DropDown.x, player1DropDown.y - 15, 0, 'Boyfriend:'));
		tab_group_song.add(new FlxText(stageDropDown.x, stageDropDown.y - 15, 0, 'Stage:'));
		tab_group_song.add(new FlxText(noteSkinInputText.x, noteSkinInputText.y - 15, 0, 'Note Texture:'));
		tab_group_song.add(new FlxText(noteSplashesInputText.x, noteSplashesInputText.y - 15, 0, 'Note Splashes Texture:'));
		tab_group_song.add(player2DropDown);
		tab_group_song.add(player3DropDown);
		tab_group_song.add(player1DropDown);
		tab_group_song.add(stageDropDown);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(camPos);
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	var sectionToCopy:Int = 0;
	var notesCopied:Array<Dynamic>;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = 'section_length';

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = _song.notes[curSection].mustHitSection;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 60, null, null, "Alt Animation", 100);
		check_altAnim.checked = _song.notes[curSection].altAnim;
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 90, null, null, 'Change BPM', 100);
		check_changeBPM.checked = _song.notes[curSection].changeBPM;
		check_changeBPM.name = 'check_changeBPM';

		stepperSectionBPM = new FlxUINumericStepper(10, 110, 1, Conductor.bpm, 0, 999, 1);
		if(check_changeBPM.checked) {
			stepperSectionBPM.value = _song.notes[curSection].bpm;
		} else {
			stepperSectionBPM.value = Conductor.bpm;
		}
		stepperSectionBPM.name = 'section_bpm';


		var copyButton:FlxButton = new FlxButton(10, 150, "Copy Section", function()
		{
			notesCopied = [];
			sectionToCopy = curSection;
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note:Array<Dynamic> = _song.notes[curSection].sectionNotes[i];
				notesCopied.push(note);
			}
		});

		var pasteButton:FlxButton = new FlxButton(10, 180, "Paste Section", function()
		{
			var addToTime:Float = Conductor.stepCrochet * (_song.notes[curSection].lengthInSteps * (curSection - sectionToCopy));
			trace('Time to add: ' + addToTime);

			for (note in notesCopied)
			{
				var copiedNote:Array<Dynamic> = [];
				if(note[4] != null) {
					copiedNote = [note[0] + addToTime, note[1], note[2], note[3], note[4]];
				} else {
					copiedNote = [note[0] + addToTime, note[1], note[2], note[3]];
				}
				_song.notes[curSection].sectionNotes.push(copiedNote);
			}
			updateGrid();
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 210, "Clear", function()
		{
			_song.notes[curSection].sectionNotes = [];
			updateGrid();
		});

		var swapSection:FlxButton = new FlxButton(10, 240, "Swap section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note:Array<Dynamic> = _song.notes[curSection].sectionNotes[i];
				if(note[1] > -1) {
					note[1] = (note[1] + 4) % 8;
					_song.notes[curSection].sectionNotes[i] = note;
				}
			}
			updateGrid();
		});

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 276, 1, 1, -999, 999, 0);

		var copyLastButton:FlxButton = new FlxButton(10, 270, "Copy last section", function()
		{
			var value:Int = Std.int(stepperCopy.value);
			var daSec = FlxMath.maxInt(curSection, value);

			for (note in _song.notes[daSec - value].sectionNotes)
			{
				var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * value);

				var copiedNote:Array<Dynamic> = [strum, note[1], note[2], note[3]];
				if(note[1] < 0) {
					copiedNote = [strum, note[1], note[2], note[3], note[4]];
				}
				_song.notes[daSec].sectionNotes.push(copiedNote);
			}
			updateGrid();
		});
		copyLastButton.setGraphicSize(80, 30);
		copyLastButton.updateHitbox();

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(pasteButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(copyLastButton);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;
	var strumTimeInputText:FlxUIInputText; //I wanted to use a stepper but we can't scale these as far as i know :(
	var noteTypeDropDown:FlxUIDropDownMenuCustom;
	var currentType:Int = 0;

	function addNoteUI():Void
	{
		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 25, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 32);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		strumTimeInputText = new FlxUIInputText(10, 65, 180, "0");
		tab_group_note.add(strumTimeInputText);
		blockPressWhileTypingOn.push(strumTimeInputText);

		var key:Int = 0;
		var displayNameList:Array<String> = [];
		while (key < noteTypeList.length) {
			displayNameList.push(noteTypeList[key]);
			noteTypeMap.set(noteTypeList[key], key);
			noteTypeIntMap.set(key, noteTypeList[key]);
			key++;
		}

		#if LUA_ALLOWED
		var directories:Array<String> = [Paths.mods('custom_notetypes/'), Paths.mods(Paths.currentModDirectory + '/custom_notetypes/')];
		for (i in 0...directories.length) {
			var directory:String =  directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file.endsWith('.lua')) {
						var fileToCheck:String = file.substr(0, file.length - 4);
						if(!noteTypeMap.exists(fileToCheck)) {
							displayNameList.push(fileToCheck);
							noteTypeMap.set(fileToCheck, key);
							noteTypeIntMap.set(key, fileToCheck);
							key++;
						}
					}
				}
			}
		}
		#end

		for (i in 1...displayNameList.length) {
			displayNameList[i] = i + '. ' + displayNameList[i];
		}

		noteTypeDropDown = new FlxUIDropDownMenuCustom(10, 105, FlxUIDropDownMenuCustom.makeStrIdLabelArray(displayNameList, true), function(character:String)
		{
			currentType = Std.parseInt(character);
			if(curSelectedNote != null && curSelectedNote[1] > -1) {
				curSelectedNote[3] = noteTypeIntMap.get(currentType);
				updateGrid();
			}
		});
		blockPressWhileScrolling.push(noteTypeDropDown);

		tab_group_note.add(new FlxText(10, 10, 0, 'Sustain length:'));
		tab_group_note.add(new FlxText(10, 50, 0, 'Strum time (in miliseconds):'));
		tab_group_note.add(new FlxText(10, 90, 0, 'Note type:'));
		tab_group_note.add(stepperSusLength);
		tab_group_note.add(strumTimeInputText);
		tab_group_note.add(noteTypeDropDown);

		UI_box.addGroup(tab_group_note);
	}

	var eventDropDown:FlxUIDropDownMenuCustom;
	var descText:FlxText;
	function addEventsUI():Void
	{
		var tab_group_event = new FlxUI(null, UI_box);
		tab_group_event.name = 'Events';

		#if LUA_ALLOWED
		var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();
		var directories:Array<String> = [Paths.mods('custom_events/'), Paths.mods(Paths.currentModDirectory + '/custom_events/')];
		for (i in 0...directories.length) {
			var directory:String =  directories[i];
			if(FileSystem.exists(directory)) {
				for (file in FileSystem.readDirectory(directory)) {
					var path = haxe.io.Path.join([directory, file]);
					if (!FileSystem.isDirectory(path) && file != 'readme.txt' && file.endsWith('.txt')) {
						var fileToCheck:String = file.substr(0, file.length - 4);
						if(!eventPushedMap.exists(fileToCheck)) {
							eventPushedMap.set(fileToCheck, true);
							eventStuff.push([fileToCheck, File.getContent(path)]);
						}
					}
				}
			}
		}
		eventPushedMap.clear();
		eventPushedMap = null;
		#end

		descText = new FlxText(20, 200, 0, eventStuff[0][0]);

		var leEvents:Array<String> = [];
		for (i in 0...eventStuff.length) {
			leEvents.push(eventStuff[i][0]);
		}

		var text:FlxText = new FlxText(20, 30, 0, "Event:");
		tab_group_event.add(text);
		eventDropDown = new FlxUIDropDownMenuCustom(20, 50, FlxUIDropDownMenuCustom.makeStrIdLabelArray(leEvents, true), function(pressed:String) {
			var selectedEvent:Int = Std.parseInt(pressed);
			descText.text = eventStuff[selectedEvent][1];
			if(curSelectedNote != null) {
				curSelectedNote[2] = eventStuff[selectedEvent][0];
				updateGrid();
			}
		});
		blockPressWhileScrolling.push(eventDropDown);

		var text:FlxText = new FlxText(20, 90, 0, "Value 1:");
		tab_group_event.add(text);
		value1InputText = new FlxUIInputText(20, 110, 100, "");
		blockPressWhileTypingOn.push(value1InputText);

		var text:FlxText = new FlxText(20, 130, 0, "Value 2:");
		tab_group_event.add(text);
		value2InputText = new FlxUIInputText(20, 150, 100, "");
		blockPressWhileTypingOn.push(value2InputText);

		tab_group_event.add(descText);
		tab_group_event.add(value1InputText);
		tab_group_event.add(value2InputText);
		tab_group_event.add(eventDropDown);

		UI_box.addGroup(tab_group_event);
	}

	var metronome:FlxUICheckBox;
	var metronomeStepper:FlxUINumericStepper;
	var metronomeOffsetStepper:FlxUINumericStepper;
	var disableAutoScrolling:FlxUICheckBox;
	#if desktop
	var waveformEnabled:FlxUICheckBox;
	var waveformUseInstrumental:FlxUICheckBox;
	#end
	var instVolume:FlxUINumericStepper;
	var voicesVolume:FlxUINumericStepper;
	function addChartingUI() {
		var tab_group_chart = new FlxUI(null, UI_box);
		tab_group_chart.name = 'Charting';
		
		#if desktop
		waveformEnabled = new FlxUICheckBox(10, 90, null, null, "Visible Waveform", 100);
		waveformEnabled.checked = false;
		waveformEnabled.callback = function()
		{
			updateWaveform();
		};

		waveformUseInstrumental = new FlxUICheckBox(waveformEnabled.x + 120, waveformEnabled.y, null, null, "Waveform for Instrumental", 100);
		waveformUseInstrumental.checked = false;
		waveformUseInstrumental.callback = function()
		{
			updateWaveform();
		};
		#end

		check_mute_inst = new FlxUICheckBox(10, 310, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var check_mute_vocals = new FlxUICheckBox(check_mute_inst.x + 120, check_mute_inst.y, null, null, "Mute Vocals (in editor)", 100);
		check_mute_vocals.checked = false;
		check_mute_vocals.callback = function()
		{
			if(vocals != null) {
				var vol:Float = 1;

				if (check_mute_vocals.checked)
					vol = 0;

				vocals.volume = vol;
			}
		};

		playSoundBf = new FlxUICheckBox(check_mute_inst.x, check_mute_vocals.y + 30, null, null, 'Play Sound (Boyfriend notes)', 100);
		playSoundBf.checked = false;
		playSoundDad = new FlxUICheckBox(check_mute_inst.x + 120, playSoundBf.y, null, null, 'Play Sound (Opponent notes)', 100);
		playSoundDad.checked = false;

		metronome = new FlxUICheckBox(10, 15, null, null, "Metronome Enabled", 100);
		metronomeStepper = new FlxUINumericStepper(15, 55, 5, _song.bpm, 1, 1500, 1);
		metronomeOffsetStepper = new FlxUINumericStepper(metronomeStepper.x + 100, metronomeStepper.y, 25, 0, 0, 1000, 1);
		
		disableAutoScrolling = new FlxUICheckBox(metronome.x + 120, metronome.y, null, null, "Disable Autoscroll (Not Recommended)", 120);

		instVolume = new FlxUINumericStepper(metronomeStepper.x, 270, 0.1, 1, 0, 1, 1);
		instVolume.value = FlxG.sound.music.volume;
		instVolume.name = 'inst_volume';
		voicesVolume = new FlxUINumericStepper(instVolume.x + 100, instVolume.y, 0.1, 1, 0, 1, 1);
		voicesVolume.value = vocals.volume;
		voicesVolume.name = 'voices_volume';

		tab_group_chart.add(new FlxText(metronomeStepper.x, metronomeStepper.y - 15, 0, 'BPM:'));
		tab_group_chart.add(new FlxText(metronomeOffsetStepper.x, metronomeOffsetStepper.y - 15, 0, 'Offset (ms):'));
		tab_group_chart.add(new FlxText(instVolume.x, instVolume.y - 15, 0, 'Inst Volume'));
		tab_group_chart.add(new FlxText(voicesVolume.x, voicesVolume.y - 15, 0, 'Voices Volume'));
		tab_group_chart.add(metronome);
		tab_group_chart.add(disableAutoScrolling);
		tab_group_chart.add(metronomeStepper);
		tab_group_chart.add(metronomeOffsetStepper);
		#if desktop
		tab_group_chart.add(waveformEnabled);
		tab_group_chart.add(waveformUseInstrumental);
		#end
		tab_group_chart.add(instVolume);
		tab_group_chart.add(voicesVolume);
		tab_group_chart.add(check_mute_inst);
		tab_group_chart.add(check_mute_vocals);
		tab_group_chart.add(playSoundBf);
		tab_group_chart.add(playSoundDad);
		UI_box.addGroup(tab_group_chart);
	}

	function loadSong():Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		var file:Dynamic = Paths.voices(currentSongName);
		vocals = new FlxSound();
		if (Std.isOfType(file, Sound) || OpenFlAssets.exists(file)) {
			vocals.loadEmbedded(file);
			FlxG.sound.list.add(vocals);
		}
		generateSong();
		FlxG.sound.music.pause();
		Conductor.songPosition = sectionStartTime();
		FlxG.sound.music.time = Conductor.songPosition;
	}

	function generateSong() {
		FlxG.sound.playMusic(Paths.inst(currentSongName), 0.6, false);
		if (instVolume != null) FlxG.sound.music.volume = instVolume.value;
		if (check_mute_inst != null && check_mute_inst.checked) FlxG.sound.music.volume = 0;

		FlxG.sound.music.onComplete = function()
		{
			generateSong();
			FlxG.sound.music.pause();
			Conductor.songPosition = 0;
			if(vocals != null) {
				vocals.play();
				vocals.pause();
				vocals.time = 0;
			}
			changeSection();
			curSection = 0;
			updateGrid();
			updateSectionUI();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateGrid();
					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alt Animation":
					_song.notes[curSection].altAnim = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				tempBpm = nums.value;
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(nums.value);
			}
			else if (wname == 'note_susLength')
			{
				if(curSelectedNote != null && curSelectedNote[1] > -1) {
					curSelectedNote[2] = nums.value;
					updateGrid();
				} else {
					sender.value = 0;
				}
			}
			else if (wname == 'section_bpm')
			{
				_song.notes[curSection].bpm = nums.value;
				updateGrid();
			}
			else if (wname == 'inst_volume')
			{
				FlxG.sound.music.volume = nums.value;
			}
			else if (wname == 'voices_volume')
			{
				vocals.volume = nums.value;
			}
		}
		else if(id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText)) {
			if(sender == noteSplashesInputText) {
				_song.splashSkin = noteSplashesInputText.text;
			}
			else if(curSelectedNote != null)
			{
				if(sender == value1InputText) {
					curSelectedNote[3] = value1InputText.text;
					updateGrid();
				}
				else if(sender == value2InputText) {
					curSelectedNote[4] = value2InputText.text;
					updateGrid();
				}
				else if(sender == strumTimeInputText) {
					var value:Float = Std.parseFloat(strumTimeInputText.text);
					if(Math.isNaN(value)) value = 0;
					curSelectedNote[0] = value;
					updateGrid();
				}
			}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function sectionStartTime(add:Int = 0):Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection + add)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	var lastConductorPos:Float;
	var colorSine:Float = 0;
	override function update(elapsed:Float)
	{
		curStep = recalculateSteps();

		if(FlxG.sound.music.time < 0) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		}
		else if(FlxG.sound.music.time > FlxG.sound.music.length) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = UI_songTitle.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) / zoomList[curZoom] % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
		camPos.y = strumLine.y;

		if(!disableAutoScrolling.checked) {
			if (strumLine.y > (gridBG.height / 2))
			{
				trace(curStep);
				trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
				trace('DUMBSHIT');

				if (_song.notes[curSection + 1] == null)
				{
					addSection();
				}

				changeSection(curSection + 1, false);
			} else if(strumLine.y < -10) {
				changeSection(curSection - 1, false);
			}
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps) * zoomList[curZoom])
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}

		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps) * zoomList[curZoom])
		{
			dummyArrow.x = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn) {
			if(inputText.hasFocus) {
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}
		if(!blockInput) {
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
			for (dropDownMenu in blockPressWhileScrolling) {
				if(dropDownMenu.dropPanel.visible) {
					blockInput = true;
					break;
				}
			}
		}

		if (!blockInput)
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				autosaveSong();
				LoadingState.loadAndSwitchState(new editors.EditorPlayState(sectionStartTime()));
			}
			if (FlxG.keys.justPressed.ENTER)
			{
				autosaveSong();
				FlxG.mouse.visible = false;
				PlayState.SONG = _song;
				FlxG.sound.music.stop();
				if(vocals != null) vocals.stop();

				//if(_song.stage == null) _song.stage = stageDropDown.selectedLabel;
				StageData.loadDirectory(_song);
				LoadingState.loadAndSwitchState(new PlayState());
			}

			if(curSelectedNote != null && curSelectedNote[1] > -1) {
				if (FlxG.keys.justPressed.E)
				{
					changeNoteSustain(Conductor.stepCrochet);
				}
				if (FlxG.keys.justPressed.Q)
				{
					changeNoteSustain(-Conductor.stepCrochet);
				}
			}

			if(FlxG.keys.justPressed.Z && curZoom > 0) {
				--curZoom;
				updateZoom();
			}
			if(FlxG.keys.justPressed.X && curZoom < zoomList.length-1) {
				curZoom++;
				updateZoom();
			}

			if (FlxG.keys.justPressed.TAB)
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					UI_box.selected_tab -= 1;
					if (UI_box.selected_tab < 0)
						UI_box.selected_tab = 2;
				}
				else
				{
					UI_box.selected_tab += 1;
					if (UI_box.selected_tab >= 3)
						UI_box.selected_tab = 0;
				}
			}

			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					if(vocals != null) vocals.pause();
				}
				else
				{
					if(vocals != null) {
						vocals.play();
						vocals.pause();
						vocals.time = FlxG.sound.music.time;
						vocals.play();
					}
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				if(vocals != null) {
					vocals.pause();
					vocals.time = FlxG.sound.music.time;
				}
			}

			if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
			{
				FlxG.sound.music.pause();

				var holdingShift:Float = 1;
				if (FlxG.keys.pressed.CONTROL) holdingShift = 0.25;
				else if (FlxG.keys.pressed.SHIFT) holdingShift = 4;

				var daTime:Float = 700 * FlxG.elapsed * holdingShift;

				if (FlxG.keys.pressed.W)
				{
					FlxG.sound.music.time -= daTime;
				}
				else
					FlxG.sound.music.time += daTime;

				if(vocals != null) {
					vocals.pause();
					vocals.time = FlxG.sound.music.time;
				}
			}

			var shiftThing:Int = 1;
			if (FlxG.keys.pressed.SHIFT)
				shiftThing = 4;

			if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
				changeSection(curSection + shiftThing);
			if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A) {
				if(curSection <= 0) {
					changeSection(_song.notes.length-1);
				} else {
					changeSection(curSection - shiftThing);
				}
			}
		} else if (FlxG.keys.justPressed.ENTER) {
			for (i in 0...blockPressWhileTypingOn.length) {
				if(blockPressWhileTypingOn[i].hasFocus) {
					blockPressWhileTypingOn[i].hasFocus = false;
				}
			}
		}

		_song.bpm = tempBpm;

		if(FlxG.sound.music.time < 0) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		}
		else if(FlxG.sound.music.time > FlxG.sound.music.length) {
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime()) / zoomList[curZoom] % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
		camPos.y = strumLine.y;

		bpmTxt.text = 
		Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2)) + " / " + Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2)) +
		"\nSection: " + curSection +
		"\n\nBeat: " + curBeat +
		"\n\nStep: " + curStep;

		var playedSound:Array<Bool> = [false, false, false, false]; //Prevents earrape GF ahegao sounds
		curRenderedNotes.forEachAlive(function(note:Note) {
			note.alpha = 1;
			#if !html5 //Fixes issues where notes would disappear while a note is selected
			if(curSelectedNote != null) {
				var noteDataToCheck:Int = note.noteData;
				if(noteDataToCheck > -1 && note.mustPress != _song.notes[curSection].mustHitSection) noteDataToCheck += 4;

				if (curSelectedNote[0] == note.strumTime && curSelectedNote[1] == noteDataToCheck)
				{
					colorSine += 180 * elapsed;
					var colorVal:Float = 0.7 + Math.sin((Math.PI * colorSine) / 180) * 0.3;
					note.color = FlxColor.fromRGBFloat(colorVal, colorVal, colorVal, 0.999); //Alpha can't be 100% or the color won't be updated for some reason, guess i will die
				}
			}
			#end

			if(note.strumTime <= Conductor.songPosition) {
				note.alpha = 0.4;
				if(note.strumTime > lastConductorPos && ((playSoundBf.checked && note.mustPress) || (playSoundDad.checked && !note.mustPress)) && FlxG.sound.music.playing && note.noteData > -1) {
					var data:Int = note.noteData % 4;
					if(!playedSound[data]) {
						var soundToPlay = 'ChartingTick';
						if(_song.player1 == 'gf') { //Easter egg
							soundToPlay = 'GF_' + Std.string(data + 1);
						}
						FlxG.sound.play(Paths.sound(soundToPlay));
						playedSound[data] = true;
					}
				}
			}
		});

		if(metronome.checked && lastConductorPos != Conductor.songPosition) {
			var metroInterval:Float = 60 / metronomeStepper.value;
			var metroStep:Int = Math.floor(((Conductor.songPosition + metronomeOffsetStepper.value) / metroInterval) / 1000);
			var lastMetroStep:Int = Math.floor(((lastConductorPos + metronomeOffsetStepper.value) / metroInterval) / 1000);
			if(metroStep != lastMetroStep) {
				FlxG.sound.play(Paths.sound('Metronome_Tick'));
				//trace('Ticked');
			}
		}
		lastConductorPos = Conductor.songPosition;
		super.update(elapsed);
	}

	function updateZoom() {
		zoomTxt.text = 'Zoom: ' + zoomList[curZoom] + 'x';
		reloadGridLayer();
	}

	function loadAudioBuffer() {
		if(audioBuffers[0] != null) {
			audioBuffers[0].dispose();
		}
		audioBuffers[0] = null;
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders('songs/' + currentSongName + '/Inst.ogg'))) {
			audioBuffers[0] = AudioBuffer.fromFile(Paths.modFolders('songs/' + currentSongName + '/Inst.ogg'));
			//trace('Custom vocals found');
		}
		else { #end
			var leVocals:Dynamic = Paths.inst(currentSongName);
			if (!Std.isOfType(leVocals, Sound) && OpenFlAssets.exists(leVocals)) { //Vanilla inst
				audioBuffers[0] = AudioBuffer.fromFile('./' + leVocals.substr(6));
				//trace('Inst found');
			}
		#if MODS_ALLOWED
		}
		#end

		if(audioBuffers[1] != null) {
			audioBuffers[1].dispose();
		}
		audioBuffers[1] = null;
		#if MODS_ALLOWED
		if(FileSystem.exists(Paths.modFolders('songs/' + currentSongName + '/Voices.ogg'))) {
			audioBuffers[1] = AudioBuffer.fromFile(Paths.modFolders('songs/' + currentSongName + '/Voices.ogg'));
			//trace('Custom vocals found');
		} else { #end
			var leVocals:Dynamic = Paths.voices(currentSongName);
			if (!Std.isOfType(leVocals, Sound) && OpenFlAssets.exists(leVocals)) { //Vanilla voices
				audioBuffers[1] = AudioBuffer.fromFile('./' + leVocals.substr(6));
				//trace('Voices found, LETS FUCKING GOOOO');
			}
		#if MODS_ALLOWED
		}
		#end
	}

	function reloadGridLayer() {
		gridLayer.clear();
		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 9, Std.int(GRID_SIZE * 32 * zoomList[curZoom]));
		gridLayer.add(gridBG);

		#if desktop
		if(waveformEnabled != null) {
			updateWaveform();
		}
		#end

		var gridBlack:FlxSprite = new FlxSprite(0, gridBG.height / 2).makeGraphic(Std.int(GRID_SIZE * 9), Std.int(gridBG.height / 2), FlxColor.BLACK);
		gridBlack.alpha = 0.4;
		gridLayer.add(gridBlack);

		var gridBlackLine:FlxSprite = new FlxSprite(gridBG.x + gridBG.width - (GRID_SIZE * 4)).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		gridLayer.add(gridBlackLine);

		gridBlackLine = new FlxSprite(gridBG.x + GRID_SIZE).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		gridLayer.add(gridBlackLine);
		updateGrid();
	}

	var waveformPrinted:Bool = true;
	var audioBuffers:Array<AudioBuffer> = [null, null];
	function updateWaveform() {
		#if desktop
		if(waveformPrinted) {
			waveformSprite.makeGraphic(Std.int(GRID_SIZE * 8), Std.int(gridBG.height), 0x00FFFFFF);
			waveformSprite.pixels.fillRect(new Rectangle(0, 0, gridBG.width, gridBG.height), 0x00FFFFFF);
		}
		waveformPrinted = false;

		var checkForVoices:Int = 1;
		if(waveformUseInstrumental.checked) checkForVoices = 0;

		if(!waveformEnabled.checked || audioBuffers[checkForVoices] == null) {
			//trace('Epic fail on the waveform lol');
			return;
		}

		var sampleMult:Float = audioBuffers[checkForVoices].sampleRate / 44100;
		var index:Int = Std.int(sectionStartTime() * 44.0875 * sampleMult);
		var drawIndex:Int = 0;

		var steps:Int = _song.notes[curSection].lengthInSteps;
		if(Math.isNaN(steps) || steps < 1) steps = 16;
		var samplesPerRow:Int = Std.int(((Conductor.stepCrochet * steps * 1.1 * sampleMult) / 16) / zoomList[curZoom]);
		if(samplesPerRow < 1) samplesPerRow = 1;
		var waveBytes:Bytes = audioBuffers[checkForVoices].data.toBytes();
		
		var min:Float = 0;
		var max:Float = 0;
		while (index < (waveBytes.length - 1))
		{
			var byte:Int = waveBytes.getUInt16(index * 4);

			if (byte > 65535 / 2)
				byte -= 65535;

			var sample:Float = (byte / 65535);

			if (sample > 0)
			{
				if (sample > max)
					max = sample;
			}
			else if (sample < 0)
			{
				if (sample < min)
					min = sample;
			}

			if ((index % samplesPerRow) == 0)
			{
				// trace("min: " + min + ", max: " + max);

				/*if (drawIndex > gridBG.height)
				{
					drawIndex = 0;
				}*/

				var pixelsMin:Float = Math.abs(min * (GRID_SIZE * 8));
				var pixelsMax:Float = max * (GRID_SIZE * 8);
				waveformSprite.pixels.fillRect(new Rectangle(Std.int((GRID_SIZE * 4) - pixelsMin), drawIndex, pixelsMin + pixelsMax, 1), FlxColor.BLUE);
				drawIndex++;

				min = 0;
				max = 0;

				if(drawIndex > gridBG.height) break;
			}

			index++;
		}
		waveformPrinted = true;
		#end
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps(add:Float = 0):Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime + add) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime();

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		if(vocals != null) {
			vocals.pause();
			vocals.time = FlxG.sound.music.time;
		}
		updateCurStep();

		updateGrid();
		updateSectionUI();
		updateWaveform();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime();
				if(vocals != null) {
					vocals.pause();
					vocals.time = FlxG.sound.music.time;
				}
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
		else
		{
			changeSection();
		}
		Conductor.songPosition = FlxG.sound.music.time;
		updateWaveform();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		var healthIconP1:String = loadHealthIconFromCharacter(_song.player1);
		var healthIconP2:String = loadHealthIconFromCharacter(_song.player2);

		if (_song.notes[curSection].mustHitSection)
		{
			leftIcon.changeIcon(healthIconP1);
			rightIcon.changeIcon(healthIconP2);
		}
		else
		{
			leftIcon.changeIcon(healthIconP2);
			rightIcon.changeIcon(healthIconP1);
		}
	}

	function loadHealthIconFromCharacter(char:String) {
		var characterPath:String = 'characters/' + char + '.json';
		#if MODS_ALLOWED
		var path:String = Paths.modFolders(characterPath);
		if (!FileSystem.exists(path)) {
			path = Paths.getPreloadPath(characterPath);
		}

		if (!FileSystem.exists(path))
		#else
		var path:String = Paths.getPreloadPath(characterPath);
		if (!OpenFlAssets.exists(path))
		#end
		{
			path = Paths.getPreloadPath('characters/' + Character.DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
		}

		#if MODS_ALLOWED
		var rawJson = File.getContent(path);
		#else
		var rawJson = OpenFlAssets.getText(path);
		#end

		var json:Character.CharacterFile = cast Json.parse(rawJson);
		return json.healthicon;
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null) {
			if(curSelectedNote[1] > -1) {
				stepperSusLength.value = curSelectedNote[2];
				if(curSelectedNote[3] != null) {
					currentType = noteTypeMap.get(curSelectedNote[3]);
					if(currentType <= 0) {
						noteTypeDropDown.selectedLabel = '';
					} else {
						noteTypeDropDown.selectedLabel = currentType + '. ' + curSelectedNote[3];
					}
				}
			} else {
				eventDropDown.selectedLabel = curSelectedNote[2];
				var selected:Int = Std.parseInt(eventDropDown.selectedId);
				if(selected > 0 && selected < eventStuff.length) {
					descText.text = eventStuff[selected][1];
				}
				value1InputText.text = curSelectedNote[3];
				value2InputText.text = curSelectedNote[4];
			}
			strumTimeInputText.text = curSelectedNote[0];
		}
	}

	function updateGrid():Void
	{
		curRenderedNotes.clear();
		curRenderedSustains.clear();
		curRenderedNoteType.clear();
		nextRenderedNotes.clear();
		nextRenderedSustains.clear();

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			trace('BPM of this section:');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */

		// CURRENT SECTION
		for (i in _song.notes[curSection].sectionNotes)
		{
			var note:Note = setupNoteData(i, false);
			curRenderedNotes.add(note);
			if (note.sustainLength > 0)
			{
				curRenderedSustains.add(setupSusNote(note));
			}

			if(note.y < -150) note.y = -150;

			if(note.noteData < 0) {
				var daText:AttachedFlxText = new AttachedFlxText(0, 0, 400, 'Event: ' + note.eventName + ' (' + Math.floor(note.strumTime) + ' ms)' + '\nValue 1: ' + note.eventVal1 + '\nValue 2: ' + note.eventVal2, 12);
				daText.setFormat(Paths.font("vcr.ttf"), 12, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				daText.xAdd = -410;
				daText.borderSize = 1;
				curRenderedNoteType.add(daText);
				daText.sprTracker = note;
			} else {
				if(i[3] != null && note.noteType != null && note.noteType.length > 0) {
					var typeInt:Null<Int> = noteTypeMap.get(i[3]);
					var theType:String = '' + typeInt;
					if(typeInt == null) theType = '?';

					var daText:AttachedFlxText = new AttachedFlxText(0, 0, 100, theType, 24);
					daText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					daText.xAdd = -32;
					daText.yAdd = 6;
					daText.borderSize = 1;
					curRenderedNoteType.add(daText);
					daText.sprTracker = note;
				}
				note.mustPress = _song.notes[curSection].mustHitSection;
				if(i[1] > 3) note.mustPress = !note.mustPress;
			}
		}

		// NEXT SECTION
		if(curSection < _song.notes.length-1) {
			for (i in _song.notes[curSection+1].sectionNotes)
			{
				var note:Note = setupNoteData(i, true);
				note.alpha = 0.6;
				nextRenderedNotes.add(note);
				if (note.sustainLength > 0)
				{
					nextRenderedSustains.add(setupSusNote(note));
				}
			}
		}
	}

	function setupNoteData(i:Array<Dynamic>, isNextSection:Bool):Note
	{
		var daNoteInfo = i[1];
		var daStrumTime = i[0];
		var daSus:Dynamic = i[2];

		var note:Note = new Note(daStrumTime, daNoteInfo % 4, null, null, true);
		if(daNoteInfo > -1) { //Common note
			if(!Std.isOfType(i[3], String)) //Convert old note type to new note type format
			{
				i[3] = noteTypeIntMap.get(i[3]);
			}
			if(i.length > 3 && (i[3] == null || i[3].length < 1))
			{
				i.remove(i[3]);
			}
			note.sustainLength = daSus;
			note.noteType = i[3];
		} else { //Event note
			note.loadGraphic(Paths.image('eventArrow'));
			note.eventName = daSus;
			note.eventVal1 = i[3];
			note.eventVal2 = i[4];
		}
		note.setGraphicSize(GRID_SIZE, GRID_SIZE);
		note.updateHitbox();
		note.x = Math.floor(daNoteInfo * GRID_SIZE) + GRID_SIZE;
		if(isNextSection && _song.notes[curSection].mustHitSection != _song.notes[curSection+1].mustHitSection) {
			if(daNoteInfo > 3) {
				note.x -= GRID_SIZE * 4;
			} else if(daNoteInfo > -1) {
				note.x += GRID_SIZE * 4;
			}
		}

		note.y = (GRID_SIZE * (isNextSection ? 16 : 0)) * zoomList[curZoom] + Math.floor(getYfromStrum((daStrumTime - sectionStartTime(isNextSection ? 1 : 0)) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps), false));
		return note;
	}

	function setupSusNote(note:Note):FlxSprite {
		var height:Int = Math.floor(FlxMath.remapToRange(note.sustainLength, 0, Conductor.stepCrochet * 16, 0, (gridBG.height / gridMult)) + (GRID_SIZE * zoomList[curZoom]) - GRID_SIZE / 2);
		var minHeight:Int = Std.int((GRID_SIZE * zoomList[curZoom] / 2) + GRID_SIZE / 2);
		if(height < minHeight) height = minHeight;
		if(height < 1) height = 1; //Prevents error of invalid height

		var spr:FlxSprite = new FlxSprite(note.x + (GRID_SIZE * 0.5) - 4, note.y + GRID_SIZE / 2).makeGraphic(8, height);
		return spr;
	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var noteDataToCheck:Int = note.noteData;
		if(noteDataToCheck > -1 && note.mustPress != _song.notes[curSection].mustHitSection) noteDataToCheck += 4;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.length > 2 && i[0] == note.strumTime && i[1] == noteDataToCheck)
			{
				curSelectedNote = i;
				break;
			}
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		var noteDataToCheck:Int = note.noteData;
		if(noteDataToCheck > -1 && note.mustPress != _song.notes[curSection].mustHitSection) noteDataToCheck += 4;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] == noteDataToCheck)
			{
				if(i == curSelectedNote) curSelectedNote = null;
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
				break;
			}
		}

		updateGrid();
	}

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}

	private function addNote():Void
	{
		var noteStrum = getStrumTime(dummyArrow.y, false) + sectionStartTime();
		var noteData = Math.floor((FlxG.mouse.x - GRID_SIZE) / GRID_SIZE);
		var noteSus = 0;
		var daAlt = false;
		var daType = currentType;

		if(noteData > -1) {
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteTypeIntMap.get(daType)]);
		} else {
			var event = eventStuff[Std.parseInt(eventDropDown.selectedId)][0];
			var text1 = value1InputText.text;
			var text2 = value2InputText.text;
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, event, text1, text2]);
		}
		curSelectedNote = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		if (FlxG.keys.pressed.CONTROL && noteData > -1)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData + 4) % 8, noteSus, noteTypeIntMap.get(daType)]);
		}

		trace(noteData + ', ' + noteStrum + ', ' + curSection);
		strumTimeInputText.text = curSelectedNote[0];

		updateGrid();
		updateNoteUI();
	}

	function getStrumTime(yPos:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if(!doZoomCalc) leZoom = 1;
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + (gridBG.height / gridMult) * leZoom, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float, doZoomCalc:Bool = true):Float
	{
		var leZoom:Float = zoomList[curZoom];
		if(!doZoomCalc) leZoom = 1;
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + (gridBG.height / gridMult) * leZoom);
	}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;

			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;

				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;

				daLength += swagLength;

				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}

			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
		}

		return noteData;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		MusicBeatState.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	function clearEvents() {
		for (sec in 0..._song.notes.length) {
			var count:Int = 0;
			while(count < _song.notes[sec].sectionNotes.length) {
				var note:Array<Dynamic> = _song.notes[sec].sectionNotes[count];
				if(note != null && note[1] < 0) {
					_song.notes[sec].sectionNotes.remove(note);
				} else {
					count++;
				}
			}
		}
		updateGrid();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), Paths.formatToSongPath(_song.song) + ".json");
		}
	}

	private function saveEvents()
	{
		var events:Array<SwagSection> = [];
		for (sec in 0..._song.notes.length) {
			if(_song.notes[sec] == null) continue;

			var arrayNotes:Array<Dynamic> = [];
			for (i in 0..._song.notes[sec].sectionNotes.length) {
				var note:Array<Dynamic> = _song.notes[sec].sectionNotes[i];
				if(note != null && note[1] < 0) {
					arrayNotes.push(note);
				}
			}

			var sex:SwagSection = {
				sectionNotes: arrayNotes,
				lengthInSteps: 16,
				typeOfSection: 0,
				mustHitSection: false,
				bpm: 0,
				changeBPM: false,
				altAnim: false
			};
			events.push(sex);
		}

		var eventsSong:SwagSong = {
			song: _song.song,
			notes: events,
			bpm: _song.bpm,
			needsVoices: _song.needsVoices,
			speed: _song.speed,
			arrowSkin: _song.arrowSkin,
			splashSkin: _song.splashSkin,

			player1: _song.player1,
			player2: _song.player2,
			player3: _song.player3,
			stage: _song.stage,
			validScore: false
		};
		var json = {
			"song": eventsSong
		}

		var data:String = Json.stringify(json, "\t");

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), "events.json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}

class AttachedFlxText extends FlxText
{
	public var sprTracker:FlxSprite;
	public var xAdd:Float = 0;
	public var yAdd:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null) {
			setPosition(sprTracker.x + xAdd, sprTracker.y + yAdd);
			angle = sprTracker.angle;
			alpha = sprTracker.alpha;
		}
	}
}
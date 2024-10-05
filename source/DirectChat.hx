package;

import flixel.FlxG;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

class DirectChat
{
	public static var chatText:String = '';
	public static var chatLong:String = '';
	public static var chatArray:Array<String> = ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''];
	public static var chosenUsername:String = '';
	public static var chosenMessage:String = '';
	public static var finalchat:String = '';
	public static var cantidad:Int = 0;
	public static var tooLong:Bool = false;

	public function new()
	{
		//no me preguntan ni una verga de este codigo porq ni yo se como lo hice funcionar en un hx aparte
	}

	public static function reset()
	{
		chatArray = ['', '', '', '', '', '', '', '', '', '', '', '', '', '', '', ''];
	}

	public static function addMessage()
	{
		if (!tooLong){
			var messages:Array<String> = [
				'This stream ass',
				'delete your channel fr',
				'*REMOVED BY MODERATOR*',
				'zseven',
				'Razky? FUCKING Razky?? They didnt even have the budget to fucking add Zseven himself??? THIS FUCKING MOVIE SUCKS!',
				'we finally got not great bruh',
				'the mood switch is INSANE',
				'I love your stream rosebloom',
				'Who is the girl at the back?',
				'Zseven.webp',
				'WE GOT TGCI MOVIE BEFORE NOT GREAT',
				'bwa',
				'yall wanna hop on bloons',
				'will you play afternight later?',
				'yooo zseven',
				'alr',
				'ITS THE GOAT OMG',
				'lmao',
				'LMAOOOO',
				'what',
				'L',
				'W',
				'no way',
				'can you play fnaf',
				'what happened to taiki',
				'is that zseven',
				'is the guy from fortnite',
				'are you the guy from fnf?',
				':fish:',
				'this is peak',
				'oh',
				'wait its a banger??',
				'BROOO????',
				'hi rose',
				'its zsover',
				'love this man',
				'thats cool',
				'he looks like the level 2 guy ',
				'this is just not great',
				'how',
				'Yeaaaa',
				'hi',
				'they couldnt even get the actual zseven to voice zseven bro wtf',
				'who the fuck is this guy',
				'this movie is gonna suck',
				'what the fuck',
				'WHAAAAAAAAAT',
				'what the fuck who cooked',
				'i wonder who taiki is?',
				'bruh',
				'hi',
				'i was here',
				'ratio',
				'you fell off',
				'hi youtube',
				'ngl the girl in the back is kinda hot',
				'i love women',
				'i love fat bitches',
				'legit who is this guy',
				'marios madness is better',
				'im gonna jump',
				'piracy is a party',
				'adobe animate sucks',
				'will you go gambling later?',
				'the divine solos',
				'follow tgci on twitter',
				'the divine please strike these individuals down',
				'i believe in alcretism',
				'there should be an fnf mod of this',
				'convert to alcretism',
				'this song took 2 months to make',
				'who gaf',
				'meow',
				'watch bocchi the rock',
				'i love impostor v4',
				'watch the friday night foundation trailer'
			];
			
			var usernames:Array<String> = [
				'razky.',
				'dataleak_',
				'Yin',
				'taiki._.',
				'krisyphuss',
				'neonspiderr',
				'kittysleeper',
				'soggysteve',
				'THE DIVINE',
				'zseventeenpencec',
				'lazybones94',
				'COOLSKELETON95',
				'FabulousKillerRobot',
				'ryanNTF',
				'dutchNTF',
				'kangjeonNTF',
				'blueballboy',
				'girlfriend',
				'pico',
				'senpai',
				'maninatank95',
				'darnell',
				'nene',
				'kris',
				'aubrey',
				'thompson',
				'orangejoelover1111',
				'jonesy',
				'holidaygirl225',
				'[[Number1RatedSalesman1997]]',
				'slicer',
				'monke',
				'guitarhero',
				'ryo',
				'kita',
				'nijika',
				'ZX',
				'sogu',
				'milly',
				'yuika',
				'NAPSTABLOOK22',
				'blahaj',
				'kingfluffybuns201',
				'StrongFish91',
				'vaporthecube',
				'flowery201',
				'#1firecat',
				'WolfeyVGC',
				'PlushtrapDev',
				'kimi',
				'dartmonkeybtd6',
				'wil.meow',
				'themadoverlord',
				'dukeofpuzzlesRK603',
				'goldenboy43',
				'besttroller33',
				'Q5U4EX7YY2E9N',
				'strongestsenator0704',
				'fallenhuman201',
				'dontlookatme096',
				'chaosclown33',
				'primesoul88',
				'inkdemon97',
				'indestructiblereptile682',
				'shayy',
				'raul',
				'kennyl',
				'DeltaZ',
				'EpsilonU',

				//ones below here have special messages for their names
				'Duo',
				'Project Afternight',
				'Pyrocynical'
			];


			var usercolor:Int = FlxG.random.int(1, 5);
			var tagcolor:String = '';

			switch(usercolor){
				case 1:
					tagcolor = '$';
				case 2:
					tagcolor = '#';
				case 3:
					tagcolor = '%';
				case 4:
					tagcolor = '&';
				case 5:
					tagcolor = ';';
			}

			chosenMessage = messages[FlxG.random.int(0, messages.length - 1)];
			chosenUsername = usernames[FlxG.random.int(0, usernames.length - 1)];
			
			switch (chosenUsername){
				case 'Duo':
					chosenMessage = "When i get angry my friends hold me back at school bc I am kinda strong and sometimes if I'm really angry my eyes turn half red no joke once my eyes turned red and we had to go in lock down no joke......";
				case 'Project Afternight':
					switch (FlxG.random.int(1,3)){
						case 1:
							chosenMessage = "Who the fuck followed this channel on the main account????";
						case 2:
							chosenMessage = "hi im wil";
						case 3:
							chosenMessage = "[SPAM] go play afternight ours is better";
					}
				case 'DeltaZ':
					chosenMessage = "are you fucking kidding me";
				case 'EpsilonU':
					chosenMessage = "are you fucking kidding me";
				case 'yinnystar':
					chosenMessage = "THIS BITCH IS :fearful:";
				case 'wil.meow':
					switch (FlxG.random.int(1,4)){
						case 1:
							chosenMessage = "hop on project afternight";
						case 2:
							chosenMessage = "hi im wil";
						case 3:
							chosenMessage = "bwaaaa";
						case 4:
							chosenMessage = "go stream bwa on soundcloud";
					}
				case 'kimi':
					chosenMessage = "hop on project afternight";
				case 'dataleak_':
					switch (FlxG.random.int(1,5)){
						case 1:
							chosenMessage = "hop on project afternight";
						case 2:
							chosenMessage = "i will pay you 4 cents to stream minecraft parkour civilisation";
						case 3:
							chosenMessage = "I coded all this shit btw totally all me i totally didnt just modify the source code :3";
						case 4:
							chosenMessage = "this took a while";
						case 5:
							chosenMessage = "Wow we actually got not great done im suprised";
					}

				case 'Pyrocynical':
					chosenMessage = "[SPAM] go subscribe to me https://www.youtube.com/@pyrocynical";				
		
			}

			chatText = tagcolor + chosenUsername + ': ' + tagcolor + chosenMessage;

			if (chatText.length > 35){
				//trace(chosenUsername + "'s message was too long");
				chatLong =  '-' + chatText.substr(35).ltrim();
				chatText = chatText.substr(0, 35).rtrim() + '-';
				tooLong = true;
			}
		}
		else{
			tooLong = false;
			chatText = chatLong;
			if (chatText.length > 35){
				//trace(chosenUsername + "'s message was too long again");
				chatLong =  '-' + chatText.substr(35).ltrim();
				chatText = chatText.substr(0, 35).rtrim() + '-';
				tooLong = true;
			}
		}

		if(cantidad >= 16){
			//top 5 codigos mas conchesumadre
			chatArray[0] = chatArray[1];
			chatArray[1] = chatArray[2];
			chatArray[2] = chatArray[3];
			chatArray[3] = chatArray[4];
			chatArray[4] = chatArray[5];
			chatArray[5] = chatArray[6];
			chatArray[6] = chatArray[7];
			chatArray[7] = chatArray[8];
			chatArray[8] = chatArray[9];
			chatArray[9] = chatArray[10];
			chatArray[10] = chatArray[11];
			chatArray[11] = chatArray[12];
			chatArray[12] = chatArray[13];
			chatArray[13] = chatArray[14];
			chatArray[14] = chatArray[15];
			chatArray[15] = chatText;
		}
		else{
		chatArray[cantidad] = chatText;
		cantidad += 1;
		}

		finalchat = chatArray[0] + '\n' + chatArray[1] + '\n' + chatArray[2] + '\n' + chatArray[3] + '\n' + chatArray[4] + '\n' + chatArray[5] + '\n' + chatArray[6] + '\n' + chatArray[7] + '\n' + chatArray[8] + '\n' + chatArray[9] + '\n' + chatArray[10] + '\n' + chatArray[11] + '\n' + chatArray[12] + '\n' + chatArray[13] + '\n' + chatArray[14] + '\n' + chatArray[15];
		if(tooLong)
			addMessage();
	}
}
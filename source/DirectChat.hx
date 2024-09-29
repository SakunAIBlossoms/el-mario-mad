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
				'bwa'
			];
			
			var usernames:Array<String> = [
				'Razky',
				'Dataleak',
				'Yin',
				'Taiki',
				'Kris',
				'Neon',
				'Rem',
				'kittysleeper',

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
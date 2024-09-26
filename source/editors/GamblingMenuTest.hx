package editors;

#if desktop
import Discord.DiscordClient;
#end
import CoolUtil;
import CppAPI;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import MusicBeatSubstate;
import openfl.Lib;
var randomNum = 0;
var youaregambling = false;
var rerollbutton:FlxSprite;
class GamblingMenuTest extends MusicBeatState
{
    override function create()
    {
        DiscordClient.changePresence("IM FUCKING GAMBLING!!!!!", null);
        Lib.application.window.title = "Friday Night Funkin': This GC's Insanity | IM FUCKING GAMBLING";
        FlxG.mouse.visible = true;
        trace("LETS GO GAMBLING!!!!");
        // im commenting this out for testing reasons... its still funny as fuck tho
        //CoolUtil.browserLoad('https://youtu.be/IPFiKEm-oNI');
        rerollbutton = new FlxSprite().loadGraphic(Paths.image('gambling/RollButton'));
        rerollbutton.x = 650;
        rerollbutton.y = 1;
        rerollbutton.angle = 90;
        //rerollbutton.scale = 0.9;
        add(rerollbutton);
        //beginRandomisation();
    }
    function beginRandomisation() {
        randomNum = FlxG.random.int(1, 100);
        trace("your number is " + randomNum + " yo");
        rerollbutton.alpha = 0.3;
    }
    function endRandomisation() {
        
    }
    override function update(elapsed:Float)
    {
        if (controls.ACCEPT)
        {
            beginRandomisation();
            youaregambling = true;
        };
        
        if (controls.BACK)
        {
            MusicBeatState.switchState(new MainMenuState());
        }
    }
}
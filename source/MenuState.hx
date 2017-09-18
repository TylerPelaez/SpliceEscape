package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.FlxG;

class MenuState extends FlxState
{
	var _playButton:FlxButton;
	
	override public function create():Void
	{
		super.create();
		_playButton = new FlxButton(10,10, "Start game", clickPlay);
		_playButton.screenCenter();
		add(_playButton);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
	
	function clickPlay():Void{
		FlxG.switchState(new PlayState());
	}
}
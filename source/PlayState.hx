package;

import flixel.FlxState;

class PlayState extends FlxState
{
	var _player : Player;

	override public function create():Void
	{
		super.create();
		_player = new Player();
		add(_player);
		_player.screenCenter();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}

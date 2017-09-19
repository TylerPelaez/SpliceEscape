package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	private static var TILE_WIDTH:Int = 80;
	private static var TILE_HEIGHT:Int = 80;

	private var _player : Player;
	private var _collisionMap : FlxTilemap;

	override public function create():Void
	{
		super.create();
		_player = new Player();
		_collisionMap = new FlxTilemap();

		_collisionMap.loadMapFromCSV("assets/tilemaps/test_tilemap.csv", "assets/images/test_tilemap.png", TILE_WIDTH, TILE_HEIGHT, AUTO);

		add(_collisionMap);
		add(_player);
	}

	override public function update(elapsed:Float):Void
	{
		FlxG.collide(_player, _collisionMap);
		super.update(elapsed);
	}
}

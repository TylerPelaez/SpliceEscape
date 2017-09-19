package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.tile.FlxTilemap;

class PlayState extends FlxState
{
	// Constants for using the tile map
	private static var TILE_WIDTH:Int = 80;
	private static var TILE_HEIGHT:Int = 80;

	private var _player : Player;
	private var _collisionMap : FlxTilemap;

	override public function create():Void
	{
		super.create();
		_player = new Player();
		_collisionMap = new FlxTilemap();


		// Using FlxTilemap enables us to display graphics AND check for 
		// collisions between the player and the leve.
		_collisionMap.loadMapFromCSV("assets/tilemaps/test_tilemap.csv", "assets/images/test_tilemap.png", TILE_WIDTH, TILE_HEIGHT, AUTO);

		add(_collisionMap);
		add(_player);
	}

	override public function update(elapsed:Float):Void
	{
		// This is enough to determine if the player is touching any part of _collisionMap.
		FlxG.collide(_player, _collisionMap);
		super.update(elapsed);
	}
}

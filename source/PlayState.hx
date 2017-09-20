package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import openfl.Assets;

class PlayState extends FlxState
{
	// Constants for using the tile map
	private static var TILE_WIDTH:Int = 80;
	private static var TILE_HEIGHT:Int = 80;
	private static var TILEMAP_PATH:String = "assets/images/test_tilemap.png";
	private static var FIRST_LEVEL_NAME:String = "test";

	private var _player:Player;
	private var _collisionMap:FlxTilemap;
	private var _inViewMode:Bool;

	private var _levels:Array<LevelData>;
	private var _currentLevelIndex = -1;

	private var _selectedInstructionList:List<Instruction>;

	override public function create():Void
	{
		super.create();
		_inViewMode = false;
		_player = new Player();
		_collisionMap = new FlxTilemap();
		_levels = new Array<LevelData>();
		add(_collisionMap);
		add(_player);

		FlxG.camera.follow(_player, PLATFORMER, 1);

		loadlevelsFromFile(FIRST_LEVEL_NAME);
		loadNextLevel();
	}

	override public function update(elapsed:Float):Void
	{
		// This is enough to determine if the player is touching any part of _collisionMap.
		FlxG.collide(_player, _collisionMap);
		// Player dies! Reset!
		if (_player.getPosition().y > _levels[_currentLevelIndex]._height || _player.getPosition().x > _levels[_currentLevelIndex]._width )
		{
			resetPlayerPlayMode();
		}
		super.update(elapsed);
	}

	private function loadlevelsFromFile(firstLevelName:String):Void{
		var lines:Array<String>;
		var curLevelName:String = firstLevelName;
		
		do 
		{
			var fullPath:String = "assets/data/" + curLevelName + ".txt";

			if (Assets.exists(fullPath))
				lines = Assets.getText(fullPath).split("|");
			else 
				return;

			var levelData:LevelData = new LevelData();
 
			// Level data files should all be in this format with a corresponding tilemap.csv in data folder
			levelData._name = lines[0];
			levelData._width = Std.parseInt(lines[1]);
			levelData._height = Std.parseInt(lines[2]);
			levelData._playerInitX = Std.parseInt(lines[3]);
			levelData._playerInitY = Std.parseInt(lines[4]);
			curLevelName = lines[5];

			_levels.push(levelData);
		} while(curLevelName != "end");
	}

	private function loadNextLevel():Void
	{
		_currentLevelIndex++;

		if (_currentLevelIndex == _levels.length)
			return;

		FlxG.camera.setScrollBoundsRect(0, 0, _levels[_currentLevelIndex]._width, _levels[_currentLevelIndex]._height, true);

		// Using FlxTilemap enables us to display graphics AND check for 
		// collisions between the player and the level.
		var CSVPath:String = "assets/data/" + _levels[_currentLevelIndex]._name;
		//trace(CSVPath);
		CSVPath = CSVPath + "_tilemap.csv";
		trace(CSVPath);
		_collisionMap.loadMapFromCSV(CSVPath, TILEMAP_PATH, TILE_WIDTH, TILE_HEIGHT, AUTO);

		// Reset player
		resetPlayerPlayMode();
	}

	private function resetPlayerPlayMode()
	{
		_player.velocity.x = _player.velocity.y = 0;
		_player.setPosition(_levels[_currentLevelIndex]._playerInitX, _levels[_currentLevelIndex]._playerInitY);
	}

	private function enterPlayMode()
	{
		_inViewMode = false;
		resetPlayerPlayMode();
	}
}

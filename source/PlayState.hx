package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import openfl.Assets;
import flixel.FlxSprite;

class PlayState extends FlxState
{
	// Constants for using the tile map
	private static var TILE_WIDTH:Int = 80;
	private static var TILE_HEIGHT:Int = 80;
	private static var TILEMAP_PATH:String = "assets/images/test_tilemap.png";
	private static var FIRST_LEVEL_NAME:String = "test";
	// Instructions to be initialized in create()
	// After player chooses instructions - copies will be made and added to 
	// the player instruction list.
	private var WALK_RIGHT_INSTRUCTION:Instruction;
	private var WALK_LEFT_INSTRUCTION:Instruction;
	private var JUMP_RIGHT_INSTRUCTION:Instruction;
	private var JUMP_LEFT_INSTRUCTION:Instruction;
	private var IDLE_INSTRUCTION:Instruction;
	private var INTERACT_INSTRUCTION:Instruction;

	private var _player:Player;
	private var _collisionMap:FlxTilemap;
	private var _inViewMode:Bool;

	private var _levels:Array<LevelData>;
	private var _currentLevelIndex = -1;
	private var _spikesGroup:FlxTypedGroup<Spikes>;

	private var _selectedInstructionList:List<Instruction>;

	private var _mouseWrapper:FlxSprite;

	override public function create():Void
	{
		super.create();
		
		_player = new Player();
		_collisionMap = new FlxTilemap();
		_levels = new Array<LevelData>();
		_selectedInstructionList = new List<Instruction>();
		initInstructions();
		_mouseWrapper = new FlxSprite();
		_spikesGroup = new FlxTypedGroup<Spikes>();
		_inViewMode = false;

		add(_collisionMap);
		add(_player);
		add(_spikesGroup);

		FlxG.camera.follow(_player, PLATFORMER, 1);

		loadlevelsFromFile(FIRST_LEVEL_NAME);
		loadNextLevel();

		// TEST CODE:
		_selectedInstructionList.add(WALK_RIGHT_INSTRUCTION);
		_selectedInstructionList.add(JUMP_RIGHT_INSTRUCTION);
		_selectedInstructionList.add(JUMP_RIGHT_INSTRUCTION);
		_selectedInstructionList.add(IDLE_INSTRUCTION);
		_selectedInstructionList.add(WALK_LEFT_INSTRUCTION);
		_selectedInstructionList.add(WALK_RIGHT_INSTRUCTION);
		_selectedInstructionList.add(WALK_RIGHT_INSTRUCTION);
		_selectedInstructionList.add(WALK_RIGHT_INSTRUCTION);
		_selectedInstructionList.add(WALK_RIGHT_INSTRUCTION);
		_selectedInstructionList.add(WALK_RIGHT_INSTRUCTION);
		// Reset player
		resetPlayerViewMode();
	}


	override public function update(elapsed:Float):Void
	{
		// This is enough to determine if the player is touching any part of _collisionMap.
		FlxG.collide(_collisionMap, _player);
		_mouseWrapper.setPosition(FlxG.mouse.getWorldPosition().x, FlxG.mouse.getWorldPosition().y);
		// Player dies! Reset!
		if (checkPlayerDeath())
		{
			resetPlayerViewMode();
		}
		if (_player.getPosition().x < 0 )
		{
			_player.setPosition(0, _player.getPosition().y);
		}
		if (_player.getPosition().x > _levels[_currentLevelIndex]._width - _player.width)
		{
			_player.setPosition(_levels[_currentLevelIndex]._width - _player.width, _player.getPosition().y);
		}
		if (_inViewMode && FlxG.keys.anyPressed([SPACE]))
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
			

			var fullItemsPath:String = "assets/data/" + curLevelName +  "_items.txt";
			var itemLine:Array<String>;

			if (Assets.exists(fullItemsPath))
			{
				itemLine = Assets.getText(fullItemsPath).split("|");
				for (item in itemLine)
				{
					if (item.split(":")[0] == "spikes")
					{
						levelData._spikeArray.push(new Spikes());
						levelData._spikeArray[levelData._spikeArray.length - 1].setPosition(Std.parseInt(item.split(":")[1]), Std.parseInt(item.split(":")[2]));
					}
									
				}
			}
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
		_collisionMap.loadMapFromCSV(CSVPath, TILEMAP_PATH, TILE_WIDTH, TILE_HEIGHT, AUTO);

		_spikesGroup.clear();
		for (spikes in _levels[_currentLevelIndex]._spikeArray)
		{
			_spikesGroup.add(spikes);
		}
	}

	private function initInstructions():Void
	{
		// Instructions that can be copied and then given to the player's instruction list.
		WALK_LEFT_INSTRUCTION = new Instruction("Walk Left", 2, -200, 0, true);
		WALK_RIGHT_INSTRUCTION = new Instruction("Walk Right", 2, 200, 0, false);
		JUMP_RIGHT_INSTRUCTION = new Instruction("Jump Right", 1.25, 200, -1000, false);
		JUMP_LEFT_INSTRUCTION = new Instruction("Jump Left", 1.25, -200, -1000, true);
		IDLE_INSTRUCTION = new Instruction("Idle", 2, 0, 0, false);
		INTERACT_INSTRUCTION = new Instruction("Interact", 0.5, 0, 0, false, true);
	}

	private function resetPlayerViewMode()
	{
		resetPlayerPlayMode();
		_player.setActive(false);
		_player.alpha = 0.2;
		_player.facing;
		_inViewMode = true;
		_player.clearInstructions();
		FlxG.camera.focusOn(_player.getPosition());
		FlxG.camera.follow(_mouseWrapper, TOPDOWN, 0.1);
	}

	private function resetPlayerPlayMode()
	{
		_player.setActive(true);
		_player.alpha = 1;
		_player.acceleration.y = 2000;
		_player.velocity.x = _player.velocity.y = 0;
		_player.setPosition(_levels[_currentLevelIndex]._playerInitX, _levels[_currentLevelIndex]._playerInitY);
		_player.giveInstructions(_selectedInstructionList);
		FlxG.camera.follow(_player, PLATFORMER, 1);
		_inViewMode = false;
	}

	private function checkPlayerDeath():Bool
	{
		return (_player.getPosition().y > _levels[_currentLevelIndex]._height) || FlxG.overlap(_spikesGroup, _player); 
	}
}

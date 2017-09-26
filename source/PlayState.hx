package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import openfl.Assets;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class PlayState extends FlxState
{
	// Constants for using the tile map
	private static var TILE_WIDTH:Int = 80;
	private static var TILE_HEIGHT:Int = 80;
	private static var TILEMAP_PATH:String = "assets/images/test_tilemap.png";
	private static var FIRST_LEVEL_NAME:String = "test";
	// Constants for orders button roll
	private static var ROLL_X:Int = 50;
	private static var ROLL_Y:Int = 50;
	private static var ROLL_SCALE:Int = 2;
	private static var ROLL_COUNT:Int = 4;
	private static var ROLL_SPACING:Int = 200;
	private static var ROLL_PIXELS:Int = 16;
	private static var ROLL_SELECT_DROP:Int = 200;
	private static var SELECT_PIXELS:Int = 16;	
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

	private var _selectedInstructionList:List<Instruction>;

	private var _availableInstructionList:Array<List<Instruction> >;
	private var _subInstructionList:List<List<Instruction> >;

	private var _mouseWrapper:FlxSprite;

	private var _orderDisplay:FlxText;
	private var _orders:Array<FlxButton>;
	private var _rollLeft:FlxButton;
	private var _rollRight:FlxButton;
	private var _orderBase:Int;


	override public function create():Void
	{
		super.create();
		
		_player = new Player();
		_collisionMap = new FlxTilemap();
		_levels = new Array<LevelData>();
		_selectedInstructionList = new List<Instruction>();
		initInstructions();
		_availableInstructionList = new Array<List< Instruction> >();
		_subInstructionList = new List<List< Instruction> >();
		_mouseWrapper = new FlxSprite();
		_inViewMode = false;

		_orderDisplay = new FlxText();
		_orderDisplay.x = ROLL_X;
		_orderDisplay.y = ROLL_Y + ROLL_SELECT_DROP;
		_orderDisplay.size = SELECT_PIXELS;
		_orderDisplay.systemFont = "Arial";
		_orderDisplay.fieldWidth = 400;
		//_orderDisplay.exists = false;

		_orders = new Array<FlxButton>();

		_orderBase = 0;
		
		_rollRight = new FlxButton(0,ROLL_Y,"→",function(){_orderBase++;setOrdersState();});
		_rollRight.scale.y = ROLL_SCALE;
		_rollRight.label.size = ROLL_PIXELS;
		_rollRight.label.systemFont = "Arial";
		_rollRight.x = ROLL_X + (ROLL_COUNT)*ROLL_SPACING;
		_rollRight.label.fieldWidth = _rollRight.width;
		_rollRight.label.alignment = "center";
		//_rollRight.exists = false;

		_rollLeft = new FlxButton(0,ROLL_X,"←",function(){_orderBase--;setOrdersState();});
		_rollLeft.scale.y = ROLL_SCALE;
		_rollLeft.label.size = ROLL_PIXELS;
		_rollLeft.label.systemFont = "Arial";
		_rollLeft.x = ROLL_X;
		_rollLeft.label.fieldWidth =_rollLeft.width;
		_rollLeft.label.alignment = "center";
		//_rollRight.exists = false;

		//Generate ROLL_COUNT buttons, set them to be scaled and formatted appropriately.
		for(i in 0...ROLL_COUNT - 1)
		{
			_orders.insert(0,new FlxButton(ROLL_X +(i+1)*ROLL_SPACING,ROLL_Y,""));
			_orders[0].scale.x = _orders[0].scale.y = ROLL_SCALE;
			_orders[0].label.size = ROLL_PIXELS;
			_orders[0].label.systemFont = "Arial";
			_orders[0].label.fieldWidth =_orders[0].width;
			_orders[0].label.alignment = "center";
			//_orders[0].exists = false;
			add(_orders[0]);
		}

		add(_rollLeft);
		add(_rollRight);
		add(_orderDisplay);
		add(_collisionMap);
		add(_player);

		FlxG.camera.follow(_player, PLATFORMER, 1);

		loadlevelsFromFile(FIRST_LEVEL_NAME);
		loadNextLevel();

		// TEST CODE:
		_availableInstructionList.insert(0,new List<Instruction>());
		_availableInstructionList[0].add(JUMP_RIGHT_INSTRUCTION);
		_availableInstructionList[0].add(JUMP_RIGHT_INSTRUCTION);
		_availableInstructionList.insert(0,new List<Instruction>());
		_availableInstructionList[0].add(WALK_RIGHT_INSTRUCTION);
		_availableInstructionList[0].add(WALK_RIGHT_INSTRUCTION);
		_availableInstructionList.insert(0,new List<Instruction>());
		_availableInstructionList[0].add(IDLE_INSTRUCTION);
		_availableInstructionList[0].add(WALK_RIGHT_INSTRUCTION);
		// Reset player
		resetPlayerViewMode();
	}


	override public function update(elapsed:Float):Void
	{
		// This is enough to determine if the player is touching any part of _collisionMap.
		FlxG.collide(_collisionMap, _player);
		_mouseWrapper.setPosition(FlxG.mouse.getWorldPosition().x, FlxG.mouse.getWorldPosition().y);
		// Player dies! Reset!
		if (_player.getPosition().y > _levels[_currentLevelIndex]._height)
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

	private function setOrdersState()
	{
		//TODO: Make orders UI visible here
		for(i in 0...ROLL_COUNT)
		{
			_orders[i].label.text = "";
			_orders[i].onUp.callback = function(){};
			_orders[i].exists = true;
			//If in range, bind the button to adding the order list and add its text to the button.
			if(i+_orderBase < _availableInstructionList.length && i+_orderBase >= 0)
			{
				for(ins in _availableInstructionList[i+_orderBase])
				{
					_orders[i].label.text += ins._name;
				}
				_orders[i].onUp.callback = function(){
					_subInstructionList.add(_availableInstructionList[i+_orderBase]);
					_availableInstructionList.remove(_availableInstructionList[i+_orderBase]);
					//Set the orders buttons again
					setOrdersState();
				}
			}
			else
			{
				_orders[i].exists = false;
			}
		}
		_orderDisplay.text = "";
		for(sublist in _subInstructionList)
		{

			for(ins in sublist)
			{
				_orderDisplay.text += ins._name;
			}
		}
	}

	private function flattenSubInstruction()
	{
		var temp:List<Instruction> = new List<Instruction>();
		for(sublist in _subInstructionList)
		{
			for(ins in sublist)
			{
				temp.add(ins);
			}
		}
		return temp;
	}

	private function unsetOrdersState()
	{
		//TODO: Make all the orders UI stuff invisible here.
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
		_collisionMap.loadMapFromCSV(CSVPath, TILEMAP_PATH, TILE_WIDTH, TILE_HEIGHT);
		// Kill player on collision with red tile(test for barbed wire)
		_collisionMap.setTileProperties(2,FlxObject.ANY,function(o1:FlxObject,o2:FlxObject){resetPlayerViewMode();});
	}

	private function initInstructions():Void
	{
		// Instructions that can be copied and then given to the player's instruction list.
		WALK_LEFT_INSTRUCTION = new Instruction("←", 2, -200, 0, true);
		WALK_RIGHT_INSTRUCTION = new Instruction("→", 2, 200, 0, false);
		JUMP_RIGHT_INSTRUCTION = new Instruction("↗", 1.25, 200, -1000, false);
		JUMP_LEFT_INSTRUCTION = new Instruction("↖", 1.25, -200, -1000, true);
		IDLE_INSTRUCTION = new Instruction("0", 2, 0, 0, false);
		INTERACT_INSTRUCTION = new Instruction("I", 0.5, 0, 0, false, true);
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
		setOrdersState();
	}

	private function resetPlayerPlayMode()
	{
		_player.setActive(true);
		_player.alpha = 1;
		_player.acceleration.y = 2000;
		_player.velocity.x = _player.velocity.y = 0;
		_player.setPosition(_levels[_currentLevelIndex]._playerInitX, _levels[_currentLevelIndex]._playerInitY);
		_player.giveInstructions(flattenSubInstruction());
		unsetOrdersState();
		FlxG.camera.follow(_player, PLATFORMER, 1);
		_inViewMode = false;
	}
}

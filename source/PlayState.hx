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
import flixel.math.FlxRect;
import flixel.addons.display.FlxBackdrop;
import flixel.system.FlxSound;

class PlayState extends FlxState
{
	// Constants for using the tile map
	private static var TILE_WIDTH:Int = 128;
	private static var TILE_HEIGHT:Int = 128;
	private static var TILEMAP_PATH:String = "assets/images/tilemap_v1.png";
	private static var FIRST_LEVEL_NAME:String = "lvl_1";
	// Constants for orders button roll
	private static var ROLL_X:Int = 150;
	private static var ROLL_Y:Int = 150;
	private static var ROLL_SCALE:Int = 2;
	private static var ROLL_COUNT:Int = 4;
	private static var ROLL_SPACING:Int = 150;
	private static var ROLL_PIXELS:Int = 16;
	private static var ROLL_SELECT_DROP:Int = 150;
	private static var SELECT_PIXELS:Int = 16;
	private static var BUTTON_FONT:String = "assets/fonts/CODE2000.TTF";
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
	private var _background:FlxBackdrop;
	private var _collisionMap:FlxTilemap;
	private var _inViewMode:Bool;

	private var _levels:Array<LevelData>;
	private var _currentLevelIndex = -1;

	private var _bulletGroup:FlxTypedGroup<FlxSprite>;
	private var _leverGroup:FlxTypedGroup<Lever>;
	private var _turretGroup:FlxTypedGroup<Turret>;
	private var _boxGroup:FlxTypedGroup<Box>;

	private var _selectedInstructionList:List<Instruction>;

	private var _availableInstructionList:Array<List<Instruction> >;
	private var _subInstructionList:List<List<Instruction> >;

	// Used for camera tracking the mouse
	private var _mouseWrapper:FlxSprite;

	// Selecting orders to give to robot.
	private var _orderDisplay:FlxText;
	private var _orders:Array<FlxButton>;
	private var _rollLeft:FlxButton;
	private var _rollRight:FlxButton;
	private var _removeOrder:FlxButton;
	private var _orderBase:Int;

	private var _sndClick:FlxSound;
	private var _sndClick2:FlxSound;

	private var _playerDead:Bool;
	private var _playerDeathCountdown:Float;
	private static var _playerDeadTimer:Float = 1.2;



	override public function create():Void
	{
		super.create();
		
		_player = new Player();
		_collisionMap = new FlxTilemap();
		_background = new FlxBackdrop("assets/images/walls.png", 1, 1, true, true);
		add(_background);
		_levels = new Array<LevelData>();
		_selectedInstructionList = new List<Instruction>();
		initInstructions();
		_availableInstructionList = new Array<List< Instruction> >();
		_subInstructionList = new List<List< Instruction> >();
		_mouseWrapper = new FlxSprite();
		_inViewMode = false;
		_playerDead = false;
		_playerDeathCountdown = 0.0;

		_bulletGroup = new FlxTypedGroup<FlxSprite>();
		_leverGroup = new FlxTypedGroup<Lever>();
		_turretGroup = new FlxTypedGroup<Turret>();
		_boxGroup = new FlxTypedGroup<Box>();

		_orderDisplay = new FlxText();
		_orderDisplay.x = ROLL_X;
		_orderDisplay.y = ROLL_Y + ROLL_SELECT_DROP;
		_orderDisplay.size = SELECT_PIXELS;
		_orderDisplay.setFormat(BUTTON_FONT, SELECT_PIXELS);
		_orderDisplay.fieldWidth = 400;
		_orderDisplay.scrollFactor.set(0,0);
		//_orderDisplay.exists = false;

		_sndClick = FlxG.sound.load(AssetPaths.MenuClick__wav);
		_sndClick2 = FlxG.sound.load(AssetPaths.MenuClick2__wav);

		_orders = new Array<FlxButton>();

		_orderBase = 0;
		
		_rollRight = new FlxButton(0,ROLL_Y,"→",function(){_orderBase++;setOrdersState(); _sndClick.play();});
		_rollRight.scale.y = ROLL_SCALE;
		_rollRight.label.size = ROLL_PIXELS;
		_rollRight.label.setFormat(BUTTON_FONT, ROLL_PIXELS, 0x000000);
		_rollRight.x = ROLL_X + (ROLL_COUNT + 1)*ROLL_SPACING;
		_rollRight.label.fieldWidth = _rollRight.width;
		_rollRight.label.alignment = "center";
		//_rollRight.exists = false;

		_rollLeft = new FlxButton(0,ROLL_Y,"←",function(){_orderBase--;setOrdersState(); _sndClick.play();});
		_rollLeft.scale.y = ROLL_SCALE;
		_rollLeft.label.size = ROLL_PIXELS;
		_rollLeft.label.setFormat(BUTTON_FONT, ROLL_PIXELS, 0x000000);
		_rollLeft.x = ROLL_X;
		_rollLeft.label.fieldWidth =_rollLeft.width;
		_rollLeft.label.alignment = "center";
		//_rollRight.exists = false;

		_removeOrder = new FlxButton(ROLL_X,ROLL_Y + ROLL_SELECT_DROP / 2,"Remove",function(){
			if(_subInstructionList.length > 0)
			{
				//Is a popBack() really too much to ask here?
				var ilist:List<Instruction> = _subInstructionList.last();
				_subInstructionList.remove(ilist);
				_availableInstructionList.push(ilist);
				setOrdersState();
			}
			_sndClick.play();
		});
		_removeOrder.scale.y = _removeOrder.scale.x = ROLL_SCALE;
		_removeOrder.label.size = ROLL_PIXELS;
		_removeOrder.label.setFormat(BUTTON_FONT, ROLL_PIXELS, 0x000000);
		_removeOrder.label.fieldWidth = _removeOrder.width;
		_removeOrder.label.alignment = "center";

		//Generate ROLL_COUNT buttons, set them to be scaled and formatted appropriately.
		for(i in 0...ROLL_COUNT)
		{
			_orders.insert(0,new FlxButton(ROLL_X +(ROLL_COUNT - i)*ROLL_SPACING,ROLL_Y,""));
			_orders[0].scale.x = _orders[0].scale.y = ROLL_SCALE;
			_orders[0].label.size = ROLL_PIXELS;
			_orders[0].label.setFormat(BUTTON_FONT, ROLL_PIXELS, 0x000000);
			_orders[0].label.fieldWidth =_orders[0].width;
			_orders[0].label.alignment = "center";
			//_orders[0].exists = false;
			add(_orders[0]);
		}

		
		add(_collisionMap);
		add(_removeOrder);
		add(_rollLeft);
		add(_rollRight);
		add(_orderDisplay);
		add(_player);
		add(_bulletGroup);
		add(_leverGroup);
		add(_turretGroup);
		add(_boxGroup);

		loadlevelsFromFile(FIRST_LEVEL_NAME);
		loadNextLevel();
		
		// Reset player
		resetPlayerViewMode();
	}



	override public function update(elapsed:Float):Void
	{
		_mouseWrapper.setPosition(FlxG.mouse.getWorldPosition().x, FlxG.mouse.getWorldPosition().y);

		// This is enough to determine if the player is touching any part of _collisionMap.
		FlxG.collide(_collisionMap, _player);
		if (!_inViewMode)
		{
			if (FlxG.keys.anyPressed([ESCAPE]))
			{
				resetPlayerViewMode();
			}

			if (_playerDead)
			{
				_playerDeathCountdown -= elapsed;
				if (_playerDeathCountdown <= 0)
				{
					resetPlayerViewMode();
				}
			} else 
			{
				if (FlxG.keys.anyPressed([ESCAPE]))
				{
					resetPlayerViewMode();
				}

				// Player died or is out of orders! Reset!
				var bulletItr = _bulletGroup.iterator();
				for (bullet in bulletItr)
				{
					if (FlxG.collide(bullet, _player))
					{
						if (!_player._holdingBox)
						{
							killPlayer();
						} else if((_player.facing == FlxObject.LEFT && bullet.getPosition().x > _player.getPosition().x) || (_player.facing == FlxObject.RIGHT && bullet.getPosition().x < _player.getPosition().x) )
						{
							killPlayer();
						}
						break;
					}
				}

				if (_player.getPosition().y > _levels[_currentLevelIndex]._height || _player.isFinished())
				{
					resetPlayerViewMode();
				}

				if (_player._interacting)
				{
					if (_player._holdingBox)
					{
						var boxItr = _boxGroup.iterator();
						for (box in boxItr)
						{
							box.drop();
							_player._holdingBox = false;
						}
						remove(_boxGroup);
						add(_boxGroup);
					} else 
					{
						var leverItr = _leverGroup.iterator();
						var flippedLever:Bool = false;
						for (lever in leverItr)
						{
							if (FlxG.overlap(lever, _player))
							{
								lever.flipLever();
								flippedLever = true;
								if ((lever.getPosition().x + (lever.width / 2)) < (_player.getPosition().x + (_player.width / 2)))
								{
									_player.animation.play("FlipSwitchLeft");
								} else
								{
									_player.animation.play("FlipSwitchRight");
								}
								break;
							}
						}

						if (!flippedLever)
						{
							var boxItr = _boxGroup.iterator();
							for (box in boxItr)
							{
								if (FlxG.overlap(box, _player))
								{
									box.pickUp();
									remove(_boxGroup);
									insert(105, _boxGroup);
									_player._holdingBox = true;
									break;
								}
							}
						}	
						
					}
					_player._interacting = false;
				}

				// Ensure player doesn't escape level.
				if (_player.getPosition().x < 0 )
				{
					_player.setPosition(0, _player.getPosition().y);
				}
				if (_player.getPosition().x > _levels[_currentLevelIndex]._width - _player.width)
				{
					_player.setPosition(_levels[_currentLevelIndex]._width - _player.width, _player.getPosition().y);
				}

				// If player is holding a box, make it follow the player.
				if (_player._holdingBox)
				{
					var boxItr = _boxGroup.iterator();
					for (box in boxItr)
					{
						if (box._beingHeld)
						{
							// Random constants to make the box be following the player
							var newX = (_player.facing == FlxObject.LEFT) ? (_player.getPosition().x - 50) : (_player.getPosition().x + 75);
							box.setPosition(newX, _player.getPosition().y - 20);
						}
					}
				}
			}

		} else if (FlxG.keys.anyPressed([SPACE]))
		{
			resetPlayerPlayMode();
		}

		FlxG.collide(_boxGroup, _collisionMap);


		// Fire bullets from turrets if possible.
		var turretItr = _turretGroup.iterator();
		for (turret in turretItr)
		{
			var bulletReturned:FlxSprite = turret.fire();
			if (bulletReturned != null)
			{
				_bulletGroup.add(bulletReturned);
			}
		}

		// Now check if bullets are out of bounds or hitting walls
		var bulletItr = _bulletGroup.iterator();
		for (bullet in bulletItr)
		{
			if (FlxG.collide(bullet, _collisionMap) || bullet.getPosition().x < 0 || bullet.getPosition().x > _levels[_currentLevelIndex]._width || FlxG.collide(_boxGroup))
			{
				bullet.kill();
				_bulletGroup.remove(bullet);
			}
		}
		if (!_inViewMode && FlxG.keys.anyPressed([ESCAPE]))
		{
			resetPlayerViewMode();
		}
		super.update(elapsed);
	}

	private function setOrdersState()
	{
		_orderDisplay.exists = true;
		_rollLeft.exists = true;
		_rollRight.exists = true;
		_removeOrder.exists = true;
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
					 _sndClick2.play();
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

		// Needed to ensure buttons show up on top of level
		var i:Int = 124;
		remove(_removeOrder);
		insert(++i, _removeOrder);
		remove(_rollLeft);
		insert(++i, _rollLeft);
		remove(_rollRight);
		insert(++i, _rollRight);
		remove(_orderDisplay);
		insert(++i, _orderDisplay);

		
		for (order in _orders)
		{
			remove(order);
			insert (i, order);
			i++;
		}
	}

	private function killPlayer():Void
	{	
		if (_playerDead)
		{
			return;
		}
		if (_player.facing == FlxObject.RIGHT)
		{
			_player.animation.play("DeathRight");
		} else
		{
			_player.animation.play("DeathLeft");
		}

		_player.velocity.x = _player.velocity.y = 0;
		_player.clearInstructions();
		_player.setDead(true);
		_player.setSpeed(0.0);
		_playerDead = true;
		_playerDeathCountdown = _playerDeadTimer;
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
		//Make all the orders UI stuff invisible here.
		_orderDisplay.exists = false;
		_rollLeft.exists = false;
		_rollRight.exists = false;
		_removeOrder.exists = false;
		for(i in 0...ROLL_COUNT)
		{
			_orders[i].exists = false;
		}
	}

	private function loadlevelsFromFile(firstLevelName:String):Void{
		var lines:Array<String>;
		var curLevelName:String = firstLevelName;
		
		do 
		{
			var fullPath:String = "assets/data/" + curLevelName + ".txt";
			var ordersPath:String = "assets/data/" + curLevelName + "order.txt";

			if (Assets.exists(fullPath) && Assets.exists(ordersPath))
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

			var nextLevel:String = lines[5];

			fullPath = "assets/data/" + curLevelName + "_items.txt";

			if (Assets.exists(fullPath))
				lines = Assets.getText(fullPath).split("|");
			else
				return;
			
			for (item in lines)
			{
				var itemInfo = item.split(" ");
				if (itemInfo[0] == "lever")
				{
					var newLever = new Lever(Std.parseInt(itemInfo[1]), Std.parseInt(itemInfo[2]), Std.parseInt(itemInfo[3]), Std.parseInt(itemInfo[4]), Std.parseFloat(itemInfo[5]), itemInfo[6]);
					levelData._levers.push(newLever);
				} else if (itemInfo[0] == "box")
				{
					var newBox = new Box(Std.parseInt(itemInfo[1]), Std.parseInt(itemInfo[2]));
					levelData._boxes.push(newBox);
				}
			}
			
			var olines:Array<String> = Assets.getText(ordersPath).split("$");
			for(subg in olines)
			{
				var tempList:List<Instruction> = new List<Instruction>();
				var instrs:Array<String> = subg.split("|");
				for(ins in instrs)
				{
					switch ins
					{
						case "wr":
							tempList.add(WALK_RIGHT_INSTRUCTION.clone());
						case "wl":
							tempList.add(WALK_LEFT_INSTRUCTION.clone());
						case "jr":
							tempList.add(JUMP_RIGHT_INSTRUCTION.clone());
						case "jl":
							tempList.add(JUMP_LEFT_INSTRUCTION.clone());
						case "idl":
							tempList.add(IDLE_INSTRUCTION.clone());
						case "itr":
							tempList.add(INTERACT_INSTRUCTION.clone());
					}
				}
				levelData._availInstr.push(tempList);
			}

			curLevelName = nextLevel;
			_levels.push(levelData);
		} while(curLevelName != "end");
	}

	private function loadNextLevel():Void
	{
		// Paranoid group resetting due to a lack of understanding of how groups work.
		resetBulletGroup();

		_selectedInstructionList.clear();
		_subInstructionList.clear();

		remove(_leverGroup);
		_leverGroup.kill();
		_leverGroup = new FlxTypedGroup<Lever>();
		add(_leverGroup);

		remove(_turretGroup);
		_turretGroup.kill();
		_turretGroup = new FlxTypedGroup<Turret>();
		add(_turretGroup);

		remove(_boxGroup);
		_boxGroup.kill();
		_boxGroup = new FlxTypedGroup<Box>();
		add(_boxGroup);
		if (_currentLevelIndex > -1)
			_levels[_currentLevelIndex] = null;

		_currentLevelIndex++;

		if (_currentLevelIndex == _levels.length)
			return;

		FlxG.camera.setScrollBoundsRect(0, 0, _levels[_currentLevelIndex]._width, _levels[_currentLevelIndex]._height, true);

		for (lever in _levels[_currentLevelIndex]._levers)
		{
			_leverGroup.add(lever);
			_turretGroup.add(lever._connectedTurret);
		}

		for (box in _levels[_currentLevelIndex]._boxes)
		{
			_boxGroup.add(box);
			box.resetToInitPos();
		}

		// Using FlxTilemap enables us to display graphics AND check for 
		// collisions between the player and the level.
		var CSVPath:String = "assets/data/" + _levels[_currentLevelIndex]._name;
		//trace(CSVPath);
		CSVPath = CSVPath + "_tilemap.csv";
		_collisionMap.loadMapFromCSV(CSVPath, TILEMAP_PATH, TILE_WIDTH, TILE_HEIGHT);
		// Kill player on collision with red tile(test for barbed wire)
		_collisionMap.setTileProperties(2,FlxObject.ANY,function(o1:FlxObject,o2:FlxObject){killPlayer();});
		_collisionMap.setTileProperties(3, FlxObject.ANY, function(o1:FlxObject, o2:FlxObject){
			if (Std.is(o2, Player) || Std.is(o1, Player))
			{
				loadNextLevel();
				resetPlayerViewMode();
			}
		});
		_availableInstructionList = _levels[_currentLevelIndex]._availInstr;
	}

	private function initInstructions():Void
	{
		// Instructions that can be copied and then given to the player's instruction list.
		WALK_LEFT_INSTRUCTION = new Instruction("←", 0.5, -256, 0, true);
		WALK_RIGHT_INSTRUCTION = new Instruction("→", 0.5, 256, 0, false);
		JUMP_RIGHT_INSTRUCTION = new Instruction("↗", 1.5, 256, -768, false);
		JUMP_LEFT_INSTRUCTION = new Instruction("↖", 1.5, -256, -768, true);
		IDLE_INSTRUCTION = new Instruction("0", 0.5, 0, 0, false);
		INTERACT_INSTRUCTION = new Instruction("I", 0.5, 0, 0, false, true);
	}

	private function resetBulletGroup():Void
	{
		remove(_bulletGroup);
		_bulletGroup.kill();
		_bulletGroup = new FlxTypedGroup<FlxSprite>();
		add(_bulletGroup);
	}

	public function resetBoxes():Void
	{
		var boxItr = _boxGroup.iterator();
		for (box in boxItr)
		{
			box.resetToInitPos();
		}
		_player._holdingBox = false;
	}

	private function restartTurretGroup():Void
	{
		// To ensure bullets will always be in the same place every single run.
		var turretItr = _turretGroup.iterator();
		for (turret in turretItr)
		{
			turret.restartCooldown();
		}
	}

	private function restartLevers():Void
	{
		var turretItr = _leverGroup.iterator();
		for (lever in turretItr)
		{
			lever.setOn(true);
		}
	}

	private function resetPlayerViewMode()
	{
		resetPlayerPlayMode();
		_player.setActive(false);
		_player.alpha = 0.4;
		_player.facing = FlxObject.RIGHT;
		_player.animation.frameIndex = 0;
		_player.animation.stop();
		_playerDead = false;
		_playerDeathCountdown = 0.0;
		_inViewMode = true;
		_player.clearInstructions();
		_player.setDead(false);
		FlxG.camera.snapToTarget();
		FlxG.camera.follow(_mouseWrapper, TOPDOWN, 0.1);
		FlxG.camera.deadzone = new FlxRect(100,100,1080,520);
		setOrdersState();
	}

	private function resetPlayerPlayMode()
	{
		_player.setActive(true);
		_player.alpha = 1;
		_player.acceleration.y = 1024;
		_player.velocity.x = _player.velocity.y = 0;
		_player.setPosition(_levels[_currentLevelIndex]._playerInitX, _levels[_currentLevelIndex]._playerInitY);
		_player.giveInstructions(flattenSubInstruction());
		unsetOrdersState();
		FlxG.camera.follow(_player, PLATFORMER, 1);
		resetBulletGroup();
		restartTurretGroup();
		restartLevers();
		resetBoxes();
		// Ensure player is drawn on top of other sprites
		remove(_player);
		insert(100, _player);
		_inViewMode = false;
	}
}

package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;

// enum Instructions {
//     Idle;
//     WalkLeft;
//     WalkRight;
//     Jump;
// }

class Player extends FlxSprite {

    private var _instructionTimer:Float;
    private var _instructionList:List<Instruction>;
    private var _currentInstruction:Instruction;
    private var _speed:Float;
    private var _isActive:Bool;

    public function new() {
        super();
        loadGraphic("assets/images/duck.png", true, 100, 114);
        _instructionTimer = 0.0;
        _instructionList = new List<Instruction>();
        
        acceleration.y = 750; // Gravity is positive because Y increases downwards.
    }

    override public function update(elapsed:Float):Void {
		
        if (_isActive)
        {
            updateInstruction(elapsed);
		    movement();
        }
        super.update(elapsed);
    }

    /** 
    *   Function responsible for determining if the current instruction has ended,
    *   as well as assigning the next instruction and the instructionTimer time.
    **/
    private function updateInstruction(elapsed:Float):Void {
        _instructionTimer -= elapsed;
        if ( _instructionTimer > 0.0 )
            return;

        // Temporary until Spliced Order Queuing is done.
        if (!_instructionList.isEmpty())
        {
            _currentInstruction = _instructionList.pop();
            _speed = _currentInstruction._assignVelocityX;
            velocity.set(_speed, _currentInstruction._assignVelocityY);
            _instructionTimer = _currentInstruction._duration;
        } else
        {
            _speed = 0;
            velocity.set(0, velocity.y);
        }
    }

    public function movement():Void {
        velocity.set(_speed, velocity.y);
    }

    public function giveInstructions(newInstructions:List<Instruction>):Void
    {
        _instructionList = newInstructions;
    }

    public function clearInstructions()
    {
        _instructionList.clear();
    }

    public function setActive(active:Bool):Void
    {
        _isActive = active;
    }
}
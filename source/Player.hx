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

        setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);

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
        //Checking if absolute y vel > 20 ensures that if we're airborne we can't get new instructions(zero air maneuverabiltiy)
        if ( _instructionTimer > 0.0 || (velocity.y > 20 || velocity.y < -20))
            return;

        if (!_instructionList.isEmpty())
        {
            _currentInstruction = _instructionList.pop();
            _speed = _currentInstruction._assignVelocityX;
            velocity.set(_speed, _currentInstruction._assignVelocityY);
            _instructionTimer = _currentInstruction._duration;
            facing = _currentInstruction._facingLeft ? FlxObject.LEFT : FlxObject.RIGHT;
        } else
        {
            _speed = 0;
            velocity.set(0, velocity.y);
        }
    }

    public function movement():Void {
        velocity.set(_speed, velocity.y);
    }

    public function isFinished():Bool
    {
        return _instructionList.isEmpty() && (_instructionTimer < 0.0);
    }

    public function giveInstructions(newInstructions:List<Instruction>):Void
    {
        _instructionList = new List<Instruction>();
        for (instruction in newInstructions)
        {
            _instructionList.add(instruction.clone());
        }
    }

    public function clearInstructions()
    {
        _instructionList.clear();
        _instructionTimer = -1;
        _currentInstruction = null;
    }

    public function setActive(active:Bool):Void
    {
        _isActive = active;
    }

    public function isActive():Bool
    {
        return _isActive;
    }
}
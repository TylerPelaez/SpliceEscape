package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;

enum Instructions {
    Idle;
    WalkLeft;
    WalkRight;
    Jump;
}

class Player extends FlxSprite {

    var _instructionTimer:Float;
    var _currentInstruction:Instructions;
    var _speed:Float;


    public function new() {
        super();
        loadGraphic("assets/images/duck.png", true, 100, 114);
        _instructionTimer = 0.0;
        drag.x = 2000; // High enough to quickly stop the player.
        acceleration.y = 420; // Gravity is positive because Y increases downwards.
    }

    override public function update(elapsed:Float):Void {
		super.update(elapsed);
        updateInstruction(elapsed);
		movement();
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
        if (FlxG.keys.anyPressed([RIGHT, D])) {
            _currentInstruction = WalkRight;
            _instructionTimer = 2.0;
            _speed = 200.0;
        } else if (FlxG.keys.anyPressed([LEFT, A])) {
            _currentInstruction = WalkLeft;
            _instructionTimer = 2.0;
            _speed = -200.0;
        } else if (FlxG.keys.anyPressed([UP, W])) {
            _currentInstruction = Jump;
            _instructionTimer = 2.0;
            _speed = 0.0;
        } else {
            _currentInstruction = Idle;
            _instructionTimer = -1.0;
            _speed = 0.0;
        }
    }


    public function movement():Void {
        if (_currentInstruction != Idle) {
            velocity.set(_speed, 0);
        }
    }
}
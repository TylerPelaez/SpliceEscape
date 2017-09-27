package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import flixel.system.FlxSound;

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
    public var _interacting:Bool;
    public var _holdingBox:Bool;

    private var _musicTimer:Float;
    private var _musicOn:Bool;

    // Sounds
    private var _sndEngine:FlxSound;
    private var _sndJump:FlxSound;

    public function new() {
        super();
        loadGraphic("assets/images/duck.png", true, 100, 114);
        _instructionTimer = 0.0;
        _instructionList = new List<Instruction>();

        setFacingFlip(FlxObject.LEFT, true, false);
		setFacingFlip(FlxObject.RIGHT, false, false);
        _interacting = false;
        _holdingBox = false;

        acceleration.y = 750; // Gravity is positive because Y increases downwards.

        _musicTimer = 0.1;
        _musicOn = false;

        _sndEngine = FlxG.sound.load(AssetPaths.RobotEngine__wav);
        _sndJump = FlxG.sound.load(AssetPaths.JumpA__wav);

        #if !flash
        FlxG.sound.playMusic(AssetPaths.IntroLoop3__ogg, 1, true);
        #end
    }

    override public function update(elapsed:Float):Void {

        // Collect how much time has elapsed since last frame.
		_musicTimer += FlxG.elapsed;

        if (_isActive)
        {
            updateInstruction(elapsed);
		    movement();

            _sndEngine.play();

            // Check out whether or not the music is at a point at which it can transition into the main theme.
            // The intro loop is 14.521 seconds long, so it can transition at 7.2615 or 14.521 or 0.
            // However, since HaxeFlixel is terrible, I'll have to settle for like 7.15?
            if (_musicTimer >= 7.22 && _musicOn == false)
            {
                #if !flash
                FlxG.sound.playMusic(AssetPaths.MainLoop__ogg, 1, true);
                #end
                _musicTimer = 0.0;
                _musicOn = true;
            }

        }
        else
        {
            _sndEngine.pause();
            if (_musicTimer >= 7.22 && _musicOn == false)
            {
                #if !flash
                FlxG.sound.playMusic(AssetPaths.IntroLoop3__ogg,1,true);
                #end
                _musicTimer = 0.0;
            }
        }

        // Only need the remainder to compare to closest beat
        _musicTimer = _musicTimer % 7.2615;

        super.update(elapsed);
    }

    /** 
    *   Function responsible for determining if the current instruction has ended,
    *   as well as assigning the next instruction and the instructionTimer time.
    **/
    private function updateInstruction(elapsed:Float):Void {
        _instructionTimer -= elapsed;
        //Checking if absolute y vel > 20 ensures that if we're airborne we can't get new instructions(zero air maneuverabiltiy)
        if ( _instructionTimer > 0.0 || (Math.abs(velocity.y) > 20) )
            return;


        if (!_instructionList.isEmpty())
        {
            _currentInstruction = _instructionList.pop();
            _speed = _currentInstruction._assignVelocityX;
            velocity.set(_speed, _currentInstruction._assignVelocityY);
            _instructionTimer = _currentInstruction._duration;
            facing = _currentInstruction._facingLeft ? FlxObject.LEFT : FlxObject.RIGHT;

            // Check if the action is a jump, and if it is, make a jump sound.
            if(_currentInstruction._assignVelocityY < 0.0)
            {
                _sndJump.play();
            } else if (_currentInstruction._interact == true)
            {
                _interacting = true;
            }
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
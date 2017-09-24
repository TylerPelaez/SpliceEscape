package;

<<<<<<< HEAD
import flixel.FlxSprite;

class Instruction extends FlxSprite
{
    private var _name:String;
    private var _duration:Int;
    private var _assignVelocityX:Int;
    private var _assignVelocityY:Int;



    public function new(name:String, duration:Int, assignVelocityX:Int, assignVelocityY:Int)
    {
        super();
=======
class Instruction
{
    public var _name:String;
    public var _duration:Float;
    public var _assignVelocityX:Int;
    public var _assignVelocityY:Int;
    public var _interact:Bool;
    public var _facingLeft:Bool;

    public function new(name:String, duration:Float, assignVelocityX:Int, assignVelocityY:Int, facingLeft:Bool, interact:Bool = false)
    {
>>>>>>> ae4d98d0374b73ba975059ce023e76f2c3688b43
        _name = name;
        _duration = duration;
        _assignVelocityX = assignVelocityX;
        _assignVelocityY = assignVelocityY;
<<<<<<< HEAD
=======
        _interact = interact;
        _facingLeft = facingLeft;
    }

    public function clone(): Instruction
    {
        return new Instruction(_name, _duration, _assignVelocityX, _assignVelocityY, _facingLeft, _interact);
>>>>>>> ae4d98d0374b73ba975059ce023e76f2c3688b43
    }
}
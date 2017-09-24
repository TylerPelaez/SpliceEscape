package;

class Instruction
{
    public var _name:String;
    public var _duration:Float;
    public var _assignVelocityX:Int;
    public var _assignVelocityY:Int;
    public var _interact:Bool;

    public function new(name:String, duration:Float, assignVelocityX:Int, assignVelocityY:Int, interact:Bool = false)
    {
        _name = name;
        _duration = duration;
        _assignVelocityX = assignVelocityX;
        _assignVelocityY = assignVelocityY;
        _interact = interact;
    }

    public function clone(): Instruction
    {
        return new Instruction(_name, _duration, _assignVelocityX, _assignVelocityY, _interact);
    }
}
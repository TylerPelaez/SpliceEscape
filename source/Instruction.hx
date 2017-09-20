package;

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
        _name = name;
        _duration = duration;
        _assignVelocityX = assignVelocityX;
        _assignVelocityY = assignVelocityY;
    }
}
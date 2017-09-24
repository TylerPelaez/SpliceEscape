package;

import flixel.FlxSprite;

class Lever extends FlxSprite
{
    private var _isOn:Bool;

    public function new(posX:Int, posY:Int) 
    {
        super();
        _isOn = true;
        setPosition(posX, posY);
    }

    public function isOn():Bool{
        return _isOn;
    }
    
    public function flipLever():Void{
        _isOn = !_isOn;
    }
}
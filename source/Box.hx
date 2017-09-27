package;

import flixel.FlxSprite;

class Box extends FlxSprite
{
    public var _beingHeld:Bool;
    private var _initPosX:Int;
    private var _initPosY:Int;

    public function new(posX:Int, posY:Int)
    {
        super();
        
        _initPosX = posX;
        _initPosY = posY;
        resetToInitPos();
    }

    public function resetToInitPos():Void
    {
        setPosition(_initPosX, _initPosY);
        drop();
    }

    public function pickUp()
    {
        _beingHeld = true;
        acceleration.y = 0;
        loadGraphic("assets/images/box-2.png");
        setGraphicSize(64, 64);
        updateHitbox();
    }

    public function drop()
    {
        _beingHeld = false;
        acceleration.y = 750;
        loadGraphic("assets/images/box-1.png");
        setGraphicSize(64, 64);
        updateHitbox();
    }
}
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;

class Box extends FlxSprite
{
    public var _beingHeld:Bool;
    private var _initPosX:Int;
    private var _initPosY:Int;
    private var _sndPickup:FlxSound;
    private var _sndDrop:FlxSound;

    // private var _prevY:Float;
    // private var _prevPrevY:Float;

    public function new(posX:Int, posY:Int)
    {
        super();
        _initPosX = posX;
        _initPosY = posY;
        resetToInitPos();
        _sndPickup = FlxG.sound.load(AssetPaths.boxtake__wav);
        _sndDrop = FlxG.sound.load(AssetPaths.boxdrop__wav);
    }
    
	// override public function update(elapsed:Float):Void
    // {
        // if (_prevY == y && _prevPrevY < _prevY + .1)
        // {
            // _sndDrop.play();
        // }
        // _prevPrevY = _prevY;
        // _prevY = y;
    // }

    public function resetToInitPos():Void
    {
        setPosition(_initPosX, _initPosY);
        drop();
    }

    public function pickUp()
    {
        _beingHeld = true;
        acceleration.y = 0;
        _sndPickup.play();
    }

    public function drop()
    {
        _beingHeld = false;
        acceleration.y = 750;
    }
}
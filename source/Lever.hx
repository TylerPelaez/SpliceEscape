package;

import flixel.FlxSprite;

class Lever extends FlxSprite
{
    private var _isOn:Bool;
    public var _connectedTurret:Turret;

    public function new(posX:Int, posY:Int, turretX:Int, turretY:Int, turretFireRate:Float) 
    {
        super();
        _isOn = true;
        setPosition(posX, posY);
        _connectedTurret = new Turret(turretX, turretY, turretFireRate);
        loadGraphic("assets/images/switch.png");
        setGraphicSize(64, 64);
        updateHitbox();
    }

    public function isOn():Bool{
        return _isOn;
    }

    public function setOn(newOn:Bool):Void
    {
        _isOn = newOn;
    }

    public function flipLever():Void{
        _isOn = !_isOn;
        _connectedTurret.setActive(_isOn);
    }
}
package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxSound;

class Lever extends FlxSprite
{
    private var _isOn:Bool;
    public var _connectedTurret:Turret;
    private var _sndSwitchOn:FlxSound;
    private var _sndSwitchOff:FlxSound;

    public function new(posX:Int, posY:Int, turretX:Int, turretY:Int, turretFireRate:Float, direction:String) 
    {
        super();
        _isOn = true;
        setPosition(posX, posY);
        _connectedTurret = new Turret(turretX, turretY, turretFireRate, direction);
        loadGraphic("assets/images/switch-1.png");
        setGraphicSize(64, 64);
        updateHitbox();

        _sndSwitchOn = FlxG.sound.load(AssetPaths.ButtonDepress__wav);
        _sndSwitchOff = FlxG.sound.load(AssetPaths.ButtonRelease__wav);
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
        if (_isOn)
        {
            _sndSwitchOn.play();
        }
        else
        {
            _sndSwitchOff.play();
        }
    }
}
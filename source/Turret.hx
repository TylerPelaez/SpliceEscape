package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.system.FlxSound;

class Turret extends FlxSprite
{
    private var _isActive:Bool;
    private var _fireRate:Float;
    private var _cooldownTimer:Float;
    private static var bulletSpeed:Float;
    private var _sndShot:FlxSound;

    public function new(posX:Int, posY:Int, fireRate:Float, direction:String)
    {
        super();
        _fireRate = fireRate;
        setFacingFlip(FlxObject.LEFT, false, false);
        setFacingFlip(FlxObject.RIGHT, true, false);
         facing = (direction == "left") ? FlxObject.LEFT : FlxObject.RIGHT;

        setPosition(posX, posY);
        restartCooldown();
        _sndShot = FlxG.sound.load(AssetPaths.GunshotDraft2__wav);
    }

    override public function update(elapsed:Float)
    {
        if (_isActive)
            _cooldownTimer -= elapsed;
    }

    public function setActive(newActive:Bool)
    {
        _isActive = newActive;
        if (_isActive)
        {
            restartCooldown();
        } else
        {
            loadGraphic("assets/images/inactive_turret.png");
        }
    }

    public function restartCooldown():Void
    {
        _isActive = true;
        _cooldownTimer = 0.0;
        loadGraphic("assets/images/active_turret.png");
    }

    public function fire():FlxSprite
    {
        if (!_isActive || _cooldownTimer > 0.0)
        {
            return null;
        }
        var returnBullet = new FlxSprite();
        returnBullet.loadGraphic("assets/images/bullet.png");
        returnBullet.setPosition(facing == FlxObject.LEFT ? getPosition().x - 5 : getPosition().x + 20, getPosition().y + 30 );
        returnBullet.velocity.x = facing == FlxObject.LEFT ? -100 : 100;
        _cooldownTimer = _fireRate;

        _sndShot.play();

        return returnBullet;
    }
}
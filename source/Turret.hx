package;

import flixel.FlxSprite;

class Turret extends FlxSprite
{
    private var _isActive:Bool;
    private var _fireRate:Float;
    private var _cooldownTimer:Float;
    private static var bulletSpeed:Float;

    public function new(posX:Int, posY:Int, fireRate:Float)
    {
        super();
        _isActive = true;
        _fireRate = fireRate;
        _cooldownTimer = 0.0;
        setPosition(posX, posY);
    }

    override public function update(elapsed:Float)
    {
        if (_isActive)
            _cooldownTimer -= elapsed;
    }

    public function setActive(newActive:Bool)
    {
        _isActive = newActive;
    }

    public function fire():FlxSprite
    {
        if (!_isActive || _cooldownTimer > 0.0)
        {
            return null;
        }
        var returnBullet = new FlxSprite();
        //returnBullet.loadGraphic("assets/images/bullet.png");
        returnBullet.setPosition(getPosition().x + 30, getPosition().y + 30 );
        returnBullet.velocity.x = -100;
        _cooldownTimer = _fireRate;

        return returnBullet;
    }
}
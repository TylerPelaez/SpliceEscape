package;

class LevelData 
{
    public var _name:String;
    public var _width:Int;
    public var _height:Int;
    public var _playerInitX:Int;
    public var _playerInitY:Int;
    public var _levers:Array<Lever>;

    public function new()
    {
        _name = "";
        _width = 0;
        _height = 0;
        _playerInitX = 0;
        _playerInitY = 0;
        _levers = new Array<Lever>();
    }
}
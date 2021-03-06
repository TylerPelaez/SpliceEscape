package;

class LevelData 
{
    public var _name:String;
    public var _width:Int;
    public var _height:Int;
    public var _playerInitX:Int;
    public var _playerInitY:Int;
    public var _availInstr:Array<List<Instruction>>;
    public var _levers:Array<Lever>;
    public var _boxes:Array<Box>;

    public function new()
    {
        _name = "";
        _width = 0;
        _height = 0;
        _playerInitX = 0;
        _playerInitY = 0;
        _availInstr = new Array<List<Instruction>>();
        _levers = new Array<Lever>();
        _boxes = new Array<Box>();
    }
}
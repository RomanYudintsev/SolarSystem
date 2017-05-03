package ;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextField;
import openfl.display.Sprite;

class InfoBase extends Sprite
{
    @:isVar var info(null, set):SpaceBodyParams;

    public function set_info(value:SpaceBodyParams) {
        this.info = value;
        formatText();
        return this.info = value;
    }
    private var _t:TextField;

    public function new(width:Float, height:Float, params:SpaceBodyParams) {
        super();
        this.mouseEnabled = false;
//        this.mouseChildren = false;
        this.graphics.beginFill(0xFFFFFF,1);
        this.graphics.drawRect(0,0,width, height);
        this.graphics.endFill();
        this.x = 100;
        this.y = 100;

        _t = new TextField();
        _t.textColor = 0xFF0000;
        _t.autoSize = TextFieldAutoSize.LEFT;
        addChild(_t);

        set_info(params);
    }
    private function formatText()
    {
        _t.htmlText = info._name+'<br/>';
        _t.htmlText += info._description;
    }
}

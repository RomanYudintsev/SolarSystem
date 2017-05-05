package ;
import openfl.text.TextFormat;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextField;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import away3d.materials.lightpickers.StaticLightPicker;
import away3d.materials.TextureMaterial;
import openfl.Assets;
import away3d.textures.BitmapTexture;
import away3d.materials.SegmentMaterial;
import away3d.materials.ColorMultiPassMaterial;
import away3d.materials.OcclusionMaterial;
import away3d.materials.ColorMaterial;
import away3d.materials.MaterialBase;
import yaml.util.ObjectMap;
class SpaceBodyParams {
    public var _name:String;
    public var _selfRadius:Int;
    public var _orbitRadius:Int;
    public var _selfRotationSpeed:Float;
    public var _orbitAngle:Int;
    public var _orbitRotationSpeed:Float;
    public var _parentBodyName:String;
    public var _description:String;
    public var _skin:MaterialBase;

    public var _lightPicker:StaticLightPicker;


    public function new(    name:String,
                            skin = null,
                            selfRadius:Int = 10,
                            orbitRadius:Int = 0,
                            selfRotationSpeed:Float = 0.0,
                            orbitAngle:Int = 0,
                            orbitRotationSpeed = 0.0,
                            description = '',
                            parentBodyName = '')
    {
        _name = name;
        _skin = generateMaterial(skin);
        _selfRadius = selfRadius;
        _orbitRadius = orbitRadius;
        _selfRotationSpeed = selfRotationSpeed;
        _orbitAngle = orbitAngle;
        _orbitRotationSpeed = orbitRotationSpeed;
        _parentBodyName = parentBodyName;
        _description = description;
    }
    public function updateMaterial():Void
    {
        _skin.lightPicker = _lightPicker;
    }

    private function generateMaterial(srcValue:String = null):MaterialBase
    {
        var skinMaterial:MaterialBase = null;
        try {
            skinMaterial = new TextureMaterial(generateTexture(srcValue));
        } catch (ex : Dynamic) {}
        try {
            skinMaterial = new ColorMaterial(cast (srcValue, Int));
        } catch (ex : Dynamic) {}
        return skinMaterial;
    }

    private function generateTexture(assetName:String = null):BitmapTexture
    {
        var bitmapData = assetName != null ? Assets.getBitmapData("assets/"+assetName) : generateBitmapData();
        return new BitmapTexture(bitmapData);
    }

    private function generateBitmapData():BitmapData
    {
        var w = 64;
        var h = Math.round(w/2);
        var tmpl:Sprite = new Sprite();

        var label = new TextField();
        var tft = new TextFormat();
        tft.size = 10;
        tft.color = 0x0000FF;
        label.text = 'test';
        label.setTextFormat(tft, 0, label.length);
        label.autoSize = TextFieldAutoSize.LEFT;
        label.x = w/2 - label.width/2;
        label.y = h/2 - label.height/2;

        tmpl.graphics.beginFill(0xFFFFFF, 1);
        tmpl.graphics.drawRect(0,0, w, h);
        tmpl.graphics.endFill();

        tmpl.graphics.beginFill(0x00FF00, 1);
        tmpl.graphics.drawCircle(w/2,h/2, h/4);
        tmpl.graphics.endFill();


        tmpl.addChild(label);

        var bd = new BitmapData(w, h, true, 0x0);
        bd.draw(tmpl);
        return bd;
    }

    public static function newFromYaml(infoYaml:AnyObjectMap):SpaceBodyParams
    {
        return new SpaceBodyParams( infoYaml.get('name'),
                                    infoYaml.get('skin'),
                                    infoYaml.get('selfRadius'),
                                    infoYaml.get('orbitRadius'),
                                    infoYaml.get('selfRotationSpeed'),
                                    infoYaml.get('orbitAngle'),
                                    infoYaml.get('orbitRotationSpeed'),
                                    infoYaml.get('description'),
                                    infoYaml.get('parent')
                                  );
    }
}

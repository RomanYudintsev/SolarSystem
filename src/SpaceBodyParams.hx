package ;
import yaml.util.ObjectMap;
import away3d.materials.MaterialBase;
class SpaceBodyParams {
    public var _name:String;
    public var _material:MaterialBase;
    public var _selfRadius:Int;
    public var _orbitRadius:Int;
    public var _selfRotationSpeed:Float;
    public var _orbitAngle:Int;
    public var _orbitRotationSpeed:Float;
    public var _parentBodyName:String;


    public function new(    name:String,
                            material:MaterialBase = null,
                            selfRadius:Int = 10,
                            orbitRadius:Int = 0,
                            selfRotationSpeed:Float = 0.0,
                            orbitAngle:Int = 0,
                            orbitRotationSpeed = 0.0,
                            parentBodyName = '')
    {
        _name = name;
        _material = material;
        _selfRadius = selfRadius;
        _orbitRadius = orbitRadius;
        _selfRotationSpeed = selfRotationSpeed;
        _orbitAngle = orbitAngle;
        _orbitRotationSpeed = orbitRotationSpeed;
        _parentBodyName = parentBodyName;
    }

    public static function newFromYaml(infoYaml:AnyObjectMap):SpaceBodyParams
    {
        return new SpaceBodyParams( infoYaml.get('name'),
                                    null,
                                    infoYaml.get('selfRadius'),
                                    infoYaml.get('orbitRadius'),
                                    infoYaml.get('selfRotationSpeed'),
                                    infoYaml.get('orbitAngle'),
                                    infoYaml.get('orbitRotationSpeed'),
                                    infoYaml.get('parent')
                                  );
    }
}

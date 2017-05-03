package ;
import away3d.primitives.*;
import away3d.entities.Mesh;

class SpaceBodyBase extends Mesh
{
    private var _params:SpaceBodyParams;
    private var _orbitRotation:Float = 0.0;

    public function new(params:SpaceBodyParams)
    {
        _params = params;
        super(new SphereGeometry(_params._selfRadius), _params._skin);
        mouseEnabled = true;
    }

    override public function get_name():String
    {
        return _params._name;
    }

    public function get_src_params():SpaceBodyParams
    {
        return _params;
    }

    public function renderStep():Void
    {
        rotationY += _params._selfRotationSpeed;
        _orbitRotation += _params._orbitRotationSpeed;
        x = _params._orbitRadius * Math.sin(Math.PI/180 * _orbitRotation % 360);
        z = _params._orbitRadius * Math.cos(Math.PI/180 * _orbitRotation % 360);
        y = z * Math.tan(Math.PI/180 * _params._orbitAngle % 360);
    }
}

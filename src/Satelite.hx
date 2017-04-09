package ;
class Satelite extends SpaceBodyBase
{
    private var _parentPlaneta:Planeta;

    public function new(parentPlaneta:Planeta, params:SpaceBodyParams)
    {
        _parentPlaneta = parentPlaneta;
        super(params);
    }
    override public function renderStep():Void
    {
        super.renderStep();
        x += _parentPlaneta.x;
        z += _parentPlaneta.z;
    }
}

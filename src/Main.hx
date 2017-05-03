package;

import away3d.textures.CubeTextureBase;
import away3d.lights.LightProbe;
import away3d.lights.DirectionalLight;
import away3d.materials.lightpickers.StaticLightPicker;
import yaml.util.ObjectMap;
import yaml.Yaml;
import openfl.Assets;
import openfl.ui.Keyboard;
import openfl.events.MouseEvent;
import openfl.events.KeyboardEvent;
import away3d.controllers.HoverController;
import away3d.controllers.HoverController;
import away3d.lights.PointLight;
import away3d.materials.ColorMultiPassMaterial;
import away3d.materials.ColorMaterial;
import Planeta;
import away3d.materials.MaterialBase;
import away3d.entities.Sprite3D;
import away3d.events.MouseEvent3D;
import away3d.primitives.SphereGeometry;
import away3d.containers.View3D;
import away3d.debug.*;
import away3d.entities.Mesh;
import away3d.materials.TextureMaterial;
import away3d.primitives.PlaneGeometry;
import away3d.utils.Cast;

import openfl.display.StageScaleMode;
import openfl.display.StageAlign;
import openfl.display.Sprite;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.geom.Vector3D;
import openfl.Lib;
import haxe.Timer;

class Main extends Sprite
{
    //engine variables
    private var _view:View3D;

    private var _solar:Star;

    private var _mercury:Planeta;

    private var _venus:Planeta;
    private var _earth:Planeta;
    private var _mars:Planeta;

    private var _luna:Satelite;

    private var _phobos:Satelite;
    private var _deimos:Satelite;

    private var _system:Array<SpaceBodyBase> = [];

    private var _cameraController:HoverController;

    //navigation variables
    var move:Bool = false;
    var lastPanAngle:Float;
    var lastTiltAngle:Float;
    var lastMouseX:Float;
    var lastMouseY:Float;
    var tiltSpeed:Float = 4;
    var panSpeed:Float = 4;
    var distanceSpeed:Float = 4;
    var tiltIncrement:Float = 0;
    var panIncrement:Float = 0;
    var distanceIncrement:Float = 0;

    var _paused:Bool = false;
    var _paused_click:Bool = false;

    var lightPicker:StaticLightPicker;
    var light1 : PointLight = new PointLight();
    var light2 : LightProbe = new LightProbe(new CubeTextureBase());

    /**
	 * Constructor
	 */
    public function new ()
    {
        super();

        var _systemSource:AnyObjectMap = Yaml.parse(Assets.getText("assets/SolarSystem.yaml"));

        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;

        //setup the view
        _view = new View3D();
        this.addChild(_view);

        //setup the camera
        _view.camera.z = -500;
        _view.camera.y = 200;

        _cameraController = new HoverController( _view.camera, null, 180, 20, 200, 0);

        light1.x = 0;
        light1.y = 0;
        light1.color = 0xFFFFFF;
//        light1.castsShadows = true;
        light1.ambient = .1;
        _view.scene.addChild(light1);

//        light2.position = _view.camera.position;
//        light2.color = 0xFFFFFF;
//        _view.scene.addChild(light2);

        lightPicker = new StaticLightPicker([light1/*, light2*/]);

        for (key in _systemSource.keys())
        {
            var group:Array<Dynamic> = cast _systemSource.get(key);
            for (item in group)
            {
                var params = SpaceBodyParams.newFromYaml(item);
                switch key {
                    case "stars": addStar(params);
                    case "planets":
                        {
                            params._lightPicker = lightPicker;
                            params.updateMaterial();
                            addPlaneta(params);
                        }
                    case "satelites":
                        {
                            params._lightPicker = lightPicker;
                            params.updateMaterial();
                            var parentPlaneta:SpaceBodyBase = getSpaceBodyByName(params._parentBodyName);
                            if (parentPlaneta != null)
                                addSatelite(cast (parentPlaneta, Planeta), params);
                        }
                    default: trace("unknow group", key);
                }

            }
        }
        var sphere:SpaceBodyBase;
        for ( sphere in _system)
        {
            _view.scene.addChild(sphere);
        }

        //setup the render loop
        initListeners();

        // stats
        this.addChild(new away3d.debug.AwayFPS(_view, 10, 10, 0xffffff, 3));
    }

    private function addStar(starParams:SpaceBodyParams):Star
    {
        var star:Star = new Star(starParams);
        addSpaceBody(star);
        return star;
    }

    private function addPlaneta(planetaParams:SpaceBodyParams):Planeta
    {
        var planeta:Planeta = new Planeta(planetaParams);
        addSpaceBody(planeta);
        return planeta;
    }

    private function addSatelite(parentPlaneta:Planeta, sateliteParams:SpaceBodyParams):Satelite
    {
        var satelite:Satelite = new Satelite(parentPlaneta, sateliteParams);
        addSpaceBody(satelite);
        return satelite;
    }

    private function addSpaceBody(body:SpaceBodyBase):SpaceBodyBase
    {
        body.addEventListener(MouseEvent3D.CLICK, sphereClickHandler);
        body.addEventListener(MouseEvent3D.MOUSE_OVER, sphereMouseOverHandler);
        body.addEventListener(MouseEvent3D.MOUSE_OUT, sphereMouseOverHandler);
        _system.push(body);
        return body;
    }

    private function getSpaceBodyByName(bodyName:String):SpaceBodyBase
    {
        return _system.filter(function (body : SpaceBodyBase) return body.name == bodyName)[0];
    }

    private function sphereMouseOverHandler(event:MouseEvent3D):Void
    {
        _focusOn = cast (event.currentTarget, SpaceBodyBase);
        if (!_paused_click)
            _paused = !_paused;
    }
    private function sphereMouseOutHandler(event:MouseEvent3D):Void
    {
        if (_paused_click)
            return;
        _paused = !_paused;
    }
    private function sphereClickHandler(event:MouseEvent3D):Void
    {
        if (_focusOn == _focusOnClick)
        {
            _paused_click = !_paused_click;
            if (_paused_click)
            {
                _focusOnClick = _focusOn;
            } else {
                _focusOnClick = null;
            }
        } else {
            _paused_click = true;
            _focusOnClick = _focusOn;
        }
    }
    /**
	 * render loop
	 */
    private static var ctr:Float = 0;
    private var _focusOn:SpaceBodyBase;
    private var _focusOnClick:SpaceBodyBase;

    private var _info:InfoBase;
    private function _onEnterFrame(e:Event):Void
    {
        if (_paused)
        {
            if (_info == null)
            {
                _info = new InfoBase(500, 500, _focusOn.get_src_params());
                this.addChild(_info);
            }
            _info.set_info(_focusOn.get_src_params());
        } else {
            if (_info != null)
            {
                this.removeChild(_info);
                _info = null;
            }
            var sphere:SpaceBodyBase;
            for ( sphere in _system)
            {
                sphere.renderStep();
            }
        }
        // Update camera.
        if (move) {
            _cameraController.panAngle = 0.3*(stage.mouseX - lastMouseX) + lastPanAngle;
            _cameraController.tiltAngle = 0.3*(stage.mouseY - lastMouseY) + lastTiltAngle;
        }
        _cameraController.panAngle += panIncrement;
        _cameraController.tiltAngle += tiltIncrement;
        _cameraController.distance += distanceIncrement;

        _view.render();
    }

    /**
	 * stage listener for resize events
	 */
//    private function onResize(event:Event = null):Void
//    {
//        _view.width = stage.stageWidth;
//        _view.height = stage.stageHeight;
//    }


    /**
	 * Initialise the listeners
	 */
    private function initListeners()
    {
        addEventListener(Event.ENTER_FRAME, _onEnterFrame);
        _view.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
        _view.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
        stage.addEventListener(Event.RESIZE, onResize);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
        stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        onResize();
    }

    /**
	 * Key down listener for camera control
	 */
    private function onKeyDown(event:KeyboardEvent)
    {
        switch (event.keyCode) {
            case Keyboard.UP, Keyboard.W:
                tiltIncrement = tiltSpeed;
            case Keyboard.DOWN, Keyboard.S:
                tiltIncrement = -tiltSpeed;
            case Keyboard.LEFT, Keyboard.A:
                panIncrement = panSpeed;
            case Keyboard.RIGHT, Keyboard.D:
                panIncrement = -panSpeed;
            case Keyboard.Z:
                distanceIncrement = distanceSpeed;
            case Keyboard.X:
                distanceIncrement = -distanceSpeed;
        }
    }

    /**
	 * Key up listener for camera control
	 */
    private function onKeyUp(event:KeyboardEvent)
    {
        switch (event.keyCode) {
            case Keyboard.UP, Keyboard.W, Keyboard.DOWN, Keyboard.S:
                tiltIncrement = 0;
            case Keyboard.LEFT, Keyboard.A, Keyboard.RIGHT, Keyboard.D:
                panIncrement = 0;
            case Keyboard.Z, Keyboard.X:
                distanceIncrement = 0;
        }
    }

    /**
	 * Mouse stage leave listener for navigation
	 */
    private function onStageMouseLeave(event:Event)
    {
        move = false;
        stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
    }

    /**
	 * stage listener for resize events
	 */
    private function onResize(event:Event = null)
    {
        _view.width = stage.stageWidth;
        _view.height = stage.stageHeight;
    }

    /**
	 * Mouse up listener for navigation
	 */
    private function onMouseUp(event:MouseEvent)
    {
        move = false;
        stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
    }

    /**
	 * Mouse down listener for navigation
	 */
    private function onMouseDown(event:MouseEvent)
    {
        move = true;
        lastPanAngle = _cameraController.panAngle;
        lastTiltAngle = _cameraController.tiltAngle;
        lastMouseX = stage.mouseX;
        lastMouseY = stage.mouseY;
        stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
    }
}

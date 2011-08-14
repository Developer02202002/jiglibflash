package {
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.entities.Mesh;
	import away3d.events.LoaderEvent;
	import away3d.lights.PointLight;
	import away3d.loaders.Loader3D;
	import away3d.loaders.parsers.OBJParser;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.ColorMaterial;

	import jiglib.cof.JConfig;
	import jiglib.debug.Stats;
	import jiglib.geometry.JTriangleMesh;
	import jiglib.math.*;
	import jiglib.physics.*;
	import jiglib.physics.constraint.*;
	import jiglib.plugin.away3d4.*;
	import jiglib.vehicles.JCar;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.net.URLRequest;
	import flash.ui.Keyboard;

	/**
	 * ...
	 * @author Muzer
	 */
	public class Away3DTriangleMesh extends Sprite {
		[Embed(source="res/fskin.jpg")]
		private var CarSkin : Class;
		private var view : View3D;
		private var mylight : PointLight;
		private var containerCity : ObjectContainer3D;
		private var containerCar : ObjectContainer3D;
		private var carMaterial : BitmapMaterial;
		private var steerFR : ObjectContainer3D;
		private var steerFL : ObjectContainer3D;
		private var wheelFR : Mesh;
		private var wheelFL : Mesh;
		private var wheelBR : Mesh;
		private var wheelBL : Mesh;
		private var physics : Away3D4Physics;
		private var ballBodies : Vector.<RigidBody>;
		private var boxBodies : Vector.<RigidBody>;
		private var bridgeBodies : Vector.<RigidBody>;
		private var bridges : Vector.<HingeJoint>;
		private var carBody : JCar;

		// private var base_url:String;
		public function Away3DTriangleMesh() {
			this.addEventListener(Event.ADDED_TO_STAGE, init);
		}

		private function init(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, init);

			init3D();
			this.addChild(new Stats(view, physics));
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		private function init3D() : void {
			view = new View3D();
			addChild(view);

			mylight = new PointLight();
			view.scene.addChild(mylight);
			mylight.color = 0xffffff;
			mylight.y = 5000;
			mylight.z = -5000;

			// init physics
			JConfig.solverType = "FAST";
			physics = new Away3D4Physics(view, 8);

			var _loader : Loader3D = new Loader3D();
			_loader.load(new URLRequest('res/scene.obj'), new OBJParser());
			_loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onSceneResourceComplete);
			containerCity = ObjectContainer3D(_loader);
			view.scene.addChild(containerCity);

			carMaterial = new BitmapMaterial(Bitmap(new CarSkin()).bitmapData);
			carMaterial.lights = [mylight];

			_loader = new Loader3D();
			_loader.load(new URLRequest('res/car.obj'), new OBJParser());
			_loader.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onCarResourceComplete);
			containerCar = ObjectContainer3D(_loader);
			view.scene.addChild(containerCar);
		}

		private function onSceneResourceComplete(event : LoaderEvent) : void {
			var materia : ColorMaterial = new ColorMaterial(0x77ee77);
			materia.lights = [mylight];
			var mesh : Mesh = Mesh(containerCity.getChildAt(0));
			mesh.geometry.scale(300);
			mesh.material = materia;

			// create the triangle mesh
			var triangleMesh : JTriangleMesh = physics.createMesh(mesh, new Vector3D(), new Matrix3D(), 10, 10);

			// create rigid bogies
			materia = new ColorMaterial(0xeeee00);
			materia.lights = [mylight];
			ballBodies = new Vector.<RigidBody>();
			for (var i : int = 0; i < 15; i++) {
				ballBodies[i] = physics.createSphere(materia, 50);
				ballBodies[i].moveTo(new Vector3D(-1000 + 2500 * Math.random(), 1000 + 1000 * Math.random(), -1000 + 2500 * Math.random()));
			}

			boxBodies = new Vector.<RigidBody>();
			for (i = 0; i < 15; i++) {
				boxBodies[i] = physics.createCube(materia, 100, 80, 60);
				boxBodies[i].moveTo(new Vector3D(-1000 + 2500 * Math.random(), 1000 + 1000 * Math.random(), -1000 + 2500 * Math.random()));
			}

			// create the bridge
			bridges = new Vector.<HingeJoint>();
			bridgeBodies = new Vector.<RigidBody>();
			for (i = 0; i < 5; i++) {
				bridgeBodies[i] = physics.createCube(materia, 260, 30, 200);
				bridgeBodies[i].moveTo(new Vector3D(265 * i - 1100, 900, 1500));
				bridgeBodies[i].disableCollisions(triangleMesh);
				for each (var other:RigidBody in bridgeBodies) {
					// disable collisions between each chainBodies
					bridgeBodies[i].disableCollisions(other);
				}
			}
			var len : int = bridgeBodies.length;
			// var pos1:Vector3D;
			// var pos2:Vector3D;
			for (i = 1; i < len; i++ ) {
				// set up the hinge joints.
				bridges[i - 1] = new HingeJoint(bridgeBodies[i - 1], bridgeBodies[i], Vector3D.Z_AXIS, new Vector3D(130, 0, 0), 100, 50, 50, 0.1, 0.5);
			}

			new JConstraintWorldPoint(bridgeBodies[0], new Vector3D(-120, 0, 100), new Vector3D(-1200, 920, 1600));
			new JConstraintWorldPoint(bridgeBodies[0], new Vector3D(-120, 0, -100), new Vector3D(-1200, 920, 1400));
			new JConstraintWorldPoint(bridgeBodies[4], new Vector3D(120, 0, 100), new Vector3D(100, 950, 1600));
			new JConstraintWorldPoint(bridgeBodies[4], new Vector3D(120, 0, -100), new Vector3D(100, 950, 1400));
		}

		private function onCarResourceComplete(event : LoaderEvent) : void {
			var mesh : Mesh;
			for (var i : int = 0; i < containerCar.numChildren; ++i) {
				mesh = Mesh(containerCar.getChildAt(i));
				mesh.geometry.scale(40);
				mesh.material = carMaterial;
			}

			// create car
			carBody = new JCar(null);
			carBody.setCar(45, 1, 500);
			carBody.chassis.mass = 10;
			carBody.chassis.sideLengths = new Vector3D(105, 40, 220);
			carBody.chassis.moveTo(new Vector3D(500, 100, -500));
			physics.addBody(carBody.chassis);

			carBody.setupWheel("WheelFL", new Vector3D(-48, -20, 68), 1.3, 1.3, 6, 20, 0.5, 0.5, 2);
			carBody.setupWheel("WheelFR", new Vector3D(48, -20, 68), 1.3, 1.3, 6, 20, 0.5, 0.5, 2);
			carBody.setupWheel("WheelBL", new Vector3D(-48, -20, -84), 1.3, 1.3, 6, 20, 0.5, 0.5, 2);
			carBody.setupWheel("WheelBR", new Vector3D(48, -20, -84), 1.3, 1.3, 6, 20, 0.5, 0.5, 2);

			steerFL = new ObjectContainer3D();
			steerFL.position = new Vector3D(-48, -20, 68);
			containerCar.addChild(steerFL);

			steerFR = new ObjectContainer3D();
			steerFR.position = new Vector3D(48, -20, 68);
			containerCar.addChild(steerFR);

			wheelFL = Mesh(containerCar.getChildAt(0));
			steerFL.addChild(wheelFL);

			wheelFR = Mesh(containerCar.getChildAt(3));
			steerFR.addChild(wheelFR);

			wheelBL = Mesh(containerCar.getChildAt(1));
			wheelBL.position = new Vector3D(-48, -20, -84);

			wheelBR = Mesh(containerCar.getChildAt(2));
			wheelBR.position = new Vector3D(48, -20, -84);
		}

		private function keyDownHandler(event : KeyboardEvent) : void {
			switch(event.keyCode) {
				case Keyboard.UP:
					carBody.setAccelerate(1);
					break;
				case Keyboard.DOWN:
					carBody.setAccelerate(-1);
					break;
				case Keyboard.LEFT:
					carBody.setSteer(["WheelFL", "WheelFR"], -1);
					break;
				case Keyboard.RIGHT:
					carBody.setSteer(["WheelFL", "WheelFR"], 1);
					break;
				case Keyboard.SPACE:
					carBody.setHBrake(1);
					break;
			}
		}

		private function keyUpHandler(event : KeyboardEvent) : void {
			switch(event.keyCode) {
				case Keyboard.UP:
					carBody.setAccelerate(0);
					break;
				case Keyboard.DOWN:
					carBody.setAccelerate(0);
					break;
				case Keyboard.LEFT:
					carBody.setSteer(["WheelFL", "WheelFR"], 0);
					break;
				case Keyboard.RIGHT:
					carBody.setSteer(["WheelFL", "WheelFR"], 0);
					break;
				case Keyboard.SPACE:
					carBody.setHBrake(0);
			}
		}

		private function updateCarSkin() : void {
			if (!carBody)
				return;

			// update car transform
			containerCar.transform = JMatrix3D.getAppendMatrix3D(carBody.chassis.currentState.orientation, JMatrix3D.getTranslationMatrix(carBody.chassis.currentState.position.x, carBody.chassis.currentState.position.y, carBody.chassis.currentState.position.z));

			// update wheels roll
			wheelFL.pitch(carBody.wheels["WheelFL"].getRollAngle());
			wheelFR.pitch(carBody.wheels["WheelFR"].getRollAngle());
			wheelBL.pitch(carBody.wheels["WheelBL"].getRollAngle());
			wheelBR.pitch(carBody.wheels["WheelBR"].getRollAngle());

			// update wheel steer
			steerFL.rotationY = carBody.wheels["WheelFL"].getSteerAngle();
			steerFR.rotationY = carBody.wheels["WheelFR"].getSteerAngle();

			// update wheel suspension
			steerFL.y = carBody.wheels["WheelFL"].getActualPos().y;
			steerFR.y = carBody.wheels["WheelFR"].getActualPos().y;
			wheelBL.y = carBody.wheels["WheelBL"].getActualPos().y;
			wheelBR.y = carBody.wheels["WheelBR"].getActualPos().y;

			view.camera.position = containerCar.position.add(new Vector3D(0, 1200, -1000));
			view.camera.lookAt(containerCar.position);
		}

		private function onEnterFrame(event : Event) : void {
			view.render();
			updateCarSkin();
			physics.step(0.1);
		}
	}
}
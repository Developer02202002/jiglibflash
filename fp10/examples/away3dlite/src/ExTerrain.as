package
{
	import away3dlite.materials.WireframeMaterial;
	import away3dlite.templates.PhysicsTemplate;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	import jiglib.geometry.JTerrain;
	import jiglib.math.*;
	import jiglib.physics.*;
	import jiglib.plugin.away3dlite.Away3DLitePhysics;
	import jiglib.plugin.away3dlite.TerrainData;

	[SWF(backgroundColor="#666666", frameRate="30", quality="MEDIUM", width="800", height="600")]
	/**
	 * Example : Terrain, (Not working 100% yet sry ;p)
	 *
	 * @see http://away3d.googlecode.com/svn/branches/lite/libs
	 * @see http://jiglibflash.googlecode.com/svn/trunk/fp10/src
	 *
	 * @author katopz
	 */
	public class ExTerrain extends PhysicsTemplate
	{
		[Embed(source="assets/heightmap_invert.png")]
		private var TERRIAN_MAP:Class;
		private var terrainBMD:Bitmap = new TERRIAN_MAP;

		private var terrain:JTerrain;

		private var _boxBodies:Array;

		protected override function onInit():void
		{
			title += " | JigLib Physics | Terrain | Click to jump";

			physics = new Away3DLitePhysics(scene, 10);

			// terrain
			var _terrainData:TerrainData = new TerrainData(terrainBMD.bitmapData, 256);
			terrain = physics.createTerrain(_terrainData, new WireframeMaterial, 1000, 1000, 32, 32);

			camera.y = -1000;

			//player
			init3D();
		}

		private function init3D():void
		{
			// Layer
			var layer:Sprite = new Sprite();
			view.addChild(layer);

			_boxBodies = [];
			var totalBox:int = 8;
			var i:int;
			for (i = 0; i < totalBox; i++)
			{
				_boxBodies[i] = physics.createCube(new WireframeMaterial(0xFFFFFF * Math.random()), 25, 25, 25);
				_boxBodies[i].moveTo(new Vector3D(100 * Math.cos(i * 2 * Math.PI / totalBox), -320, 100 * Math.sin(i * 2 * Math.PI / totalBox)));
			}

			for (i = 0; i < totalBox; i++)
			{
				var temp:* = physics.createSphere(new WireframeMaterial(0xFFFFFF * Math.random()), 25);
				temp.moveTo(new Vector3D(200 * Math.cos(i * 2 * Math.PI / totalBox), -320, 200 * Math.sin(i * 2 * Math.PI / totalBox)));
			}

			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMousePress);
		}

		private function handleMousePress(event:MouseEvent):void
		{
			for each (var box:RigidBody in _boxBodies)
				box.addWorldForce(new Vector3D(100 * Math.random() - 100 * Math.random(), -100, 100 * Math.random() - 100 * Math.random()), box.currentState.position);
		}

		override protected function onPreRender():void
		{
			//run
			physics.step();

			//system
			camera.lookAt(new Vector3D);
		}
	}
}
## Introduction ##

This is a short & rough document describing how the rearchitected API works.

## 'Plugin' package ##

The new plugin package contains the facade class (AbstractPhysics) and two implentations: for Papervision3D and for Away3D. To initialize the physics use the class for the proper 3d engine. Ex, for Papervision3D it looks like that:

```
physics = new Papervision3DPhysics(scene, 10);
```

Where `scene` refers to the Papervision3D scene object. The Away3D version expects its `View3D` class instead.

The second argument defines the speed of the simulation - it might be discarded in future versions.

## Working with the facade object ##

The main idea of having a facade object is that it controls the simulation & allows to advance the step at each frame in a simple way - using the `step()` method, hiding the complexity of the implementation. It also offers an interface to add bodies to the physics world. In the simplest possible scenario, once you create the physics object, you just need call `step()` at each frame before rendering. If you use Pv3D and extends the `BasicView` class, it would look something like this:

```
protected override function onRenderTick(event:Event = null):void {
   physics.step();
   super.onRenderTick(event);
}
```

Other than that, the implementations for the 3d engines offer a couple of methods that facilitates the creation of physics-enabled primitives - like cubes & spheres. For example, to create a physics-enabled sphere use this method of the `Papervision3DPhysics` class:

```
public function createSphere(material:MaterialObject3D, radius:Number=100, segmentsW:int=8, segmentsH:int = 6):RigidBody
```

You should notice that the argument list here is exactly the same in the default Sphere constructor in Pv3d - we tried to follow this rule for every other creational method. What this method does is that it creates this sphere, but it also creates a RigidBody which is a representation of the sphere in the physics engine.

The method return an instance of this RigidBody class. Later, if you want to access the Pv3D sphere you can do it like this:

```
var sphere:RigidBody = physics.createSphere(new WireframeMaterial(0xffffff), 30, 6, 6);
physics.getMesh(sphere).material = new WireframeMaterial(0xff0000);
```

## Custom 3d objects ##

JigLib currently implements a few primitives like: sphere, cube and plane. But on the 3D engine side, we do not need to use only those - ex. a more or less irregular mesh of an apple can be represented on the physics side by a sphere. To create a custom object use something like that:

```
var apple:DisplayObject3D = new DAE("apple.dae");
scene.addChild(apple);
var japple:RigidBody = new JSphere(new Pv3dMesh(apple), 30);
japple.y = 700;
japple.rotationZ = Math.PI / 4; // Use radians here
physics.addBody(japple);
```

The `Pv3dMesh` class (and its Away3D version - `Away3DMesh`) is a wrapper for meshes. They both implement ISkin3D interface. This interface is a very simple abstraction of those functions & properties of a mesh that JigLib needs to run the simulation. Whenever

## RigidBody ##

Every object in the physics world is of type RigidBody exactly the same way as every mesh in Pv3D is of type DisplayObject3D. The RigidBody class has been enriched with several properties that should make it easier to use.

The properties are as follows: `x`, `y`, `z`, `rotationX`, `rotationY` and `rotationZ`. Using this properties will update both the object in the 3d world and its representation in the physics world.

IMPORTANT. Using those properties directly on the physics-enabled mesh will have no effect.
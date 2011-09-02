package agt.core
{

	import agt.entities.CharacterEntity;
	import agt.entities.DynamicEntity;

	import away3d.containers.Scene3D;

	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;

	import flash.geom.Vector3D;
	import flash.utils.getTimer;

	public class PhysicsScene3D extends Scene3D
	{
		private var _physicsWorld:AWPDynamicsWorld;
		// keep this at 1/60 or 1/120
		private var _fixedTimeStep:Number = 1/60; // TODO: add option to not use adaptive time step?
		// time since last timestep
		private var _deltaTime:Number;
		private var _maxSubStep:int = 2;
		private var _lastTimeStep:Number = -1;
		private var _characterEntities:Vector.<CharacterEntity>;

		private var _allObjectsCollisionGroup:int = -1;
		private var _sceneObjectsCollisionGroup:int = 1;
		private var _characterDynamicObjectsCollisionGroup:int = 2;
		private var _characterKinematicObjectsCollisionGroup:int = 4;

		public function PhysicsScene3D()
		{
			super();
			initPhysics();

			_characterEntities = new Vector.<CharacterEntity>();
		}

		private function initPhysics():void
		{
			// init world
			_physicsWorld = AWPDynamicsWorld.getInstance();
			_physicsWorld.initWithDbvtBroadphase();
			_physicsWorld.collisionCallbackOn = true;
			_physicsWorld.gravity = new Vector3D(0, -10, 0);
		}

		public function addDynamicEntity(entity:DynamicEntity):void
		{
			// add visual part
			addChild(entity.container);

			// add physics part
			_physicsWorld.addRigidBodyWithGroup(entity.body, _sceneObjectsCollisionGroup, _allObjectsCollisionGroup | _characterDynamicObjectsCollisionGroup);
		}

		public function removeDynamicEntity(entity:DynamicEntity):void
		{
			// remove physics part
			_physicsWorld.removeRigidBody(entity.body);

			// remove visual part
			removeChild(entity.container);
		}

		public function addCharacterEntity(entity:CharacterEntity):void
		{
			// add visual part
			addChild(entity.container);
			addChild(entity.dynamicCapsuleMesh);

			// add physics kinematics part
			_physicsWorld.addCharacter(entity.character, _characterKinematicObjectsCollisionGroup, _sceneObjectsCollisionGroup);

			// add physics dynamics part
			_physicsWorld.addRigidBodyWithGroup(entity.body, _characterDynamicObjectsCollisionGroup, _sceneObjectsCollisionGroup);

			// register player
			_characterEntities.push(entity);
		}

		public function updatePhysics():void
		{
			// kinematic entities update
			var loop:uint = _characterEntities.length;
			for(var i:uint; i < loop; ++i)
				_characterEntities[i].update();

			// world update
			if(_lastTimeStep == -1) _lastTimeStep = getTimer();
			_deltaTime = (getTimer() - _lastTimeStep)/1000;
			_lastTimeStep = getTimer();
			_physicsWorld.step(_deltaTime, _maxSubStep, _fixedTimeStep);
		}
	}
}

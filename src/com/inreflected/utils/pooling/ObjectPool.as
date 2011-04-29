package com.inreflected.utils.pooling
{
	import flash.utils.getQualifiedClassName;
	
	/**
	 * @author Pavel fljot
	 * 
	 * "inspired" by Jonnie Hallman 
	 * @link http://destroytoday.com
	 * @link https://github.com/destroytoday
	 * 
	 * Added some optimization and changes.
	 */
	public class ObjectPool
	{
		// --------------------------------------------------------------------------
		//
		// Properties
		//
		// --------------------------------------------------------------------------
		
		protected var _type:Class;
		protected var objectList:Array = [];
		

		// --------------------------------------------------------------------------
		//
		// Constructor
		//
		// --------------------------------------------------------------------------
		
		public function ObjectPool(type:Class, size:uint = 0)
		{
			_type = type;

			if (size > 0)
			{
				allocate(size);
			}
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Getters / Setters
		//
		// --------------------------------------------------------------------------
		
		public function get type():Class
		{
			return _type;
		}


		public function get numObjects():uint
		{
			return objectList.length;
		}
		
		
		
		// --------------------------------------------------------------------------
		//
		// Public Methods
		//
		// --------------------------------------------------------------------------
		
		public function hasObject(object:Object):Boolean
		{
			return objectList.indexOf(object) > -1;
		}


		public function getObject():*
		{
			return numObjects > 0 ? objectList.pop() : createObject();
		}


		public function disposeObject(object:Object):void
		{
			if (!(object is type))
			{
				throw new TypeError("Disposed object type mismatch. Expected " + type + ", got " + getQualifiedClassName(object));
			}

			addObject(object);
		}


		public function empty():void
		{
			objectList.length = 0;
		}
		


		//--------------------------------------------------------------------------
		//
		// Protected methods
		//
		//--------------------------------------------------------------------------
		
		protected function addObject(object:Object):*
		{
			if (!hasObject(object))
				objectList[objectList.length] = object;

			return object;
		}


		protected function createObject():*
		{
			return new type();
		}


		protected function allocate(value:uint):void
		{
			var n:int = value - numObjects;
			
			while (n-- > 0)
			{
				addObject(createObject());
			}
		}
	}
}
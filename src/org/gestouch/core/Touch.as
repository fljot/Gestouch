package org.gestouch.core
{
	import flash.display.InteractiveObject;


	/**
	 * TODO:
	 * - maybe add "phase" (began, moved, stationary, ended)?
	 * 
	 * @author Pavel fljot
	 */
	public class Touch
	{
		/**
		 * Touch point ID.
		 */
		public var id:uint;
		/**
		 * The original event target for this touch (touch began with).
		 */
		public var target:InteractiveObject;
		
		public var x:Number;
		public var y:Number;
		public var sizeX:Number;
		public var sizeY:Number;
		public var pressure:Number;
		public var time:uint;
		
//		public var touchBeginPos:Point;
//		public var touchBeginTime:uint;
//		public var moveOffset:Point;
//		public var lastMove:Point;
//		public var velocity:Point;
		
		
		public function Touch(id:uint = 0)
		{
			this.id = id;
		}
		
		
		public function clone():Touch
		{
			var touch:Touch = new Touch(id);
			touch.x = x;
			touch.y = y;
			touch.target = target;
			touch.sizeX = sizeX;
			touch.sizeY = sizeY;
			touch.pressure = pressure;
			touch.time = time;
			
			return touch;
		}
		
		
		public function toString():String
		{
			return "Touch [id: " + id + ", x: " + x + ", y: " + y + ", ...]";
		}
	}
}
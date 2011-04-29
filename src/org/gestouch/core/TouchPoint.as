package org.gestouch.core
{
	import flash.geom.Point;


	/**
	 * @author Pavel fljot
	 */
	public class TouchPoint extends Point
	{
		public var id:uint;
		public var localX:Number;
		public var localY:Number;
		public var sizeX:Number;
		public var sizeY:Number;
		public var pressure:Number;
		public var touchBeginPos:Point;
		public var touchBeginTime:uint;
		public var moveOffset:Point;
		public var lastMove:Point;
		public var lastTime:uint;
		public var velocity:Point;
		
		
		public function TouchPoint(id:uint = 0, x:Number = 0, y:Number = 0,
								sizeX:Number = NaN, sizeY:Number = NaN,
								pressure:Number = NaN,
								touchBeginPos:Point = null, touchBeginTime:uint = 0,
								moveOffset:Point = null,
								lastMove:Point = null, lastTime:uint = 0, velocity:Point = null)
		{
			super(x, y);
			
			this.id = id;
			this.sizeX = sizeX;
			this.sizeY = sizeY;
			this.pressure = pressure;
			this.touchBeginPos = touchBeginPos || new Point();
			this.touchBeginTime = touchBeginTime;
			this.moveOffset = moveOffset || new Point();
			this.lastMove = lastMove || new Point();
			this.lastTime = lastTime;
			this.velocity = velocity || new Point();
		}
		
		
		override public function clone():Point
		{
			var p:TouchPoint = new TouchPoint(id, x, y, sizeX, sizeY, pressure,
				touchBeginPos.clone(), touchBeginTime,
				moveOffset.clone(),
				lastMove.clone(), lastTime, velocity.clone());
			return p;
		}
		
		
		public function reset():void
		{
			
		}
		
		
		override public function toString():String
		{
			return "Touch point [id: " + id + ", x: " + x + ", y: " + y + ", ...]";
		}
	}
}
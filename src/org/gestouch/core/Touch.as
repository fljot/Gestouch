package org.gestouch.core
{
	import flash.display.InteractiveObject;
	import flash.geom.Point;


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
		
		public var sizeX:Number;
		public var sizeY:Number;
		public var pressure:Number;
		
//		public var lastMove:Point;
		
		
		public function Touch(id:uint = 0)
		{
			this.id = id;
		}
		
		
		protected var _location:Point;
		public function get location():Point
		{
			return _location.clone();
		}
		gestouch_internal function setLocation(value:Point):void
		{
			_location = value;
			_beginLocation = _location.clone();
			_previousLocation = _location.clone();
		}
		gestouch_internal function updateLocation(x:Number, y:Number):void
		{
			if (_location)
			{
				_previousLocation.x = _location.x;
				_previousLocation.y = _location.y;
				_location.x = x;
				_location.y = y;
			}
			else
			{
				gestouch_internal::setLocation(new Point(x, y));
			}
		}
		
		
		protected var _previousLocation:Point;
		public function get previousLocation():Point
		{
			return _previousLocation.clone();
		}
		
		
		protected var _beginLocation:Point;
		public function get beginLocation():Point
		{
			return _beginLocation.clone();
		}
		
		
		public function get locationOffset():Point
		{
			return _location.subtract(_beginLocation);
		}
		
		
		protected var _time:uint;
		public function get time():uint
		{
			return _time;
		}
		gestouch_internal function setTime(value:uint):void
		{
			_time = value;
		}
		
		
		protected var _beginTime:uint;
		public function get beginTime():uint
		{
			return _beginTime;
		}
		gestouch_internal function setBeginTime(value:uint):void
		{
			_beginTime = value;
		}
		
		
		public function clone():Touch
		{
			var touch:Touch = new Touch(id);
			touch._location = _location;
			touch._beginLocation = _beginLocation;
			touch.target = target;
			touch.sizeX = sizeX;
			touch.sizeY = sizeY;
			touch.pressure = pressure;
			touch._time = _time;
			touch._beginTime = _beginTime;
			
			return touch;
		}
		
		
		public function toString():String
		{
			return "Touch [id: " + id + ", location: " + location + ", ...]";
		}
	}
}
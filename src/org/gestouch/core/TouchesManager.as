package org.gestouch.core
{
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	/**
	 * @author Pavel fljot
	 */
	public class TouchesManager implements ITouchesManager
	{
		private static var _instance:ITouchesManager;
		private static var _allowInstantiation:Boolean;
		
		protected var _touchesMap:Object = {};
		
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		}
		
		
		public function TouchesManager()
		{
			if (Object(this).constructor == TouchesManager && !_allowInstantiation)
			{
				throw new Error("Do not instantiate TouchesManager directly.");
			}
		}
		
		
		protected var _activeTouchesCount:uint;
		public function get activeTouchesCount():uint
		{
			return _activeTouchesCount;
		}
		
		
		public static function setImplementation(value:ITouchesManager):void
		{
			if (!value)
			{
				throw new ArgumentError("value cannot be null.");
			}
			if (_instance)
			{
				throw new Error("Instance of TouchesManager is already created. If you want to have own implementation of single TouchesManager instace, you should set it earlier.");
			}
			_instance = value;
		}
		

		public static function getInstance():ITouchesManager
		{
			if (!_instance)
			{
				_allowInstantiation = true;
				_instance = new TouchesManager();
				_allowInstantiation = false;
			}
			 
			return _instance;
		}
		
		
		public function createTouch():Touch
		{
			//TODO: pool
			return new Touch();
		}
		
		
		public function addTouch(touch:Touch):Touch
		{
			if (_touchesMap.hasOwnProperty(touch.id))
			{
				throw new Error("Touch with id " + touch.id + " is already registered.");
			}
			
			_touchesMap[touch.id] = touch;
			_activeTouchesCount++;
			
			return touch;
		}
		
		
		public function removeTouch(touch:Touch):Touch
		{
			if (!_touchesMap.hasOwnProperty(touch.id))
			{
				throw new Error("Touch with id " + touch.id + " is not registered.");
			}
			
			delete _touchesMap[touch.id];
			_activeTouchesCount--;
			
			return touch;
		}
		
		
		public function hasTouch(touchPointID:int):Boolean
		{
			 return _touchesMap.hasOwnProperty(touchPointID);
		}
		
		
		public function getTouch(touchPointID:int):Touch
		{
			var touch:Touch = _touchesMap[touchPointID] as Touch;
			return touch ? touch.clone() : null;
		}
	}
}
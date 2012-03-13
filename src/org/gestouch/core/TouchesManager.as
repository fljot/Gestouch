package org.gestouch.core
{
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	/**
	 * @author Pavel fljot
	 */
	public class TouchesManager implements ITouchesManager
	{
		private static var _instance:ITouchesManager;
		private static var _allowInstantiation:Boolean;
		
		protected var _touchesMap:Object = {};
		
		
		public function TouchesManager()
		{
			if (Object(this).constructor == TouchesManager && !_allowInstantiation)
			{
				throw new Error("Do not instantiate TouchesManager directly.");
			}
		}
		
		
		protected var _gesturesManager:IGesturesManager;
		public function set gesturesManager(value:IGesturesManager):void
		{
			_gesturesManager = value;
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
		
		
		public function onTouchBegin(inputAdapter:IInputAdapter, touchID:uint, x:Number, y:Number, target:Object):void
		{
			var overlappingTouches:Dictionary = _touchesMap[touchID] as Dictionary;
			if (overlappingTouches)
			{
				// In case we listen to both TouchEvents and MouseEvents, one of them will come first
				// (right now looks like MouseEvent dispatches first, but who know what Adobe will
				// do tomorrow). This check is to filter out the one comes second.
				for each (var registeredTouch:Touch in overlappingTouches)
				{
					if (registeredTouch.target == target)
						return;
				}
			}
			else
			{
				overlappingTouches = _touchesMap[touchID] = new Dictionary();
				_activeTouchesCount++;
			}
			
			var touch:Touch = createTouch();
			touch.id = touchID;
			touch.target = target;
			touch.gestouch_internal::setLocation(new Point(x, y), getTimer());			
			overlappingTouches[inputAdapter] = touch;
			
			_gesturesManager.gestouch_internal::onTouchBegin(touch);
		}
		
		
		public function onTouchMove(inputAdapter:IInputAdapter, touchID:uint, x:Number, y:Number):void
		{
			var overlappingTouches:Dictionary = _touchesMap[touchID] as Dictionary;
			if (!overlappingTouches)
				return;//this touch isn't properly registered.. some fake
			
			var touch:Touch = overlappingTouches[inputAdapter] as Touch;
			if (!touch)
				return;//touch with this ID from this inputAdapter is not registered. see workaround reason above
			
			touch.gestouch_internal::updateLocation(x, y, getTimer());
			
			_gesturesManager.gestouch_internal::onTouchMove(touch);
		}
		
		
		public function onTouchEnd(inputAdapter:IInputAdapter, touchID:uint, x:Number, y:Number):void
		{
			var overlappingTouches:Dictionary = _touchesMap[touchID] as Dictionary;
			if (!overlappingTouches)
				return;//this touch isn't properly registered.. some fake
			
			var touch:Touch = overlappingTouches[inputAdapter] as Touch;
			if (!touch)
				return;//touch with this ID from this inputAdapter is not registered. see workaround reason above
			
			touch.gestouch_internal::updateLocation(x, y, getTimer());
			
			delete overlappingTouches[inputAdapter];
			var empty:Boolean = true;
			for (var key:Object in overlappingTouches)
			{
				empty = false;
				break;
			}
			if (empty)
			{
				delete _touchesMap[touchID];
				_activeTouchesCount--;
			}
			
			_gesturesManager.gestouch_internal::onTouchEnd(touch);
		}
		
		
		/**
		 * Must be called by IInputAdapter#dispose() to remove all the touches invoked by it. 
		 */
		public function onInputAdapterDispose(inputAdapter:IInputAdapter):void
		{
			for (var touchID:Object in _touchesMap)
			{
				var overlappingTouches:Dictionary = _touchesMap[touchID] as Dictionary;
				if (overlappingTouches[inputAdapter])
				{
					delete overlappingTouches[inputAdapter];
					var empty:Boolean = true;
					for (var key:Object in overlappingTouches)
					{
						empty = false;
						break;
					}
					if (empty)
					{
						delete _touchesMap[touchID];
						_activeTouchesCount--;
					}
				}
			}
		}
		
		
		protected function createTouch():Touch
		{
			//TODO: pool
			return new Touch();
		}
	}
}
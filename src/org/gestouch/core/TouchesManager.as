package org.gestouch.core
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getTimer;
	/**
	 * @author Pavel fljot
	 */
	public class TouchesManager implements ITouchesManager
	{
		private static var _instance:ITouchesManager;
		private static var _allowInstantiation:Boolean;
		
		protected var _stage:Stage;
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
		
		
		public function init(stage:Stage):void
		{
			_stage = stage;
			if (Multitouch.supportsTouchEvents)
			{
				stage.addEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBeginHandler, true, int.MAX_VALUE);
				stage.addEventListener(TouchEvent.TOUCH_MOVE, stage_touchMoveHandler, true, int.MAX_VALUE);
				stage.addEventListener(TouchEvent.TOUCH_END, stage_touchEndHandler, true, int.MAX_VALUE);
			}
			else
			{
				stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler, true, int.MAX_VALUE);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler, true, int.MAX_VALUE);
				stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler, true, int.MAX_VALUE);
			}
		}
		
		
		public function getTouch(touchPointID:int):Touch
		{
			var touch:Touch = _touchesMap[touchPointID] as Touch;
			return touch ? touch.clone() : null;
		}		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		protected function stage_touchBeginHandler(event:TouchEvent):void
		{
			var touch:Touch = new Touch(event.touchPointID);
			_touchesMap[event.touchPointID] = touch;
			
			touch.target = event.target as InteractiveObject;
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.sizeX = event.sizeX;
			touch.sizeY = event.sizeY;
			touch.pressure = event.pressure;
			touch.time = getTimer();//TODO: conditional compilation + event.timestamp
			
			_activeTouchesCount++;
		}
		
		
		protected function stage_mouseDownHandler(event:MouseEvent):void
		{
			var touch:Touch = new Touch(0);
			_touchesMap[0] = touch;
			
			touch.target = event.target as InteractiveObject;
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.sizeX = NaN;
			touch.sizeY = NaN;
			touch.pressure = NaN;
			touch.time = getTimer();//TODO: conditional compilation + event.timestamp
			
			_activeTouchesCount++;
		}
		
		
		protected function stage_touchMoveHandler(event:TouchEvent):void
		{
			var touch:Touch = _touchesMap[event.touchPointID] as Touch;
			if (!touch)
			{
				// some fake event?
				return;
			}
			
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.sizeX = event.sizeX;
			touch.sizeY = event.sizeY;
			touch.pressure = event.pressure;
			touch.time = getTimer();//TODO: conditional compilation + event.timestamp
		}
		
		
		protected function stage_mouseMoveHandler(event:MouseEvent):void
		{
			var touch:Touch = _touchesMap[0] as Touch;
			if (!touch)
			{
				// some fake event?
				return;
			}
			
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.time = getTimer();//TODO: conditional compilation + event.timestamp
		}
		
		
		protected function stage_touchEndHandler(event:TouchEvent):void
		{
			var touch:Touch = _touchesMap[event.touchPointID] as Touch;
			if (!touch)
			{
				// some fake event?
				return;
			}
			
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.sizeX = event.sizeX;
			touch.sizeY = event.sizeY;
			touch.pressure = event.pressure;
			touch.time = getTimer();//TODO: conditional compilation + event.timestamp
			
			_activeTouchesCount--;
		}
		
		
		protected function stage_mouseUpHandler(event:MouseEvent):void
		{
			var touch:Touch = _touchesMap[0] as Touch;
			if (!touch)
			{
				// some fake event?
				return;
			}
			
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.time = getTimer();//TODO: conditional compilation + event.timestamp
			
			_activeTouchesCount--;
		}
	}
}
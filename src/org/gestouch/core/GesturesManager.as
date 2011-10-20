package org.gestouch.core
{
	import org.gestouch.events.MouseTouchEvent;
	import org.gestouch.utils.ObjectPool;

	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;


	/**
	 * @author Pavel fljot
	 */
	public class GesturesManager implements IGesturesManager
	{
		public static var implementation:IGesturesManager;
		
		protected static var _impl:IGesturesManager;
		protected static var _initialized:Boolean = false;
		
		protected var _stage:Stage;
		protected var _gestures:Vector.<IGesture> = new Vector.<IGesture>();
		protected var _currGestures:Vector.<IGesture> = new Vector.<IGesture>();
		/**
		 * Maps (Dictionary[target] = gesture) by gesture type.
		 */
		protected var _gestureMapsByType:Dictionary = new Dictionary();
		protected var _touchPoints:Vector.<TouchPoint> = new Vector.<TouchPoint>(Multitouch.maxTouchPoints);
		protected var _touchPointsPool:ObjectPool = new ObjectPool(TouchPoint);
		
		
		gestouch_internal static function addGesture(gesture:IGesture):IGesture
		{
			if (!_impl)
			{
				_impl = implementation || new GesturesManager();
			}
			return _impl.addGesture(gesture);
		}


		gestouch_internal static function removeGesture(gesture:IGesture):IGesture
		{
			return _impl.removeGesture(gesture);
		}
		
		
		gestouch_internal static function removeGestureByTarget(gestureType:Class, target:InteractiveObject):IGesture
		{
			return _impl.removeGestureByTarget(gestureType, target);
		}
		
		
		gestouch_internal static function cancelGesture(gesture:IGesture):void
		{
			_impl.cancelGesture(gesture);
		}
		
		
		gestouch_internal static function addCurrentGesture(gesture:IGesture):void
		{
			_impl.addCurrentGesture(gesture);
		}
		
		
		gestouch_internal static function updateGestureTarget(gesture:IGesture, oldTarget:InteractiveObject, newTarget:InteractiveObject):void
		{
			_impl.updateGestureTarget(gesture, oldTarget, newTarget);
		}
		
		
		public function init(stage:Stage):void
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
						
			_stage = stage;
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseDownHandler);
			_stage.addEventListener(TouchEvent.TOUCH_BEGIN, stage_touchBeginHandler);
			_stage.addEventListener(TouchEvent.TOUCH_MOVE, stage_touchMoveHandler);
			_stage.addEventListener(TouchEvent.TOUCH_END, stage_touchEndHandler, true);
		}
		
		
		public static function getTouchPoint(touchPointID:int):TouchPoint
		{
			return _impl.getTouchPoint(touchPointID);
		}
		
		
		public function addGesture(gesture:IGesture):IGesture
		{
			if (_gestures.indexOf(gesture) > -1)
			{
				throw new IllegalOperationError("Gesture instace '" + gesture + "' is already registered.");
			}
			
			_gestures.push(gesture);
			
			return gesture;
		}


		public function removeGesture(gesture:IGesture):IGesture
		{
			var index:int = _gestures.indexOf(gesture); 
			if (index == -1)
			{
				throw new IllegalOperationError("Gesture instace '" + gesture + "' is not registered.");
			}
			
			_gestures.splice(index, 1);
			
			index = _currGestures.indexOf(gesture);
			if (index > -1)
			{
				_currGestures.splice(index, 1);
			}
			
			gesture.dispose();
			
			return gesture;
		}


		public function removeGestureByTarget(gestureType:Class, target:InteractiveObject):IGesture
		{
			var gesture:IGesture = getGestureByTarget(gestureType, target);
			return removeGesture(gesture);
		}


		public function getGestureByTarget(gestureType:Class, target:InteractiveObject):IGesture
		{
			var gesturesOfTypeByTarget:Dictionary = _gestureMapsByType[gestureType] as Dictionary;
			var gesture:IGesture = gesturesOfTypeByTarget ? gesturesOfTypeByTarget[target] as IGesture : null;
			return gesture;
		}
		
		
		public function cancelGesture(gesture:IGesture):void
		{
			var index:int = _currGestures.indexOf(gesture);
			if (index == -1)
			{
				return;// don't see point in throwing error
			}
			
			_currGestures.splice(index, 1);
			gesture.onCancel();
		}
		
		
		public function addCurrentGesture(gesture:IGesture):void
		{
			if (_currGestures.indexOf(gesture) == -1)
			{
				_currGestures.push(gesture);
			}
		}
		
		
		public function updateGestureTarget(gesture:IGesture, oldTarget:InteractiveObject, newTarget:InteractiveObject):void
		{
			if (!_initialized)
			{
				var stage:Stage = newTarget.stage; 
				if (stage)
				{
					_impl.init(stage);
					_initialized = true;			
				}
				else
				{
					newTarget.addEventListener(Event.ADDED_TO_STAGE, target_addedToStageHandler, false, 0, true);
				}
			}
			
			var gesturesOfTypeByTarget:Dictionary = _gestureMapsByType[gesture.reflect()] as Dictionary;
			if (!gesturesOfTypeByTarget)
			{
				gesturesOfTypeByTarget = _gestureMapsByType[gesture.reflect()] = new Dictionary();
			}
			if (gesturesOfTypeByTarget[newTarget])
			{
				throw new IllegalOperationError("You cannot add two gestures of the same type to one target (it makes no sence).");
			}
			if (oldTarget)
			{
				delete gesturesOfTypeByTarget[oldTarget];
			}
			if (newTarget)
			{
				gesturesOfTypeByTarget[newTarget] = gesture;
			}
		}
		
		
		public function getTouchPoint(touchPointID:int):TouchPoint
		{
			var p:TouchPoint = _touchPoints[touchPointID];
			if (!p)
			{
				throw new ArgumentError("No touch point with ID " + touchPointID + " found.");
			}
			return p.clone() as TouchPoint;
		}


		private static function target_addedToStageHandler(event:Event):void
		{
			var target:InteractiveObject = event.currentTarget as InteractiveObject;
			target.removeEventListener(Event.ADDED_TO_STAGE, target_addedToStageHandler);
			
			if (!_initialized)
			{
				_impl.init(target.stage);
				_initialized = true;
			}
		}


		protected function stage_mouseDownHandler(event:MouseEvent):void
		{
			if (Multitouch.supportsTouchEvents)
			{
				return;
			}
			
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			_stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			
			stage_touchBeginHandler(new MouseTouchEvent(TouchEvent.TOUCH_BEGIN, event));
		}
		
		
		protected function stage_mouseMoveHandler(event:MouseEvent):void
		{
			stage_touchMoveHandler(new MouseTouchEvent(TouchEvent.TOUCH_MOVE, event));
		}
		
		
		protected function stage_mouseUpHandler(event:MouseEvent):void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			
			stage_touchEndHandler(new MouseTouchEvent(TouchEvent.TOUCH_END, event));
		}


		protected function stage_touchBeginHandler(event:TouchEvent):void
		{
			var outOfRange:Boolean = (_touchPoints.length <= event.touchPointID);
			var tp:TouchPoint = outOfRange ? null : _touchPoints[event.touchPointID];
			if (!tp)
			{
				tp = _touchPointsPool.getObject() as TouchPoint;
				tp.id = event.touchPointID;
				if (outOfRange)
				{
					_touchPoints.length = tp.id + 1;
				}
				_touchPoints[tp.id] = tp;
			}
			tp.reset();
			tp.x = event.stageX;
			tp.y = event.stageY;
			tp.sizeX = event.sizeX;
			tp.sizeY = event.sizeY;
			tp.pressure = event.pressure;
			tp.touchBeginPos.x = tp.x;
			tp.touchBeginPos.y = tp.y;
			tp.touchBeginTime = tp.lastTime = getTimer();
			tp.moveOffset.x = tp.moveOffset.y = 0; 
			tp.lastMove.x = tp.lastMove.y = 0;
			tp.velocity.x = tp.velocity.y = 0;
			
			for each (var gesture:IGesture in _gestures)
			{
				if (gesture.target && gesture.shouldTrackPoint(event, tp))
				{
					gesture.onTouchBegin(tp);
				}
			}
			
			// add gestures that are being tracked to the current gestures list
			var n:uint = _gestures.length;
			while (n-- > 0)
			{
				gesture = _gestures[n];
				//TODO: which condition first (performance-wise)?
				if (_currGestures.indexOf(gesture) == -1 && gesture.isTracking(tp.id))
				{
					_currGestures.push(gesture);
				}
			}
		}
		
		
		protected function stage_touchMoveHandler(event:TouchEvent):void
		{
			var tp:TouchPoint = _touchPoints[event.touchPointID];
			var oldX:Number = tp.x;
			var oldY:Number = tp.y;
			tp.x = event.stageX;
			tp.y = event.stageY;
			tp.sizeX = event.sizeX;
			tp.sizeY = event.sizeY;
			tp.pressure = event.pressure;
//			tp.moveOffset = tp.subtract(tp.touchBeginPos);
			tp.moveOffset.x = tp.x - tp.touchBeginPos.x;
			tp.moveOffset.y = tp.y - tp.touchBeginPos.y;
			tp.lastMove.x = tp.x - oldX;
			tp.lastMove.y = tp.y - oldY;
			var now:uint = getTimer(); 
			var dt:uint = now - tp.lastTime;
			tp.lastTime = now;
			tp.velocity.x = tp.lastMove.x / dt;
			tp.velocity.y = tp.lastMove.y / dt;
			
			for each (var gesture:IGesture in _currGestures)
			{
				if (gesture.isTracking(tp.id))
				{
					gesture.onTouchMove(tp);
				}
			}
		}
		
		
		protected function stage_touchEndHandler(event:TouchEvent):void
		{
			var tp:TouchPoint = _touchPoints[event.touchPointID];
			tp.x = event.stageX;
			tp.y = event.stageY;
			tp.sizeX = event.sizeX;
			tp.sizeY = event.sizeY;
			tp.pressure = event.pressure;
			tp.moveOffset = tp.subtract(tp.touchBeginPos);
			
			for each (var gesture:IGesture in _currGestures)
			{
				if (gesture.isTracking(tp.id))
				{
					gesture.onTouchEnd(tp);
				}
			}
			
			var i:uint = 0;
			for each (gesture in _currGestures.concat())
			{
				if (gesture.trackingPointsCount == 0)
				{
					_currGestures.splice(i, 1);
				}
				else
				{				
					i++;
				}
			}
		}
	}
}
package org.gestouch.gestures
{
	import org.gestouch.utils.GestureUtils;
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.SwipeGestureEvent;

	import flash.geom.Point;


	/**
	 * 
	 * @eventType org.gestouch.events.SwipeGestureEvent
	 */
	[Event(name="gestureSwipe", type="org.gestouch.events.SwipeGestureEvent")]
	/**
	 * TODO:
	 * -check native behavior on iDevice
	 * 
	 * @author Pavel fljot
	 */
	public class SwipeGesture extends Gesture
	{
		private static const ANGLE:Number = 30 * GestureUtils.DEGREES_TO_RADIANS;
		
		public var slop:Number = Gesture.DEFAULT_SLOP;
		public var numTouchesRequired:uint = 1;
		public var minVelocity:Number = 0.6;
		public var minOffset:Number = Gesture.DEFAULT_SLOP;
		public var direction:uint = SwipeGestureDirection.ORTHOGONAL;
		
		protected var _offset:Point = new Point();
		protected var _startTime:int;
		protected var _noDirection:Boolean;
		protected var _avrgVel:Point = new Point();
		protected var _prevAvrgVel:Point = new Point();
		protected var _decelerationCounter:uint = 0;
		
		
		public function SwipeGesture(target:Object = null)
		{
			super(target);
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Public methods
		//
		// --------------------------------------------------------------------------
		
		override public function reflect():Class
		{
			return SwipeGesture;
		}
		
			
		override public function reset():void
		{
			_startTime = 0;
			_offset.x = 0;
			_offset.y = 0;
			_decelerationCounter = 0;

			super.reset();
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Protected methods
		//
		// --------------------------------------------------------------------------
		
		override protected function onTouchBegin(touch:Touch):void
		{
			if (touchesCount > numTouchesRequired)
			{
				failOrIgnoreTouch(touch);
				return;
			}
			
			if (touchesCount == 1)
			{
				// Because we want to fail as quick as possible
				_startTime = touch.time;
			}
			if (touchesCount == numTouchesRequired)
			{
				updateLocation();
				_avrgVel.x = _avrgVel.y = 0;
				
				// cache direction condition for performance
				_noDirection = (SwipeGestureDirection.ORTHOGONAL & direction) == 0;
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (touchesCount < numTouchesRequired)
				return;
			
			var totalTime:int = touch.time - _startTime;
			if (totalTime == 0)
				return;//It was somehow THAT MUCH performant on one Android tablet
			
			var prevCentralPointX:Number = _centralPoint.x;
			var prevCentralPointY:Number = _centralPoint.y;
			updateCentralPoint();
			
			_offset.x = _centralPoint.x - _location.x;
			_offset.y = _centralPoint.y - _location.y;
			var offsetLength:Number = _offset.length;
			
			if (offsetLength < slop)
			{
				// no need in processing yet - we're in the very beginning of movement
				return;
			}
			
			// average velocity (total offset to total duration)
			_prevAvrgVel.x = _avrgVel.x;
			_prevAvrgVel.y = _avrgVel.y;
			_avrgVel.x = _offset.x / totalTime;
			_avrgVel.y = _offset.y / totalTime;
			var avrgVel:Number = _avrgVel.length;
			
			if (avrgVel * 0.95 < _prevAvrgVel.length)
			{
				_decelerationCounter++;
			}
			// We should quickly fail if we have noticable deceleration
			// or average velocity is too low
			if (_decelerationCounter > 5 || avrgVel < 0.05)
			{
				setState(GestureState.FAILED);
				return;
			}
			
			if (_noDirection)
			{
				if (avrgVel >= minVelocity && (minOffset != minOffset || offsetLength >= minOffset))
				{
					if (setState(GestureState.RECOGNIZED) && hasEventListener(SwipeGestureEvent.GESTURE_SWIPE))
					{
						_localLocation = targetAdapter.globalToLocal(_location);//refresh local location in case target moved
						dispatchEvent(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, false, false, GestureState.RECOGNIZED,
							_location.x, _location.y, _localLocation.x, _localLocation.y, _offset.x, _offset.y));
					}
				}
			}
			else
			{
				var recentOffsetX:Number = _centralPoint.x - prevCentralPointX;
				var recentOffsetY:Number = _centralPoint.y - prevCentralPointY;
				//faster Math.abs()
				var absVelX:Number = _avrgVel.x > 0 ? _avrgVel.x : -_avrgVel.x;
				var absVelY:Number = _avrgVel.y > 0 ? _avrgVel.y : -_avrgVel.y;
				
				if (absVelX > absVelY)
				{
					var absOffsetX:Number = _offset.x > 0 ? _offset.x : -_offset.x;
					
					if ((SwipeGestureDirection.HORIZONTAL & direction) == 0)
					{
						// horizontal velocity is greater then vertical, but we're not interested in any horizontal direction
						setState(GestureState.FAILED);
					}
					else if ((recentOffsetX < 0 && (direction & SwipeGestureDirection.LEFT) == 0) ||
						(recentOffsetX > 0 && (direction & SwipeGestureDirection.RIGHT) == 0) ||
						Math.abs(Math.atan(_offset.y/_offset.x)) > ANGLE)
					{
						// movement in opposite direction
						// or too much diagonally
						setState(GestureState.FAILED);
					}
					else if (absVelX >= minVelocity && (minOffset != minOffset || absOffsetX >= minOffset))
					{
						_offset.y = 0;
						if (setState(GestureState.RECOGNIZED) && hasEventListener(SwipeGestureEvent.GESTURE_SWIPE))
						{
							_localLocation = targetAdapter.globalToLocal(_location);//refresh local location in case target moved
							dispatchEvent(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, false, false, GestureState.RECOGNIZED,
								_location.x, _location.y, _localLocation.x, _localLocation.y, _offset.x, _offset.y));
						}
					}
				}
				else if (absVelY > absVelX)
				{
					var absOffsetY:Number = _offset.y > 0 ? _offset.y : -_offset.y;
					
					if ((SwipeGestureDirection.VERTICAL & direction) == 0)
					{
						// horizontal velocity is greater then vertical, but we're not interested in any horizontal direction
						setState(GestureState.FAILED);
					}
					else if ((recentOffsetY < 0 && (direction & SwipeGestureDirection.UP) == 0) ||
						(recentOffsetY > 0 && (direction & SwipeGestureDirection.DOWN) == 0) ||
						Math.abs(Math.atan(_offset.x/_offset.y)) > ANGLE)
					{
						// movement in opposite direction
						// or too much diagonally
						setState(GestureState.FAILED);
					}
					else if (absVelY >= minVelocity && (minOffset != minOffset || absOffsetY >= minOffset))
					{
						_offset.x = 0;
						if (setState(GestureState.RECOGNIZED) && hasEventListener(SwipeGestureEvent.GESTURE_SWIPE))
						{
							_localLocation = targetAdapter.globalToLocal(_location);//refresh local location in case target moved
							dispatchEvent(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, false, false, GestureState.RECOGNIZED,
								_location.x, _location.y, _localLocation.x, _localLocation.y, _offset.x, _offset.y));
						}
					}
				}
				else
				{
					setState(GestureState.FAILED);
				}
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			if (touchesCount < numTouchesRequired)
			{
				setState(GestureState.FAILED);
			}
		}
		
		
		override protected function onDelayedRecognize():void
		{
			if (hasEventListener(SwipeGestureEvent.GESTURE_SWIPE))
			{
				_localLocation = targetAdapter.globalToLocal(_location);//refresh local location in case target moved
				dispatchEvent(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, false, false, GestureState.RECOGNIZED,
					_location.x, _location.y, _localLocation.x, _localLocation.y, _offset.x, _offset.y));
			}
		}
	}
}
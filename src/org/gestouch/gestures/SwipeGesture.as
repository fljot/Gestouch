package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.SwipeGestureEvent;

	import flash.display.InteractiveObject;
	import flash.geom.Point;
	import flash.system.Capabilities;

	[Event(name="gestureSwipe", type="org.gestouch.events.SwipeGestureEvent")]
	/**
	 * TODO:
	 * -check native behavior on iDevice
	 * 
	 * @author Pavel fljot
	 */
	public class SwipeGesture extends Gesture
	{
		public var numTouchesRequired:uint = 1;
		public var velocityThreshold:Number = 0.1;
		public var minVelocity:Number = 1.5;
		public var minDistance:Number = Capabilities.screenDPI * 0.5;
		
		public var direction:uint = SwipeGestureDirection.ORTHOGONAL;
		
		protected var _offset:Point = new Point();
		protected var _startTime:int;
		protected var _noDirection:Boolean;
		
		
		public function SwipeGesture(target:InteractiveObject = null)
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
				//TODO: or ignore?
				setState(GestureState.FAILED);
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
				
				// cache direction condition for performance
				_noDirection = (SwipeGestureDirection.ORTHOGONAL & direction) == 0;
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (touchesCount < numTouchesRequired)
				return;
			
			updateCentralPoint();
			
			_offset.x = _centralPoint.x - _location.x;
			_offset.y = _centralPoint.y - _location.y;
			var offsetLength:Number = _offset.length;
			var timeDelta:int = touch.time - _startTime;			
			var vel:Number = offsetLength / timeDelta;
			var absVel:Number = vel > 0 ? vel : -vel;//faster Math.abs()
			
			if (offsetLength < Gesture.DEFAULT_SLOP)
			{
				// no need in processing - we're in the very beginning of movement
				return;
			}
			else if (absVel < velocityThreshold)
			{
				setState(GestureState.FAILED);
				return;
			}
			
			var velX:Number = _offset.x / timeDelta;
			var velY:Number = _offset.y / timeDelta;
			
			
			if (_noDirection)
			{
				if (absVel >= minVelocity || (minDistance != minDistance || offsetLength >= minDistance))
				{
					if (setState(GestureState.RECOGNIZED) && hasEventListener(SwipeGestureEvent.GESTURE_SWIPE))
					{
						_localLocation = target.globalToLocal(_location);//refresh local location in case target moved
						dispatchEvent(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, false, false, GestureState.RECOGNIZED,
							_location.x, _location.y, _localLocation.x, _localLocation.y, _offset.x, _offset.y));
					}
				}
			}
			else
			{
				//faster Math.abs()
				var absVelX:Number = velX > 0 ? velX : -velX;
				var absVelY:Number = velY > 0 ? velY : -velY;
				var absOffsetX:Number = _offset.x > 0 ? _offset.x : -_offset.x;
				var absOffsetY:Number = _offset.y > 0 ? _offset.y : -_offset.y;
				
				if (absVelX > absVelY)
				{
					if ((SwipeGestureDirection.HORIZONTAL & direction) == 0)
					{
						// horizontal velocity is greater then vertical, but we're not interested in any horizontal direction
						setState(GestureState.FAILED);
					}
					else if (velX < 0 && (direction & SwipeGestureDirection.LEFT) == 0)
					{
						setState(GestureState.FAILED);
					}
					else if (velX > 0 && (direction & SwipeGestureDirection.RIGHT) == 0)
					{
						setState(GestureState.FAILED);						
					}
					else if (absVelX >= minVelocity || (minDistance != minDistance || absOffsetX >= minDistance))
					{
						if (setState(GestureState.RECOGNIZED) && hasEventListener(SwipeGestureEvent.GESTURE_SWIPE))
						{
							_localLocation = target.globalToLocal(_location);//refresh local location in case target moved
							dispatchEvent(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, false, false, GestureState.RECOGNIZED,
								_location.x, _location.y, _localLocation.x, _localLocation.y, _offset.x, 0));
						}
					}
				}
				else if (absVelY > absVelX)
				{
					if ((SwipeGestureDirection.VERTICAL & direction) == 0)
					{
						// horizontal velocity is greater then vertical, but we're not interested in any horizontal direction
						setState(GestureState.FAILED);
					}
					else if (velY < 0 && (direction & SwipeGestureDirection.UP) == 0)
					{
						setState(GestureState.FAILED);
					}
					else if (velY > 0 && (direction & SwipeGestureDirection.DOWN) == 0)
					{
						setState(GestureState.FAILED);						
					}
					else if (absVelY >= minVelocity || (minDistance != minDistance || absOffsetY >= minDistance))
					{
						if (setState(GestureState.RECOGNIZED) && hasEventListener(SwipeGestureEvent.GESTURE_SWIPE))
						{
							_localLocation = target.globalToLocal(_location);//refresh local location in case target moved
							dispatchEvent(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, false, false, GestureState.RECOGNIZED,
								_location.x, _location.y, _localLocation.x, _localLocation.y, 0, _offset.y));
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
			setState(GestureState.FAILED);
		}
	}
}
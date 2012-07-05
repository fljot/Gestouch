package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.RotateGestureEvent;
	import org.gestouch.utils.GestureUtils;

	import flash.geom.Point;


	/**
	 * 
	 * @eventType org.gestouch.events.RotateGestureEvent
	 */
	[Event(name="gestureRotate", type="org.gestouch.events.RotateGestureEvent")]
	/**
	 * TODO:
	 * -check native behavior on iDevice
	 * 
	 * @author Pavel fljot
	 */
	public class RotateGesture extends Gesture
	{
		public var slop:Number = Gesture.DEFAULT_SLOP >> 1;
		
		protected var _touch1:Touch;
		protected var _touch2:Touch;
		protected var _transformVector:Point;
		
		
		public function RotateGesture(target:Object = null)
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
			return RotateGesture;
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Protected methods
		//
		// --------------------------------------------------------------------------
		
		override protected function onTouchBegin(touch:Touch):void
		{
			if (touchesCount > 2)
			{
				failOrIgnoreTouch(touch);
				return;
			}
			
			if (touchesCount == 1)
			{
				_touch1 = touch;
			}
			else
			{
				_touch2 = touch;
				
				_transformVector = _touch2.location.subtract(_touch1.location);
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (touchesCount < 2)
				return;
			
			var recognized:Boolean = true;
			
			if (state == GestureState.POSSIBLE && slop > 0 && touch.locationOffset.length < slop)
			{
				recognized = false;
			}
			
			if (recognized)
			{
				var currTransformVector:Point = _touch2.location.subtract(_touch1.location);
				var rotation:Number = Math.atan2(currTransformVector.y, currTransformVector.x) - Math.atan2(_transformVector.y, _transformVector.x);
				rotation *= GestureUtils.RADIANS_TO_DEGREES;
				_transformVector.x = currTransformVector.x;
				_transformVector.y = currTransformVector.y;
				
				updateLocation();
				
				if (state == GestureState.POSSIBLE)
				{
					if (setState(GestureState.BEGAN) && hasEventListener(RotateGestureEvent.GESTURE_ROTATE))
					{
						dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GestureState.BEGAN,
							_location.x, _location.y, _localLocation.x, _localLocation.y, rotation));
					}
				}
				else
				{
					if (setState(GestureState.CHANGED) && hasEventListener(RotateGestureEvent.GESTURE_ROTATE))
					{
						dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GestureState.CHANGED,
							_location.x, _location.y, _localLocation.x, _localLocation.y, rotation));
					}
				}
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			if (touchesCount == 0)
			{
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					if (setState(GestureState.ENDED) && hasEventListener(RotateGestureEvent.GESTURE_ROTATE))
					{
						dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GestureState.ENDED,
							_location.x, _location.y, _localLocation.x, _localLocation.y, 0));
					}
				}
				else if (state == GestureState.POSSIBLE)
				{
					setState(GestureState.FAILED);
				}
			}
			else// == 1
			{
				if (touch == _touch1)
				{
					_touch1 = _touch2;
				}
				_touch2 = null;
				
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					updateLocation();
					if (setState(GestureState.CHANGED) && hasEventListener(RotateGestureEvent.GESTURE_ROTATE))
					{
						dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GestureState.CHANGED,
							_location.x, _location.y, _localLocation.x, _localLocation.y, 0));
					}
				}
			}
		}
	}
}
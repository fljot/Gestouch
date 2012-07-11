package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.TransformGestureEvent;
	import org.gestouch.utils.GestureUtils;

	import flash.geom.Point;


	/**
	 * 
	 * @eventType org.gestouch.events.TransformGestureEvent
	 */
	[Event(name="gestureTransform", type="org.gestouch.events.TransformGestureEvent")]
	/**
	 * @author Pavel fljot
	 */
	public class TransformGesture extends Gesture
	{
		public var slop:Number = Gesture.DEFAULT_SLOP;
		
		protected var _touch1:Touch;
		protected var _touch2:Touch;
		protected var _transformVector:Point;
		
		
		public function TransformGesture(target:Object = null)
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
			return TransformGesture;
		}
		
			
		override public function reset():void
		{
			_touch1 = null;
			_touch2 = null;

			super.reset();
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
			
			updateLocation();
			
			if (state == GestureState.BEGAN || state == GestureState.CHANGED)
			{
				if (setState(GestureState.CHANGED) && hasEventListener(TransformGestureEvent.GESTURE_TRANSFORM))
				{ 
					dispatchEvent(new TransformGestureEvent(TransformGestureEvent.GESTURE_TRANSFORM, false, false, GestureState.CHANGED,
						_location.x, _location.y, _localLocation.x, _localLocation.y));
				}
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			var prevLocation:Point = _location.clone();
			updateLocation();
			
			var currTransformVector:Point;
			
			if (state == GestureState.POSSIBLE)
			{
				if (slop > 0 && touch.locationOffset.length < slop)
				{
					// Not recognized yet
					if (_touch2)
					{
						// Recalculate _transformVector to avoid initial "jump" on recognize
						_transformVector = _touch2.location.subtract(_touch1.location);
					}
					return;
				}
			}
			
			if (_touch2 && !currTransformVector)
			{
				currTransformVector = _touch2.location.subtract(_touch1.location);
			}
			
			var prevLocalLocation:Point;
			var offsetX:Number = _location.x - prevLocation.x;
			var offsetY:Number = _location.y - prevLocation.y;
			var scale:Number = 1;
			var rotation:Number = 0;
			if (_touch2)
			{
				rotation = Math.atan2(currTransformVector.y, currTransformVector.x) - Math.atan2(_transformVector.y, _transformVector.x);
				scale = currTransformVector.length / _transformVector.length;
				_transformVector = _touch2.location.subtract(_touch1.location);
			}
			
			
			if (state == GestureState.POSSIBLE)
			{
				if (setState(GestureState.BEGAN) && hasEventListener(TransformGestureEvent.GESTURE_TRANSFORM))
				{
					// Note that we dispatch previous location point which gives a way to perform
					// accurate UI redraw. See examples project for more info.
					prevLocalLocation = targetAdapter.globalToLocal(prevLocation);
					dispatchEvent(new TransformGestureEvent(TransformGestureEvent.GESTURE_TRANSFORM, false, false, GestureState.BEGAN,
						prevLocation.x, prevLocation.y, prevLocalLocation.x, prevLocalLocation.y, scale, scale, rotation, offsetX, offsetY));
				}
			}
			else
			{
				if (setState(GestureState.CHANGED) && hasEventListener(TransformGestureEvent.GESTURE_TRANSFORM))
				{
					// Note that we dispatch previous location point which gives a way to perform
					// accurate UI redraw. See examples project for more info.
					prevLocalLocation = targetAdapter.globalToLocal(prevLocation);
					dispatchEvent(new TransformGestureEvent(TransformGestureEvent.GESTURE_TRANSFORM, false, false, GestureState.CHANGED,
						prevLocation.x, prevLocation.y, prevLocalLocation.x, prevLocalLocation.y, scale, scale, rotation, offsetX, offsetY));
				}
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			if (touchesCount == 0)
			{
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					if (setState(GestureState.ENDED) && hasEventListener(TransformGestureEvent.GESTURE_TRANSFORM))
					{
						dispatchEvent(new TransformGestureEvent(TransformGestureEvent.GESTURE_TRANSFORM, false, false, GestureState.ENDED,
							_location.x, _location.y, _localLocation.x, _localLocation.y));
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
					if (setState(GestureState.CHANGED) && hasEventListener(TransformGestureEvent.GESTURE_TRANSFORM))
					{
						dispatchEvent(new TransformGestureEvent(TransformGestureEvent.GESTURE_TRANSFORM, false, false, GestureState.CHANGED,
							_location.x, _location.y, _localLocation.x, _localLocation.y));
					}
				}
			}
		}
	}
}
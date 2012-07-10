package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.ZoomGestureEvent;

	import flash.geom.Point;


	/**
	 * 
	 * @eventType org.gestouch.events.ZoomGestureEvent
	 */
	[Event(name="gestureZoom", type="org.gestouch.events.ZoomGestureEvent")]
	/**
	 * 
	 * @author Pavel fljot
	 */
	public class ZoomGesture extends Gesture
	{
		public var slop:Number = Gesture.DEFAULT_SLOP;
		public var lockAspectRatio:Boolean = true;
		
		protected var _touch1:Touch;
		protected var _touch2:Touch;
		protected var _transformVector:Point;
		protected var _initialDistance:Number;
		
		
		public function ZoomGesture(target:Object = null)
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
			return ZoomGesture;
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
			else// == 2
			{
				_touch2 = touch;
				
				_transformVector = _touch2.location.subtract(_touch1.location);
				_initialDistance = _transformVector.length;
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (touchesCount < 2)
				return;
			
			var currTransformVector:Point = _touch2.location.subtract(_touch1.location);
			var scaleX:Number;
			var scaleY:Number;
			
			if (state == GestureState.POSSIBLE)
			{
				const d:Number = currTransformVector.length - _initialDistance;
				const absD:Number = d >= 0 ? d : -d;
				if (absD < slop)
				{
					// Not recognized yet
					return;
				}
				
				if (slop > 0)
				{
					// adjust _transformVector to avoid initial "jump"
					const slopVector:Point = currTransformVector.clone();
					slopVector.normalize(_initialDistance + (d >= 0 ? slop : -slop));
					_transformVector = slopVector;
				}
			}
			
			
			if (lockAspectRatio)
			{
				scaleX = scaleY = currTransformVector.length / _transformVector.length;
			}
			else
			{
				scaleX = currTransformVector.x / _transformVector.x;
				scaleY = currTransformVector.y / _transformVector.y;
			}
			
			_transformVector.x = currTransformVector.x;
			_transformVector.y = currTransformVector.y;
			
			updateLocation();
			
			if (state == GestureState.POSSIBLE)
			{
				if (setState(GestureState.BEGAN) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))
				{
					dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GestureState.BEGAN,
						_location.x, _location.y, _localLocation.x, _localLocation.y, scaleX, scaleY));
				}
			}
			else
			{
				if (setState(GestureState.CHANGED) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))
				{
					dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GestureState.CHANGED,
						_location.x, _location.y, _localLocation.x, _localLocation.y, scaleX, scaleY));
				}
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			if (touchesCount == 0)
			{
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					if (setState(GestureState.ENDED) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))
					{
						dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GestureState.ENDED,
							_location.x, _location.y, _localLocation.x, _localLocation.y, 1, 1));
					}
				}
				else if (state == GestureState.POSSIBLE)
				{
					setState(GestureState.FAILED);
				}
			}
			else//== 1
			{
				if (touch == _touch1)
				{
					_touch1 = _touch2;
				}
				_touch2 = null;
				
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					updateLocation();
					if (setState(GestureState.CHANGED) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))
					{
						dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GestureState.CHANGED,
							_location.x, _location.y, _localLocation.x, _localLocation.y, 1, 1));
					}
				}
			}
		}
	}
}
package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.RotateGestureEvent;
	import org.gestouch.utils.GestureUtils;

	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.geom.Point;

	[Event(name="gestureRotate", type="org.gestouch.events.RotateGestureEvent")]
	/**
	 * TODO:
	 * -location
	 * -check native behavior on iDevice
	 * 
	 * @author Pavel fljot
	 */
	public class RotateGesture extends Gesture
	{
		public var slop:Number = Gesture.DEFAULT_SLOP >> 1;
		
		protected var _rotationVector:Point = new Point();
		protected var _firstTouch:Touch;
		protected var _secondTouch:Touch;
		
		
		public function RotateGesture(target:InteractiveObject = null)
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
				//TODO
				ignoreTouch(touch);
				return;
			}
			
			if (touchesCount == 1)
			{
				_firstTouch = touch;
			}
			else
			{
				_secondTouch = touch;
				
				_rotationVector = _secondTouch.location.subtract(_firstTouch.location);
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (touch.id == _firstTouch.id)
			{
				_firstTouch = touch;
			}
			else
			{
				_secondTouch = touch;
			}
			
			if (touchesCount == 2)
			{
				var recognized:Boolean;
				
				if (state == GestureState.POSSIBLE)
				{
					// we start once any finger moved enough
					if (touch.locationOffset.length > slop || slop != slop)//faster isNaN(slop)
					{
						recognized = true;
					}
				}
				else
				{
					recognized = true;
				}
				
				if (recognized)
				{
					var currRotationVector:Point = _secondTouch.location.subtract(_firstTouch.location);
					var rotation:Number = Math.atan2(currRotationVector.y, currRotationVector.x) - Math.atan2(_rotationVector.y, _rotationVector.x);
					rotation *= GestureUtils.RADIANS_TO_DEGREES;
					_rotationVector.x = currRotationVector.x;
					_rotationVector.y = currRotationVector.y;
					
					updateLocation();
					
					if (state == GestureState.POSSIBLE)
					{
						if (setState(GestureState.BEGAN) && hasEventListener(RotateGestureEvent.GESTURE_ROTATE))
						{
							dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GesturePhase.BEGIN, _localLocation.x, _localLocation.y, rotation));
						}
					}
					else
					{
						if (setState(GestureState.CHANGED) && hasEventListener(RotateGestureEvent.GESTURE_ROTATE))
						{
							dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, rotation));
						}
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
						dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GesturePhase.END, _localLocation.x, _localLocation.y, 0));
					}
				}
				else if (state == GestureState.POSSIBLE)
				{
					setState(GestureState.FAILED);
				}
			}
			else// == 1
			{
				if (touch.id == _firstTouch.id)
				{
					_firstTouch = _secondTouch;
				}
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					updateLocation();
					if (setState(GestureState.CHANGED) && hasEventListener(RotateGestureEvent.GESTURE_ROTATE))
					{
						dispatchEvent(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, 0));
					}
				}
			}
		}
	}
}
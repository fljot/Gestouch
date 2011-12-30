package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.RotateGestureEvent;
	import org.gestouch.utils.GestureUtils;

	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.events.TouchEvent;
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
		
		protected var _touchBeginX:Array = [];
		protected var _touchBeginY:Array = [];
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
		
			
		override public function reset():void
		{			
			_touchBeginX.length = 0;
			_touchBeginY.length = 0;

			super.reset();
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Protected methods
		//
		// --------------------------------------------------------------------------
		
		override protected function onTouchBegin(touch:Touch, event:TouchEvent):void
		{
			if (touchesCount > 2)
			{
				//TODO
				ignoreTouch(touch, event);
				return;
			}
			
			if (touchesCount == 1)
			{
				_firstTouch = touch;
			}
			else
			{
				_secondTouch = touch;
				
				_touchBeginX[_firstTouch.id] = _firstTouch.x;
				_touchBeginY[_firstTouch.id] = _firstTouch.y;
				_touchBeginX[_secondTouch.id] = _secondTouch.x;
				_touchBeginY[_secondTouch.id] = _secondTouch.y;
				
				_rotationVector.x = _secondTouch.x - _firstTouch.x;
				_rotationVector.y = _secondTouch.y - _firstTouch.y;
			}
		}
		
		
		override protected function onTouchMove(touch:Touch, event:TouchEvent):void
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
				var currRotationVector:Point = new Point(_secondTouch.x - _firstTouch.x, _secondTouch.y - _firstTouch.y);
				var recognized:Boolean;
				
				if (state == GestureState.POSSIBLE)
				{
					// we start once any finger moved enough
					var dx:Number = Number(_touchBeginX[touch.id]) - touch.x;
					var dy:Number = Number(_touchBeginY[touch.id]) - touch.y;
					if (Math.sqrt(dx*dx + dy*dy) > slop || slop != slop)//faster isNaN(slop)
					{
						recognized = true;
						_rotationVector.x = _secondTouch.x - _firstTouch.x;
						_rotationVector.y = _secondTouch.y - _firstTouch.y;
					}
				}
				else
				{
					recognized = true;
				}
				
				if (recognized)
				{
					updateLocation();
					
					var rotation:Number = Math.atan2(currRotationVector.y, currRotationVector.x) - Math.atan2(_rotationVector.y, _rotationVector.x);
					rotation *= GestureUtils.RADIANS_TO_DEGREES;
					_rotationVector.x = currRotationVector.x;
					_rotationVector.y = currRotationVector.y;
					
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
		
		
		override protected function onTouchEnd(touch:Touch, event:TouchEvent):void
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
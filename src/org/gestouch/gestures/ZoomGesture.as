package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.ZoomGestureEvent;

	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.geom.Point;

	[Event(name="gestureZoom", type="org.gestouch.events.ZoomGestureEvent")]
	/**
	 * TODO:
	 * -location
	 * -check native behavior on iDevice
	 * 
	 * @author Pavel fljot
	 */
	public class ZoomGesture extends Gesture
	{
		public var slop:Number = Gesture.DEFAULT_SLOP >> 1;
		public var lockAspectRatio:Boolean = true;
		
		protected var _scaleVector:Point = new Point();
		protected var _firstTouch:Touch;
		protected var _secondTouch:Touch;
		
		
		public function ZoomGesture(target:InteractiveObject = null)
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
				//TODO
				ignoreTouch(touch);
				return;
			}
			
			if (touchesCount == 1)
			{
				_firstTouch = touch;
			}
			else// == 2
			{
				_secondTouch = touch;
				
				_scaleVector = _secondTouch.location.subtract(_firstTouch.location);
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
					// Check if finger moved enough for gesture to be recognized
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
					var currScaleVector:Point = _secondTouch.location.subtract(_firstTouch.location);
					var scaleX:Number;
					var scaleY:Number;
					if (lockAspectRatio)
					{
						scaleX = scaleY = currScaleVector.length / _scaleVector.length;
					}
					else
					{
						scaleX = currScaleVector.x / _scaleVector.x;
						scaleY = currScaleVector.y / _scaleVector.y;
					}
					
					_scaleVector.x = currScaleVector.x;
					_scaleVector.y = currScaleVector.y;
					
					updateLocation();
					
					if (state == GestureState.POSSIBLE)
					{
						if (setState(GestureState.BEGAN) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))
						{
							dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.BEGIN, _localLocation.x, _localLocation.y, scaleX, scaleY));
						}
					}
					else
					{
						if (setState(GestureState.CHANGED) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))
						{
							dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, scaleX, scaleY));
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
					if (setState(GestureState.ENDED) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))
					{
						dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.END, _localLocation.x, _localLocation.y, 1, 1));
					}
				}
				else if (state == GestureState.POSSIBLE)
				{
					setState(GestureState.FAILED);
				}				
			}
			else//== 1
			{
				if (touch.id == _firstTouch.id)
				{
					_firstTouch = _secondTouch;
				}
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					updateLocation();
					if (setState(GestureState.CHANGED) && hasEventListener(ZoomGestureEvent.GESTURE_ZOOM))
					{
						dispatchEvent(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, 1, 1));
					}
				}
			}
		}
	}
}
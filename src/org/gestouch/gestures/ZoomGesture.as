package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.ZoomGestureEvent;

	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.events.TouchEvent;
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
		
		protected var _touchBeginX:Array = [];
		protected var _touchBeginY:Array = [];
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
			else// == 2
			{
				_secondTouch = touch;
				
				_touchBeginX[_firstTouch.id] = _firstTouch.x;
				_touchBeginY[_firstTouch.id] = _firstTouch.y;
				_touchBeginX[_secondTouch.id] = _secondTouch.x;
				_touchBeginY[_secondTouch.id] = _secondTouch.y;
				
				_scaleVector.x = _secondTouch.x - _firstTouch.x;
				_scaleVector.y = _secondTouch.y - _firstTouch.y;
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
				var currScaleVector:Point = new Point(_secondTouch.x - _firstTouch.x, _secondTouch.y - _firstTouch.y);
				var recognized:Boolean;
				
				if (state == GestureState.POSSIBLE)
				{
					// Check if finger moved enough for gesture to be recognized
					var dx:Number = Number(_touchBeginX[touch.id]) - touch.x;
					var dy:Number = Number(_touchBeginY[touch.id]) - touch.y;
					if (Math.sqrt(dx*dx + dy*dy) > slop || slop != slop)//faster isNaN(slop)
					{
						recognized = true;
						_scaleVector.x = _secondTouch.x - _firstTouch.x;
						_scaleVector.y = _secondTouch.y - _firstTouch.y;
					}
				}
				else
				{
					recognized = true;
				}
				
				if (recognized)
				{
					updateLocation();
					
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
					
					if (state == GestureState.POSSIBLE)
					{
						setState(GestureState.BEGAN, new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.BEGIN, _localLocation.x, _localLocation.y, scaleX, scaleY));
					}
					else
					{
						setState(GestureState.CHANGED, new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, scaleX, scaleY));
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
					setState(GestureState.ENDED, new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.END, _localLocation.x, _localLocation.y, 1, 1));
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
					setState(GestureState.CHANGED, new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, 1, 1));
				}
			}
		}
	}
}
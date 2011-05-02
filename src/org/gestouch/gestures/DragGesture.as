package org.gestouch.gestures
{
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.events.TouchEvent;
	import org.gestouch.core.GesturesManager;
	import org.gestouch.core.TouchPoint;
	import org.gestouch.core.gestouch_internal;
	import org.gestouch.events.DragGestureEvent;




	/**
	 * Tracks the drag. Event works nice with minTouchPointsCount = 1 and maxTouchPoaintsCount > 1.
	 * 
	 * <p>DragGestureEvent has 3 possible phases: GesturePhase.BEGIN, GesturePhase.UPDATE, GesturePhase.END</p>
	 * 
	 * @see org.gestouch.events.DragGestureEvent
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/GestureEvent.html#phase
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/GesturePhase.html
	 * 
	 * @author Pavel fljot
	 */
	public class DragGesture extends MovingGestureBase
	{
		public function DragGesture(target:InteractiveObject = null, settings:Object = null)
		{
			super(target, settings);
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Static methods
		//
		//--------------------------------------------------------------------------
		
		public static function add(target:InteractiveObject, settings:Object = null):DragGesture
		{
			return new DragGesture(target, settings);
		}
		
		
		public static function remove(target:InteractiveObject):DragGesture
		{
			return GesturesManager.gestouch_internal::removeGestureByTarget(DragGesture, target) as DragGesture;
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		override public function reflect():Class
		{
			return DragGesture;
		}
		
		
		override public function shouldTrackPoint(event:TouchEvent, tp:TouchPoint):Boolean
		{
			// No need to track more points than we need
			if (_trackingPointsCount == maxTouchPointsCount)
			{
				return false;
			}
			// this particular gesture is interested only in those touchpoints on top of target
			var touchTarget:InteractiveObject = event.target as InteractiveObject;
			if (touchTarget != target && !(target is DisplayObjectContainer && (target as DisplayObjectContainer).contains(touchTarget)))
			{
				return false;
			}
			
			return true;
		}
		
		
		override public function onTouchBegin(touchPoint:TouchPoint):void
		{
			// No need to track more points than we need
			if (_trackingPointsCount == maxTouchPointsCount)
			{
				return;
			}
			
			_trackPoint(touchPoint);
			
			if (_trackingPointsCount > 1)
			{
				_adjustCentralPoint();
				_centralPoint.lastMove.x = _centralPoint.lastMove.y = 0;
			}
		}
		
		
		override public function onTouchMove(touchPoint:TouchPoint):void
		{
			// do calculations only when we track enough points
			if (_trackingPointsCount < minTouchPointsCount)
			{
				return;
			}
			
			_adjustCentralPoint();
			 
			if (!_slopPassed)
			{
				_slopPassed = _checkSlop(_centralPoint.moveOffset);
				
				if (_slopPassed)
				{
					_centralPoint.lastMove.x = _centralPoint.lastMove.y = 0;
					_dispatch(new DragGestureEvent(DragGestureEvent.GESTURE_DRAG, true, false, GesturePhase.BEGIN, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
				}
			}
			
			if (_slopPassed)
			{
				_dispatch(new DragGestureEvent(DragGestureEvent.GESTURE_DRAG, true, false, GesturePhase.UPDATE, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y, 1, 1, 0, _centralPoint.lastMove.x, _centralPoint.lastMove.y));
			}
		}
		
		
		override public function onTouchEnd(touchPoint:TouchPoint):void
		{
			var ending:Boolean = (_trackingPointsCount == minTouchPointsCount);
			_forgetPoint(touchPoint);
			
			_adjustCentralPoint();
			_centralPoint.lastMove.x = _centralPoint.lastMove.y = 0;
			
			if (ending)
			{
				_reset();
				_dispatch(new DragGestureEvent(DragGestureEvent.GESTURE_DRAG, true, false, GesturePhase.END, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y, 1, 1, 0, 0, 0));
			}
		}
	}
}
package org.gestouch.gestures
{
	import org.gestouch.GestureUtils;
	import org.gestouch.core.GesturesManager;
	import org.gestouch.core.TouchPoint;
	import org.gestouch.core.gestouch_internal;
	import org.gestouch.events.RotateGestureEvent;

	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.geom.Point;


	[Event(name="gestureRotate", type="org.gestouch.events.RotateGestureEvent")]
	/**
	 * @author Pavel fljot
	 */
	public class RotateGesture extends Gesture
	{		
		
		protected var _currVector:Point = new Point();
		protected var _lastVector:Point = new Point();
		
		
		public function RotateGesture(target:InteractiveObject, settings:Object = null)
		{
			super(target, settings);
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Static methods
		//
		//--------------------------------------------------------------------------
		
		public static function add(target:InteractiveObject = null, settings:Object = null):RotateGesture
		{
			return new RotateGesture(target, settings);
		}
		
		
		public static function remove(target:InteractiveObject):RotateGesture
		{
			return GesturesManager.gestouch_internal::removeGestureByTarget(RotateGesture, target) as RotateGesture;
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		override public function onCancel():void
		{
			super.onCancel();
			
			
		}
		
		
		override public function reflect():Class
		{
			return RotateGesture;
		}
		
		
		override public function onTouchBegin(touchPoint:TouchPoint):void
		{
			// No need to track more points than we need
			if (_trackingPointsCount == maxTouchPointsCount)
			{
				return;
			}
			
			_trackPoint(touchPoint);
			
			if (_trackingPointsCount == minTouchPointsCount)
			{
				_lastVector.x = _trackingPoints[1].x - _trackingPoints[0].x;
				_lastVector.y = _trackingPoints[1].y - _trackingPoints[0].y;
				
				_updateCentralPoint();
				
				_dispatch(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, true, false, GesturePhase.BEGIN, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
			}
		}
		
		
		override public function onTouchMove(touchPoint:TouchPoint):void
		{
			// do calculations only when we track enough points
			if (_trackingPointsCount < minTouchPointsCount)
			{
				return;
			}
			
			_updateCentralPoint();
			
			_currVector.x = _trackingPoints[1].x - _trackingPoints[0].x;
			_currVector.y = _trackingPoints[1].y - _trackingPoints[0].y;
			
			var a1:Number = Math.atan2(_lastVector.y, _lastVector.x);
			var a2:Number = Math.atan2(_currVector.y, _currVector.x);
			var angle:Number = a2 - a1;
			angle *= GestureUtils.RADIANS_TO_DEGREES; 
			
			_lastVector.x = _currVector.x;
			_lastVector.y = _currVector.y;
			
			_dispatch(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, true, false, GesturePhase.UPDATE, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y, 1, 1, angle));
		}
		
		
		override public function onTouchEnd(touchPoint:TouchPoint):void
		{
			var ending:Boolean = (_trackingPointsCount == minTouchPointsCount);
			_forgetPoint(touchPoint);
			
			if (ending)
			{
				_dispatch(new RotateGestureEvent(RotateGestureEvent.GESTURE_ROTATE, true, false, GesturePhase.END, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
			}
		}
		
		
		override protected function _preinit():void
		{
			super._preinit();
			
			minTouchPointsCount = 2;
		}
	}
}
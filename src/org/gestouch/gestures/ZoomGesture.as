package org.gestouch.gestures
{
	import org.gestouch.core.GesturesManager;
	import org.gestouch.core.TouchPoint;
	import org.gestouch.core.gestouch_internal;
	import org.gestouch.events.ZoomGestureEvent;

	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.geom.Point;


	[Event(name="gestureZoom", type="org.gestouch.events.ZoomGestureEvent")]
	/**
	 * @author Pavel fljot
	 */
	public class ZoomGesture extends Gesture
	{	
		public var lockAspectRatio:Boolean = true;
		
		protected var _currVector:Point = new Point();
		protected var _lastVector:Point = new Point();
		
		
		public function ZoomGesture(target:InteractiveObject, settings:Object = null)
		{
			super(target, settings);
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Static methods
		//
		//--------------------------------------------------------------------------
		
		public static function add(target:InteractiveObject = null, settings:Object = null):ZoomGesture
		{
			return new ZoomGesture(target, settings);
		}
		
		
		public static function remove(target:InteractiveObject):ZoomGesture
		{
			return GesturesManager.gestouch_internal::removeGestureByTarget(ZoomGesture, target) as ZoomGesture;
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------		
		
		override public function reflect():Class
		{
			return ZoomGesture;
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
				
				_dispatch(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, true, false, GesturePhase.BEGIN, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
			}
		}
		
		
		override public function onTouchMove(touchPoint:TouchPoint):void
		{
			// do calculations only when we track enought points
			if (_trackingPointsCount < minTouchPointsCount)
			{
				return;
			}
			
			_updateCentralPoint();
			
			_currVector.x = _trackingPoints[1].x - _trackingPoints[0].x;
			_currVector.y = _trackingPoints[1].y - _trackingPoints[0].y;
			
			var scaleX:Number = _currVector.x / _lastVector.x;
			var scaleY:Number = _currVector.y / _lastVector.y;
			if (lockAspectRatio)
			{
				scaleX = scaleY = _currVector.length / _lastVector.length;
			}
			else
			{
				scaleX = _currVector.x / _lastVector.x;
				scaleY = _currVector.y / _lastVector.y;
			}
			
			_lastVector.x = _currVector.x;
			_lastVector.y = _currVector.y;
			
			_dispatch(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, true, false, GesturePhase.UPDATE, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y, scaleX, scaleY));
		}
		
		
		override public function onTouchEnd(touchPoint:TouchPoint):void
		{
			var ending:Boolean = (_trackingPointsCount == minTouchPointsCount);
			_forgetPoint(touchPoint);
			
			if (ending)
			{
				_dispatch(new ZoomGestureEvent(ZoomGestureEvent.GESTURE_ZOOM, true, false, GesturePhase.END, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
			}
		}
		
		
		override protected function _preinit():void
		{
			super._preinit();
			
			minTouchPointsCount = 2;
			
			_propertyNames.push("lockAspectRatio");
		}
	}
}
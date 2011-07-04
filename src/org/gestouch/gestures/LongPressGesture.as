package org.gestouch.gestures
{
	import org.gestouch.core.GesturesManager;
	import org.gestouch.core.TouchPoint;
	import org.gestouch.core.gestouch_internal;
	import org.gestouch.events.LongPressGestureEvent;

	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.events.TimerEvent;
	import flash.utils.Timer;



	/**
	 * 
	 * 
	 * @author Pavel fljot
	 */
	public class LongPressGesture extends Gesture
	{
		/**
		 * Default value 1000ms
		 */
		public var timeThreshold:uint = 500;
		/**
		 * Deafult value is Gesture.DEFAULT_SLOP
		 * @see org.gestouchers.core.Gesture#DEFAULT_SLOP
		 */
		public var slop:Number = Gesture.DEFAULT_SLOP;
		
		protected var _thresholdTimer:Timer;
		
		
		public function LongPressGesture(target:InteractiveObject = null, settings:Object = null)
		{
			super(target, settings);
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Static methods
		//
		//--------------------------------------------------------------------------
		
		public static function add(target:InteractiveObject, settings:Object = null):LongPressGesture
		{
			return new LongPressGesture(target, settings);
		}
		
		
		public static function remove(target:InteractiveObject):LongPressGesture
		{
			return GesturesManager.gestouch_internal::removeGestureByTarget(LongPressGesture, target) as LongPressGesture;
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		override public function reflect():Class
		{
			return LongPressGesture;
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
				_thresholdTimer.reset();
				_thresholdTimer.delay = timeThreshold;
				_thresholdTimer.start();
			}
		}
		
		
		override public function onTouchMove(touchPoint:TouchPoint):void
		{
			// faster isNaN
			if (_thresholdTimer.currentCount == 0 && slop == slop)
			{
				if (touchPoint.moveOffset.length > slop)
				{
					cancel();
				}
			}
		}
		
		
		override public function onTouchEnd(touchPoint:TouchPoint):void
		{			
			_forgetPoint(touchPoint);
			
			var held:Boolean = (_thresholdTimer.currentCount > 0);
			_thresholdTimer.reset();
			
			if (held)
			{
				_updateCentralPoint();
				_reset();
				_dispatch(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, true, false, GesturePhase.END, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
			}
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		override protected function _preinit():void
		{
			super._preinit();
			
			_thresholdTimer = new Timer(timeThreshold, 1);
			_thresholdTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _onThresholdTimerComplete);
			
			_propertyNames.push("timeThreshold", "slop");
		}
		
			
		override protected function _reset():void
		{
			super._reset();
			
			_thresholdTimer.reset();
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------

		protected function _onThresholdTimerComplete(event:TimerEvent):void
		{
			_updateCentralPoint();
			_dispatch(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, true, false, GesturePhase.BEGIN, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
		}
	}
}
package org.gestouch.gestures
{
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	import org.gestouch.core.GesturesManager;
	import org.gestouch.core.TouchPoint;
	import org.gestouch.core.gestouch_internal;
	import org.gestouch.events.DoubleTapGestureEvent;




	/**
	 * DoubleTapGesture tracks quick double-tap (double-click).
	 * 
	 * <p>Gesture-specific configuratin properties:<br/><br/>
	 * timeThreshold — time between first touchBegin and second touchEnd events,<br/><br/>
	 * moveThreshold — maximum allowed distance between two taps.</p>
	 * 
	 * 
	 * @author Pavel fljot
	 */
	public class DoubleTapGesture extends Gesture
	{
		/**
		 * Time in milliseconds between touchBegin and touchEnd events for gesture to be detected.
		 * 
		 * <p>For multitouch usage this is a bit more complex then "first touchBeing and second touchEnd":
		 * Taps are counted once <code>minTouchPointsCount</code> of touch points are down and then fully released.
		 * So it's time in milliseconds between full press and full release events for gesture to be detected.</p>
		 * 
		 * @default 400
		 */
		public var timeThreshold:uint = 400;
		/**
		 * Maximum allowed distance between two taps for gesture to be detected.
		 * 
		 * @default Gesture.DEFAULT_SLOP &#42; 3
		 * 
		 * @see org.gestouch.gestures.Gesture#DEFAULT_SLOP
		 */
		public var moveThreshold:Number = Gesture.DEFAULT_SLOP * 3;
		
		/**
		 * Timer used to track time between taps.
		 */
		protected var _thresholdTimer:Timer;
		/**
		 * Count taps (where tap is an action of changing _touchPointsCount from 0 to minTouchPointsCount
		 * and back to 0. For single touch gesture it would be common tap, for 2-touch gesture it would be
		 * both fingers down, then both fingers up, etc...)
		 */
		protected var _tapCounter:int = 0;
		/**
		 * Flag to detect "complex tap".
		 */
		protected var _minTouchPointsCountReached:Boolean;
		/**
		 * Used to check moveThreshold.
		 */
		protected var _prevCentralPoint:Point;
		/**
		 * Used to check moveThreshold.
		 */
		protected var _lastCentralPoint:Point;
		
		
		public function DoubleTapGesture(target:InteractiveObject = null, settings:Object = null)
		{
			super(target, settings);
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Static methods
		//
		//--------------------------------------------------------------------------
		
		public static function add(target:InteractiveObject, settings:Object = null):DoubleTapGesture
		{
			return new DoubleTapGesture(target, settings);
		}
		
		
		public static function remove(target:InteractiveObject):DoubleTapGesture
		{
			return GesturesManager.gestouch_internal::removeGestureByTarget(DoubleTapGesture, target) as DoubleTapGesture;
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------	
		
		override public function reflect():Class
		{
			return DoubleTapGesture;
		}
		
		
		override public function shouldTrackPoint(event:TouchEvent, touchPoint:TouchPoint):Boolean
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
			
			if (_trackingPointsCount == minTouchPointsCount)
			{
				if (!_thresholdTimer.running)
				{
					// first touchBegin combo (all the required fingers are on the screen)
					_tapCounter = 0;
					_thresholdTimer.reset();
					_thresholdTimer.delay = timeThreshold;
					_thresholdTimer.start();
					_adjustCentralPoint();
				}
				
				_minTouchPointsCountReached = true;
				
				if (moveThreshold > 0)
				{ 
					// calculate central point for future moveThreshold comparsion
					_adjustCentralPoint();
					// save points for later comparsion with moveThreshold
					_prevCentralPoint = _lastCentralPoint;
					_lastCentralPoint = _centralPoint.clone();
				}
			}
		}
		
		
		override public function onTouchMove(touchPoint:TouchPoint):void
		{
			// nothing to do here
		}
		
		
		override public function onTouchEnd(touchPoint:TouchPoint):void
		{			
			// As we a here, this means timer hasn't fired yet (and therefore hasn't cancelled this gesture)
			
			_forgetPoint(touchPoint);
			
			// if last finger released
			if (_trackingPointsCount == 0)
			{
				if (_minTouchPointsCountReached)
				{
					_tapCounter++;
					// reset for next "all fingers down"
					_minTouchPointsCountReached = false;
				}
				
				if (_tapCounter >= 2)
				{
					// double tap combo recognized
					
					if (moveThreshold > 0)
					{						
						if (_lastCentralPoint.subtract(_prevCentralPoint).length < moveThreshold)
						{
							_reset();
							_dispatch(new DoubleTapGestureEvent(DoubleTapGestureEvent.GESTURE_DOUBLE_TAP, true, false, GesturePhase.ALL, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
						}
					}
					else
					{
						// no moveThreshold defined
						_reset();
						_dispatch(new DoubleTapGestureEvent(DoubleTapGestureEvent.GESTURE_DOUBLE_TAP, true, false, GesturePhase.ALL, _lastLocalCentralPoint.x, _lastLocalCentralPoint.y));
					}
				}
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
			_thresholdTimer.addEventListener(TimerEvent.TIMER_COMPLETE, _thresholdTimer_timerCompleteHandler);
			
			_propertyNames.push("timeThreshold", "moveThreshold");
		}
		
			
		override protected function _reset():void
		{
			super._reset();
			
			_tapCounter = 0;
			_minTouchPointsCountReached = false;
			_thresholdTimer.reset();
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		protected function _thresholdTimer_timerCompleteHandler(event:TimerEvent):void
		{
			cancel();
		}
	}
}
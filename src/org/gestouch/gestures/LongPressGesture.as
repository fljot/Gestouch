package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.LongPressGestureEvent;

	import flash.events.TimerEvent;
	import flash.utils.Timer;


	/**
	 * 
	 * @eventType org.gestouch.events.LongPressGestureEvent
	 */
	[Event(name="gestureLongPress", type="org.gestouch.events.LongPressGestureEvent")]
	/**
	 * TODO:
	 * - add numTapsRequired
	 * 
	 * @author Pavel fljot
	 */
	public class LongPressGesture extends Gesture
	{
		public var numTouchesRequired:uint = 1;
		/**
		 * The minimum time interval in millisecond fingers must press on the target for the gesture to be recognized.
		 * 
		 * @default 500
		 */
		public var minPressDuration:uint = 500;
		public var slop:Number = Gesture.DEFAULT_SLOP;
		
		protected var _timer:Timer;
		protected var _numTouchesRequiredReached:Boolean;
		
		
		public function LongPressGesture(target:Object = null)
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
			return TapGesture;
		}
		
			
		override public function reset():void
		{
			super.reset();
			
			_numTouchesRequiredReached = false;
			_timer.reset();
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Protected methods
		//
		// --------------------------------------------------------------------------
		
		override protected function preinit():void
		{
			super.preinit();
			
			_timer = new Timer(minPressDuration, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_timerCompleteHandler);
		}
		
		
		override protected function onTouchBegin(touch:Touch):void
		{
			if (touchesCount > numTouchesRequired)
			{
				failOrIgnoreTouch(touch);
				return;
			}
			
			if (touchesCount == numTouchesRequired)
			{
				_numTouchesRequiredReached = true;
				_timer.reset();
				_timer.delay = minPressDuration || 1;
				_timer.start();
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (state == GestureState.POSSIBLE && slop > 0 && touch.locationOffset.length > slop)
			{
				setState(GestureState.FAILED);
			}
			else if (state == GestureState.BEGAN || state == GestureState.CHANGED)
			{
				updateLocation();
				if (setState(GestureState.CHANGED) && hasEventListener(LongPressGestureEvent.GESTURE_LONG_PRESS))
				{
					dispatchEvent(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, false, false, GestureState.CHANGED,
						_location.x, _location.y, _localLocation.x, _localLocation.y));
				}
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			if (_numTouchesRequiredReached)
			{
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					updateLocation();
					if (setState(GestureState.ENDED) && hasEventListener(LongPressGestureEvent.GESTURE_LONG_PRESS))
					{
						dispatchEvent(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, false, false, GestureState.ENDED,
							_location.x, _location.y, _localLocation.x, _localLocation.y));
					} 
				}
				else
				{
					setState(GestureState.FAILED);
				}
			}
			else
			{
				setState(GestureState.FAILED);
			}
		}
		
		
		override protected function onDelayedRecognize():void
		{
			if (hasEventListener(LongPressGestureEvent.GESTURE_LONG_PRESS))
			{
				dispatchEvent(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, false, false, GestureState.BEGAN,
						_location.x, _location.y, _localLocation.x, _localLocation.y));
			}
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		protected function timer_timerCompleteHandler(event:TimerEvent = null):void
		{
			if (state == GestureState.POSSIBLE)
			{
				updateLocation();
				if (setState(GestureState.BEGAN) && hasEventListener(LongPressGestureEvent.GESTURE_LONG_PRESS))
				{
					dispatchEvent(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, false, false, GestureState.BEGAN,
							_location.x, _location.y, _localLocation.x, _localLocation.y));
				}
			}
		}
	}
}
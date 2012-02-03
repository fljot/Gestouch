package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.LongPressGestureEvent;

	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.events.TimerEvent;
	import flash.utils.Timer;


	/**
	 * TODO: -location
	 * - check on iOS (Obj-C) what happens when numTouchesRequired=2, two finger down, then quickly release one.
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
		protected var _touchBeginX:Array = [];
		protected var _touchBeginY:Array = [];
		protected var _numTouchesRequiredReached:Boolean;
		
		
		public function LongPressGesture(target:InteractiveObject = null)
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
			
			_touchBeginX.length = 0;
			_touchBeginY.length = 0;
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
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					ignoreTouch(touch);
				}
				else
				{
					setState(GestureState.FAILED);
				}
				return;
			}
			
			_touchBeginX[touch.id] = touch.x;
			_touchBeginY[touch.id] = touch.y;
			
			if (touchesCount == numTouchesRequired)
			{
				_numTouchesRequiredReached = true;
				_timer.reset();
				_timer.delay = minPressDuration;
				if (minPressDuration > 0)
				{
					_timer.start();
				}
				else
				{
					timer_timerCompleteHandler();
				}
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (state == GestureState.POSSIBLE && slop > 0)
			{
				// Fail if touch overcome slop distance
				var dx:Number = Number(_touchBeginX[touch.id]) - touch.x;
				var dy:Number = Number(_touchBeginY[touch.id]) - touch.y;
				if (Math.sqrt(dx*dx + dy*dy) > slop)
				{
					setState(GestureState.FAILED);
					return;
				}
			}
			else if (state == GestureState.BEGAN || state == GestureState.CHANGED)
			{
				updateLocation();
				if (setState(GestureState.CHANGED) && hasEventListener(LongPressGestureEvent.GESTURE_LONG_PRESS))
				{
					dispatchEvent(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y));
				}
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			//TODO: check proper condition (behavior) on iOS native
			if (_numTouchesRequiredReached)
			{
				if (((GestureState.BEGAN | GestureState.CHANGED) & state) > 0)
				{
					updateLocation();
					if (setState(GestureState.ENDED) && hasEventListener(LongPressGestureEvent.GESTURE_LONG_PRESS))
					{
						dispatchEvent(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, false, false, GesturePhase.END, _localLocation.x, _localLocation.y));
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
					dispatchEvent(new LongPressGestureEvent(LongPressGestureEvent.GESTURE_LONG_PRESS, false, false, GesturePhase.BEGIN, _localLocation.x, _localLocation.y));
				}
			}
		}
	}
}
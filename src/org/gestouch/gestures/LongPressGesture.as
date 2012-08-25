package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;

	import flash.events.TimerEvent;
	import flash.utils.Timer;


	/**
	 * TODO:
	 * - add numTapsRequired
	 * 
	 * @author Pavel fljot
	 */
	public class LongPressGesture extends AbstractContinuousGesture
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
			return LongPressGesture;
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
				setState(GestureState.CHANGED);
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			if (_numTouchesRequiredReached)
			{
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					updateLocation();
					setState(GestureState.ENDED);
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
				setState(GestureState.BEGAN);
			}
		}
	}
}
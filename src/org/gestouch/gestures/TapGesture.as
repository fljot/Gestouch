package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.TapGestureEvent;

	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.utils.Timer;


	/**
	 * TODO: check failing conditions (iDevice)
	 * 
	 * @author Pavel fljot
	 */
	public class TapGesture extends Gesture
	{
		public var numTouchesRequired:uint = 1;
		public var numTapsRequired:uint = 1;
		public var slop:Number = Gesture.DEFAULT_SLOP;
		public var maxTapDelay:uint = 400;
		public var maxTapDuration:uint = 1500;
		
		protected var _timer:Timer;
		protected var _touchBeginX:Array = [];
		protected var _touchBeginY:Array = [];
		protected var _numTouchesRequiredReached:Boolean;
		protected var _tapCounter:uint = 0;
		
		
		public function TapGesture(target:InteractiveObject = null)
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
			_touchBeginX.length = 0;
			_touchBeginY.length = 0;
			_numTouchesRequiredReached = false;
			_tapCounter = 0;
			_timer.reset();

			super.reset();
		}
		
			
		override public function canPreventGesture(preventedGesture:Gesture):Boolean
		{
			if (preventedGesture is TapGesture &&
				(preventedGesture as TapGesture).numTapsRequired > this.numTapsRequired)
			{
				return false;
			}
			return true;
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Protected methods
		//
		// --------------------------------------------------------------------------
		
		override protected function preinit():void
		{
			super.preinit();
			
			_timer = new Timer(maxTapDelay, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_timerCompleteHandler);
		}
		
		
		override protected function onTouchBegin(touch:Touch, event:TouchEvent):void
		{
			if (touchesCount > numTouchesRequired)
			{
				// We put more fingers then required at the same time,
				// so treat that as failed
				setState(GestureState.FAILED);
				return;
			}
			
			_touchBeginX[touch.id] = touch.x;
			_touchBeginY[touch.id] = touch.y;
			
			if (touchesCount == 1)
			{
				_timer.reset();
				_timer.delay = maxTapDuration;
				_timer.start();
			}
			
			if (touchesCount == numTouchesRequired)
			{
				_numTouchesRequiredReached = true;				
			}
		}
		
		
		override protected function onTouchMove(touch:Touch, event:TouchEvent):void
		{
			if (slop >= 0)
			{
				// Fail if touch overcome slop distance
				var dx:Number = Number(_touchBeginX[touch.id]) - touch.x;
				var dy:Number = Number(_touchBeginY[touch.id]) - touch.y;
				if (Math.sqrt(dx*dx + dy*dy) > slop)
				{
					setState(GestureState.FAILED);
				}
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch, event:TouchEvent):void
		{
			if (!_numTouchesRequiredReached)
			{
				//TODO: check this condition on iDevice
				setState(GestureState.FAILED);
			}
			else if (touchesCount == 0)
			{
				// reset flag for the next "full press" cycle
				_numTouchesRequiredReached = false;
				
				_tapCounter++;
				_timer.reset();
				
				if (_tapCounter == numTapsRequired)
				{
					updateLocation();
					setState(GestureState.RECOGNIZED, new TapGestureEvent(TapGestureEvent.GESTURE_TAP, false, false, GesturePhase.ALL, _localLocation.x, _localLocation.y));
				}
				else
				{
					_timer.delay = maxTapDelay;
					_timer.start();
				}
			}
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		protected function timer_timerCompleteHandler(event:TimerEvent):void
		{
			if (state == GestureState.POSSIBLE)
			{
				setState(GestureState.FAILED);
			}
		}
	}
}
package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.utils.GestureUtils;

	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.utils.Timer;


	/**
	 * Recognition logic:<br/>
	 * 1. should be recognized during <code>maxDuration</code> period<br/>
	 * 2. velocity >= minVelocity <b>OR</b> offset >= minOffset
	 * 
	 * 
	 * @author Pavel fljot
	 */
	public class SwipeGesture extends AbstractDiscreteGesture
	{
		private static const ANGLE:Number = 40 * GestureUtils.DEGREES_TO_RADIANS;
		private static const MAX_DURATION:uint = 500;
		private static const MIN_OFFSET:Number = Capabilities.screenDPI / 6;
		private static const MIN_VELOCITY:Number = 2 * MIN_OFFSET / MAX_DURATION;
		
		/**
		 * "Dirty" region around touch begin location which is not taken into account for
		 * recognition/failing algorithms.
		 * 
		 * @default Gesture.DEFAULT_SLOP
		 */
		public var slop:Number = Gesture.DEFAULT_SLOP;
		public var numTouchesRequired:uint = 1;
		public var direction:uint = SwipeGestureDirection.ORTHOGONAL;
		
		/**
		 * The duration of period (in milliseconds) in which SwipeGesture must be recognized.
		 * If gesture is not recognized during this period it fails. Default value is 500 (half a
		 * second) and generally should not be changed. You can change it though for some special
		 * cases, most likely together with <code>minVelocity</code> and <code>minOffset</code>
		 * to achieve really custom behavior. 
		 * 
		 * @default 500
		 * 
		 * @see #minVelocity
		 * @see #minOffset
		 */
		public var maxDuration:uint = MAX_DURATION;
		
		/**
		 * Minimum offset (in pixels) for gesture to be recognized.
		 * Default value is <code>Capabilities.screenDPI / 6</code> and generally should not
		 * be changed.
		 */
		public var minOffset:Number = MIN_OFFSET;
		
		/**
		 * Minimum velocity (in pixels per millisecond) for gesture to be recognized.
		 * Default value is <code>2 * minOffset / maxDuration</code> and generally should not
		 * be changed.
		 * 
		 * @see #minOffset
		 * @see #minDuration
		 */
		public var minVelocity:Number = MIN_VELOCITY;
		
		protected var _offset:Point = new Point();
		protected var _startTime:int;
		protected var _noDirection:Boolean;
		protected var _avrgVel:Point = new Point();
		protected var _timer:Timer;
		
		
		public function SwipeGesture(target:Object = null)
		{
			super(target);
		}
		
		
		public function get offsetX():Number
		{
			return _offset.x;
		}
		
		
		public function get offsetY():Number
		{
			return _offset.y;
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Public methods
		//
		// --------------------------------------------------------------------------
		
		override public function reflect():Class
		{
			return SwipeGesture;
		}
		
		
		override public function reset():void
		{
			_startTime = 0;
			_offset.x = 0;
			_offset.y = 0;
			_timer.reset();
			
			super.reset();
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Protected methods
		//
		// --------------------------------------------------------------------------
		
		override protected function preinit():void
		{
			super.preinit();
			
			_timer = new Timer(maxDuration, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, timer_timerCompleteHandler);
		}
		
		
		override protected function onTouchBegin(touch:Touch):void
		{
			if (touchesCount > numTouchesRequired)
			{
				failOrIgnoreTouch(touch);
				return;
			}
			
			if (touchesCount == 1)
			{
				// Because we want to fail as quick as possible
				_startTime = touch.time;
				
				_timer.reset();
				_timer.delay = maxDuration;
				_timer.start();
			}
			if (touchesCount == numTouchesRequired)
			{
				updateLocation();
				_avrgVel.x = _avrgVel.y = 0;
				
				// cache direction condition for performance
				_noDirection = (SwipeGestureDirection.ORTHOGONAL & direction) == 0;
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (touchesCount < numTouchesRequired)
				return;
			
			var totalTime:int = touch.time - _startTime;
			if (totalTime == 0)
				return;//It was somehow THAT MUCH performant on one Android tablet
			
			var prevCentralPointX:Number = _centralPoint.x;
			var prevCentralPointY:Number = _centralPoint.y;
			updateCentralPoint();
			
			_offset.x = _centralPoint.x - _location.x;
			_offset.y = _centralPoint.y - _location.y;
			var offsetLength:Number = _offset.length;
			
			// average velocity (total offset to total duration)
			_avrgVel.x = _offset.x / totalTime;
			_avrgVel.y = _offset.y / totalTime;
			var avrgVel:Number = _avrgVel.length;
			
			if (_noDirection)
			{
				if ((offsetLength > slop || slop != slop) &&
					(avrgVel >= minVelocity || offsetLength >= minOffset))
				{
					setState(GestureState.RECOGNIZED);
				}
			}
			else
			{
				var recentOffsetX:Number = _centralPoint.x - prevCentralPointX;
				var recentOffsetY:Number = _centralPoint.y - prevCentralPointY;
				//faster Math.abs()
				var absVelX:Number = _avrgVel.x > 0 ? _avrgVel.x : -_avrgVel.x;
				var absVelY:Number = _avrgVel.y > 0 ? _avrgVel.y : -_avrgVel.y;
				
				if (absVelX > absVelY)
				{
					var absOffsetX:Number = _offset.x > 0 ? _offset.x : -_offset.x;
					
					if (absOffsetX > slop || slop != slop)//faster isNaN()
					{
						if ((recentOffsetX < 0 && (direction & SwipeGestureDirection.LEFT) == 0) ||
							(recentOffsetX > 0 && (direction & SwipeGestureDirection.RIGHT) == 0) ||
							Math.abs(Math.atan(_offset.y/_offset.x)) > ANGLE)
						{
							// movement in opposite direction
							// or too much diagonally
							
							setState(GestureState.FAILED);
						}
						else if (absVelX >= minVelocity || absOffsetX >= minOffset)
						{
							_offset.y = 0;
							setState(GestureState.RECOGNIZED);
						}
					}
				}
				else if (absVelY > absVelX)
				{
					var absOffsetY:Number = _offset.y > 0 ? _offset.y : -_offset.y;
					if (absOffsetY > slop || slop != slop)//faster isNaN()
					{
						if ((recentOffsetY < 0 && (direction & SwipeGestureDirection.UP) == 0) ||
							(recentOffsetY > 0 && (direction & SwipeGestureDirection.DOWN) == 0) ||
							Math.abs(Math.atan(_offset.x/_offset.y)) > ANGLE)
						{
							// movement in opposite direction
							// or too much diagonally
							
							setState(GestureState.FAILED);
						}
						else if (absVelY >= minVelocity || absOffsetY >= minOffset)
						{
							_offset.x = 0;
							setState(GestureState.RECOGNIZED);
						}
					}
				}
				// Give some tolerance for accidental offset on finger press (slop)
				else if (offsetLength > slop || slop != slop)//faster isNaN()
				{
					setState(GestureState.FAILED);
				}
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			if (touchesCount < numTouchesRequired)
			{
				setState(GestureState.FAILED);
			}
		}
		
		
		override protected function resetNotificationProperties():void
		{
			super.resetNotificationProperties();
			
			_offset.x = _offset.y = 0;
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
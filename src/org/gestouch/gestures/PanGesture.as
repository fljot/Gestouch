package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.PanGestureEvent;

	import flash.geom.Point;

	[Event(name="gesturePan", type="org.gestouch.events.PanGestureEvent")]
	/**
	 * TODO:
	 * -location
	 * -check native behavior on iDevice
	 * 
	 * @author Pavel fljot
	 */
	public class PanGesture extends Gesture
	{
		public var slop:Number = Gesture.DEFAULT_SLOP;
		/**
		 * Used for initial slop overcome calculations only.
		 */
		public var direction:uint = PanGestureDirection.NO_DIRECTION;
		
		protected var _gestureBeginOffsetX:Number;
		protected var _gestureBeginOffsetY:Number;
		
		
		public function PanGesture(target:Object = null)
		{
			super(target);
		}
		
		
		/** @private */
		private var _maxNumTouchesRequired:uint = 1;
		
		/**
		 * 
		 */
		public function get maxNumTouchesRequired():uint
		{
			return _maxNumTouchesRequired;
		}
		public function set maxNumTouchesRequired(value:uint):void
		{
			if (_maxNumTouchesRequired == value)
				return;
			
			if (value < minNumTouchesRequired)
				throw ArgumentError("maxNumTouchesRequired must be not less then minNumTouchesRequired");
			
			_maxNumTouchesRequired = value;
		}
		
		
		/** @private */
		private var _minNumTouchesRequired:uint = 1;
		
		/**
		 * 
		 */
		public function get minNumTouchesRequired():uint
		{
			return _minNumTouchesRequired;
		}
		public function set minNumTouchesRequired(value:uint):void
		{
			if (_minNumTouchesRequired == value)
				return;
			
			if (value > maxNumTouchesRequired)
				throw ArgumentError("minNumTouchesRequired must be not greater then maxNumTouchesRequired");
			
			_minNumTouchesRequired = value;
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Public methods
		//
		// --------------------------------------------------------------------------
		
		override public function reflect():Class
		{
			return PanGesture;
		}
		
			
		override public function reset():void
		{
			_gestureBeginOffsetX = NaN;
			_gestureBeginOffsetY = NaN;
			
			super.reset();
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Protected methods
		//
		// --------------------------------------------------------------------------
		
		override protected function onTouchBegin(touch:Touch):void
		{
			if (touchesCount > maxNumTouchesRequired)
			{
				//TODO
				ignoreTouch(touch);
				return;
			}
			
			if (touchesCount >= minNumTouchesRequired)
			{
				updateLocation();
			}			
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (touchesCount < minNumTouchesRequired)
				return;
			
			var prevLocationX:Number;
			var prevLocationY:Number;
			var offsetX:Number;
			var offsetY:Number;
			
			if (state == GestureState.POSSIBLE)
			{
				prevLocationX = _location.x;
				prevLocationY = _location.y;
				updateLocation();
				
				// Check if finger moved enough for gesture to be recognized
				var locationOffset:Point = touch.locationOffset;
				if (direction == PanGestureDirection.VERTICAL)
				{
					locationOffset.x = 0;
				}
				else if (direction == PanGestureDirection.HORIZONTAL)
				{
					locationOffset.y = 0;
				}
				
				if (locationOffset.length > slop || slop != slop)//faster isNaN(slop)
				{
					offsetX = _location.x - prevLocationX;
					offsetY = _location.y - prevLocationY;
					// acummulate begin offsets for the case when this gesture recognition is delayed by requireGestureToFail
					_gestureBeginOffsetX = (_gestureBeginOffsetX != _gestureBeginOffsetX) ? offsetX : _gestureBeginOffsetX + offsetX;
					_gestureBeginOffsetY = (_gestureBeginOffsetY != _gestureBeginOffsetY) ? offsetY : _gestureBeginOffsetY + offsetY;
					
					if (setState(GestureState.BEGAN) && hasEventListener(PanGestureEvent.GESTURE_PAN))
					{
						dispatchEvent(new PanGestureEvent(PanGestureEvent.GESTURE_PAN, false, false, GestureState.BEGAN,
							_location.x, _location.y, _localLocation.x, _localLocation.y, offsetX, offsetY));
					}
				}
			}
			else if (state == GestureState.BEGAN || state == GestureState.CHANGED)
			{
				prevLocationX = _location.x;
				prevLocationY = _location.y;
				updateLocation();
				offsetX = _location.x - prevLocationX;
				offsetY = _location.y - prevLocationY;
				
				if (setState(GestureState.CHANGED) && hasEventListener(PanGestureEvent.GESTURE_PAN))
				{
					dispatchEvent(new PanGestureEvent(PanGestureEvent.GESTURE_PAN, false, false, GestureState.CHANGED,
						_location.x, _location.y, _localLocation.x, _localLocation.y, offsetX, offsetY));
				}
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			if (touchesCount < minNumTouchesRequired)
			{
				if (state == GestureState.POSSIBLE)
				{
					setState(GestureState.FAILED);
				}
				else
				{
					if (setState(GestureState.ENDED) && hasEventListener(PanGestureEvent.GESTURE_PAN))
					{
						dispatchEvent(new PanGestureEvent(PanGestureEvent.GESTURE_PAN, false, false, GestureState.ENDED,
							_location.x, _location.y, _localLocation.x, _localLocation.y, 0, 0));
					}
				}
			}
			else
			{
				updateLocation();
			}
		}
		
		
		override protected function onDelayedRecognize():void
		{
			if (hasEventListener(PanGestureEvent.GESTURE_PAN))
			{
				dispatchEvent(new PanGestureEvent(PanGestureEvent.GESTURE_PAN, false, false, GestureState.BEGAN,
					_location.x, _location.y, _localLocation.x, _localLocation.y, _gestureBeginOffsetX, _gestureBeginOffsetY));
			}
		}
	}
}
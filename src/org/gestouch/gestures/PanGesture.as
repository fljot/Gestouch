package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;

	import flash.geom.Point;


	/**
	 * TODO:
	 * -location
	 * -check native behavior on iDevice
	 * 
	 * @author Pavel fljot
	 */
	public class PanGesture extends AbstractContinuousGesture
	{
		public var slop:Number = Gesture.DEFAULT_SLOP;
		/**
		 * Used for initial slop overcome calculations only.
		 */
		public var direction:uint = PanGestureDirection.NO_DIRECTION;
		
		
		public function PanGesture(target:Object = null)
		{
			super(target);
		}
		
		
		/** @private */
		private var _maxNumTouchesRequired:uint = uint.MAX_VALUE;
		
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
		
		
		protected var _offsetX:Number = 0;
		public function get offsetX():Number
		{
			return _offsetX;
		}
		
		
		protected var _offsetY:Number = 0;
		public function get offsetY():Number
		{
			return _offsetY;
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
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Protected methods
		//
		// --------------------------------------------------------------------------
		
		override protected function onTouchBegin(touch:Touch):void
		{
			if (touchesCount > maxNumTouchesRequired)
			{
				failOrIgnoreTouch(touch);
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
					// NB! += instead of = for the case when this gesture recognition is delayed via requireGestureToFail
					_offsetX += _location.x - prevLocationX;
					_offsetY += _location.y - prevLocationY;
					
					setState(GestureState.BEGAN);
				}
			}
			else if (state == GestureState.BEGAN || state == GestureState.CHANGED)
			{
				prevLocationX = _location.x;
				prevLocationY = _location.y;
				updateLocation();
				_offsetX = _location.x - prevLocationX;
				_offsetY = _location.y - prevLocationY;
				
				setState(GestureState.CHANGED);
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
					setState(GestureState.ENDED);
				}
			}
			else
			{
				updateLocation();
			}
		}
		
		
		override protected function resetNotificationProperties():void
		{
			super.resetNotificationProperties();
			
			_offsetX = _offsetY = 0;
		}
	}
}
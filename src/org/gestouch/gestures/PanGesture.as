package org.gestouch.gestures
{
	import org.gestouch.events.PanGestureEvent;
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.events.ZoomGestureEvent;

	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.events.TouchEvent;
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
		
		protected var _touchBeginX:Array = [];
		protected var _touchBeginY:Array = [];
		
		
		public function PanGesture(target:InteractiveObject = null)
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
			_touchBeginX.length = 0;
			_touchBeginY.length = 0;

			super.reset();
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Protected methods
		//
		// --------------------------------------------------------------------------
		
		override protected function onTouchBegin(touch:Touch, event:TouchEvent):void
		{
			if (touchesCount > maxNumTouchesRequired)
			{
				//TODO
				ignoreTouch(touch, event);
				return;
			}
			
			_touchBeginX[touch.id] = touch.x;
			_touchBeginY[touch.id] = touch.y;
			
			if (touchesCount >= minNumTouchesRequired)
			{
				updateLocation();
			}			
		}
		
		
		override protected function onTouchMove(touch:Touch, event:TouchEvent):void
		{
			if (touchesCount < minNumTouchesRequired)
				return;
			
			var prevLocationX:Number;
			var prevLocationY:Number;
			var offsetX:Number;
			var offsetY:Number;
			
			if (state == GestureState.POSSIBLE)
			{
				// Check if finger moved enough for gesture to be recognized
				var dx:Number = Number(_touchBeginX[touch.id]) - touch.x;
				var dy:Number = Number(_touchBeginY[touch.id]) - touch.y;
				if (Math.sqrt(dx*dx + dy*dy) > slop || slop != slop)//faster isNaN(slop)
				{
					prevLocationX = _location.x;
					prevLocationY = _location.y;
					updateLocation();
					offsetX = _location.x - prevLocationX;
					offsetY = _location.y - prevLocationY;
					// Unfortunately we create several new point instances here,
					// but thats not a big deal since this code executed only once per recognition session
					var offset:Point = new Point(offsetX, offsetY);
					if (offset.length > slop)
					{
						var slopVector:Point = offset.clone();
						slopVector.normalize(slop);
						offset = offset.subtract(slopVector);
					}
					
					if (setState(GestureState.BEGAN) && hasEventListener(PanGestureEvent.GESTURE_PAN))
					{
						dispatchEvent(new PanGestureEvent(PanGestureEvent.GESTURE_PAN, false, false, GesturePhase.BEGIN, _localLocation.x, _localLocation.y, offset.x, offset.y));
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
					dispatchEvent(new PanGestureEvent(PanGestureEvent.GESTURE_PAN, false, false, GesturePhase.UPDATE, _localLocation.x, _localLocation.y, offsetX, offsetY));
				}
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch, event:TouchEvent):void
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
						dispatchEvent(new PanGestureEvent(PanGestureEvent.GESTURE_PAN, false, false, GesturePhase.END, _localLocation.x, _localLocation.y, 0, 0));
					}
				}
			}
			else
			{
				updateLocation();
			}
		}
	}
}
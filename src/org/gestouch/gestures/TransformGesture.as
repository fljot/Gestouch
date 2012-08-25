package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;

	import flash.geom.Point;


	/**
	 * @author Pavel fljot
	 */
	public class TransformGesture extends AbstractContinuousGesture
	{
		public var slop:Number = Gesture.DEFAULT_SLOP;
		
		protected var _touch1:Touch;
		protected var _touch2:Touch;
		protected var _transformVector:Point;
		
		
		public function TransformGesture(target:Object = null)
		{
			super(target);
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
		
		
		protected var _rotation:Number = 0;
		public function get rotation():Number
		{
			return _rotation;
		}
		
		
		protected var _scale:Number = 1;
		public function get scale():Number
		{
			return _scale;
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Public methods
		//
		// --------------------------------------------------------------------------
		
		override public function reflect():Class
		{
			return TransformGesture;
		}
		
		
		override public function reset():void
		{
			_touch1 = null;
			_touch2 = null;
			
			super.reset();
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Protected methods
		//
		// --------------------------------------------------------------------------
		
		override protected function onTouchBegin(touch:Touch):void
		{
			if (touchesCount > 2)
			{
				failOrIgnoreTouch(touch);
				return;
			}
			
			if (touchesCount == 1)
			{
				_touch1 = touch;
			}
			else
			{
				_touch2 = touch;
				
				_transformVector = _touch2.location.subtract(_touch1.location);
			}
			
			updateLocation();
			
			if (state == GestureState.BEGAN || state == GestureState.CHANGED)
			{
				// notify that location (and amount of touches) has changed
				setState(GestureState.CHANGED);
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			var prevLocation:Point = _location.clone();
			updateLocation();
			
			var currTransformVector:Point;
			
			if (state == GestureState.POSSIBLE)
			{
				if (slop > 0 && touch.locationOffset.length < slop)
				{
					// Not recognized yet
					if (_touch2)
					{
						// Recalculate _transformVector to avoid initial "jump" on recognize
						_transformVector = _touch2.location.subtract(_touch1.location);
					}
					return;
				}
			}
			
			if (_touch2 && !currTransformVector)
			{
				currTransformVector = _touch2.location.subtract(_touch1.location);
			}
			
			_offsetX = _location.x - prevLocation.x;
			_offsetY = _location.y - prevLocation.y;
			if (_touch2)
			{
				_rotation = Math.atan2(currTransformVector.y, currTransformVector.x) - Math.atan2(_transformVector.y, _transformVector.x);
				_scale = currTransformVector.length / _transformVector.length;
				_transformVector = _touch2.location.subtract(_touch1.location);
			}
			
			setState(state == GestureState.POSSIBLE ? GestureState.BEGAN : GestureState.CHANGED);
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			if (touchesCount == 0)
			{
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					setState(GestureState.ENDED);
				}
				else if (state == GestureState.POSSIBLE)
				{
					setState(GestureState.FAILED);
				}
			}
			else// == 1
			{
				if (touch == _touch1)
				{
					_touch1 = _touch2;
				}
				_touch2 = null;
				
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					updateLocation();
					setState(GestureState.CHANGED);
				}
			}
		}
		
		
		override protected function resetNotificationProperties():void
		{
			super.resetNotificationProperties();
			
			_offsetX = _offsetY = 0;
			_rotation = 0;
			_scale = 1;
		}
	}
}
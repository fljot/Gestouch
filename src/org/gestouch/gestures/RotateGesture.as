package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;

	import flash.geom.Point;


	/**
	 * TODO:
	 * -check native behavior on iDevice
	 * 
	 * @author Pavel fljot
	 */
	public class RotateGesture extends AbstractContinuousGesture
	{
		public var slop:Number = Gesture.DEFAULT_SLOP;
		
		protected var _touch1:Touch;
		protected var _touch2:Touch;
		protected var _transformVector:Point;
		protected var _thresholdAngle:Number;
		
		
		public function RotateGesture(target:Object = null)
		{
			super(target);
		}
		
		
		protected var _rotation:Number = 0;
		public function get rotation():Number
		{
			return _rotation;
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Public methods
		//
		// --------------------------------------------------------------------------
		
		override public function reflect():Class
		{
			return RotateGesture;
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
				
				// @see chord length formula
				_thresholdAngle = Math.asin(slop / (2 * _transformVector.length)) * 2;
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (touchesCount < 2)
				return;
			
			var currTransformVector:Point = _touch2.location.subtract(_touch1.location);
			var rotation:Number = Math.atan2(currTransformVector.y, currTransformVector.x) - Math.atan2(_transformVector.y, _transformVector.x);
			
			if (state == GestureState.POSSIBLE)
			{
				const absRotation:Number = rotation >= 0 ? rotation : -rotation;
				if (absRotation < _thresholdAngle)
				{
					// not recognized yet
					return;
				}
				
				// adjust angle to avoid initial "jump"
				rotation = rotation > 0 ? rotation - _thresholdAngle : rotation + _thresholdAngle;
			}
			
			_transformVector.x = currTransformVector.x;
			_transformVector.y = currTransformVector.y;
			_rotation = rotation;
			
			updateLocation();
			
			if (state == GestureState.POSSIBLE)
			{
				setState(GestureState.BEGAN);
			}
			else
			{
				setState(GestureState.CHANGED);
			}
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
			
			_rotation = 0;
		}
	}
}
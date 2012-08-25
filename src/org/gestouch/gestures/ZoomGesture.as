package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;

	import flash.geom.Point;


	/**
	 * 
	 * @author Pavel fljot
	 */
	public class ZoomGesture extends AbstractContinuousGesture
	{
		public var slop:Number = Gesture.DEFAULT_SLOP;
		public var lockAspectRatio:Boolean = true;
		
		protected var _touch1:Touch;
		protected var _touch2:Touch;
		protected var _transformVector:Point;
		protected var _initialDistance:Number;
		
		
		public function ZoomGesture(target:Object = null)
		{
			super(target);
		}
		
		
		protected var _scaleX:Number = 1;
		public function get scaleX():Number
		{
			return _scaleX;
		}
		
		
		protected var _scaleY:Number = 1;
		public function get scaleY():Number
		{
			return _scaleY;
		}
		
		
		
		
		// --------------------------------------------------------------------------
		//
		// Public methods
		//
		// --------------------------------------------------------------------------
		
		override public function reflect():Class
		{
			return ZoomGesture;
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
			else// == 2
			{
				_touch2 = touch;
				
				_transformVector = _touch2.location.subtract(_touch1.location);
				_initialDistance = _transformVector.length;
			}
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if (touchesCount < 2)
				return;
			
			var currTransformVector:Point = _touch2.location.subtract(_touch1.location);
			
			if (state == GestureState.POSSIBLE)
			{
				const d:Number = currTransformVector.length - _initialDistance;
				const absD:Number = d >= 0 ? d : -d;
				if (absD < slop)
				{
					// Not recognized yet
					return;
				}
				
				if (slop > 0)
				{
					// adjust _transformVector to avoid initial "jump"
					const slopVector:Point = currTransformVector.clone();
					slopVector.normalize(_initialDistance + (d >= 0 ? slop : -slop));
					_transformVector = slopVector;
				}
			}
			
			
			if (lockAspectRatio)
			{
				_scaleX *= currTransformVector.length / _transformVector.length;
				_scaleY = _scaleX;
			}
			else
			{
				_scaleX *= currTransformVector.x / _transformVector.x;
				_scaleY *= currTransformVector.y / _transformVector.y;
			}
			
			_transformVector.x = currTransformVector.x;
			_transformVector.y = currTransformVector.y;
			
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
			else//== 1
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
			
			_scaleX = _scaleY = 1;
		}
	}
}
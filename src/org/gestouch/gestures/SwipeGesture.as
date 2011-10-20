package org.gestouch.gestures
{
	import org.gestouch.Direction;
	import org.gestouch.GestureUtils;
	import org.gestouch.core.GesturesManager;
	import org.gestouch.core.TouchPoint;
	import org.gestouch.core.gestouch_internal;
	import org.gestouch.events.SwipeGestureEvent;

	import flash.display.InteractiveObject;
	import flash.events.GesturePhase;
	import flash.geom.Point;
	import flash.utils.getTimer;


	[Event(name="gestureSwipe", type="org.gestouch.events.SwipeGestureEvent")]
	/**
	 * SwipeGesture detects <i>swipe</i> motion (also known as <i>flick</i> or <i>flig</i>).
	 * 
	 * <p>I couldn't find any certain definition of <i>Swipe</i> except for it's defined as <i>quick</i>.
	 * So I've implemented detection via two threshold velocities — one is in the direction of the movement,
	 * and second is the "side"-one (orthogonal). They form a velocity rectangle, where you have to move
	 * with a velocity greater then velocityThreshold value and less then sideVelocityThreshold.</p>
	 * 
	 * @author Pavel fljot
	 */
	public class SwipeGesture extends MovingGestureBase
	{
		public var moveThreshold:Number = Gesture.DEFAULT_SLOP;
		public var minTimeThreshold:uint = 50;
		public var velocityThreshold:Number = 7 * GestureUtils.IPS_TO_PPMS;
		public var sideVelocityThreshold:Number = 2 * GestureUtils.IPS_TO_PPMS;
		
		protected var _startTime:uint;
		
		
		public function SwipeGesture(target:InteractiveObject = null, settings:Object = null)
		{
			super(target, settings);
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Static methods
		//
		//--------------------------------------------------------------------------
		
		public static function add(target:InteractiveObject, settings:Object = null):SwipeGesture
		{
			return new SwipeGesture(target, settings);
		}
		
		
		public static function remove(target:InteractiveObject):SwipeGesture
		{
			return GesturesManager.gestouch_internal::removeGestureByTarget(SwipeGesture, target) as SwipeGesture;
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------		
			
		override public function reflect():Class
		{
			return SwipeGesture;
		}
		
		
		override public function onTouchBegin(touchPoint:TouchPoint):void
		{
			// No need to track more points than we need
			if (_trackingPointsCount == maxTouchPointsCount)
			{
				return;
			}
			
			_trackPoint(touchPoint);
		}
		
		
		override public function onTouchMove(touchPoint:TouchPoint):void
		{
			// do calculations only when we track enought points
			if (_trackingPointsCount < minTouchPointsCount)
			{
				return;
			}
			
			_updateCentralPoint();
			 
			if (!_slopPassed)
			{
				_slopPassed = _checkSlop(_centralPoint.moveOffset);
			}
			
			if (_slopPassed)
			{
				var velocity:Point = _centralPoint.velocity;
				
				var foo:Number = _centralPoint.moveOffset.length;//FIXME!
				var swipeDetected:Boolean = false;
				
				if (getTimer() - _startTime > minTimeThreshold && foo > 10)
				{
					var lastMoveX:Number = 0;
					var lastMoveY:Number = 0;
					
					if (_canMoveHorizontally && _canMoveVertically)
					{
						lastMoveX = _centralPoint.lastMove.x;
						lastMoveY = _centralPoint.lastMove.y;
						
						if (direction == Direction.STRAIGHT_AXES)
						{
							// go to logic below: if (!swipeDetected && _canMove*)..
						}
						else if (direction == Direction.OCTO)
						{
							swipeDetected = velocity.length >= velocityThreshold;
							
							if (Math.abs(velocity.y) < sideVelocityThreshold)
							{
								// horizontal swipe
								lastMoveY = 0;
							}
							else if (Math.abs(velocity.x) < sideVelocityThreshold)
							{
								// vertical swipe
								lastMoveX = 0;
							}
						}
						else
						{
							// free direction swipe
							swipeDetected = velocity.length >= velocityThreshold;
						}
					}
					
					if (!swipeDetected && _canMoveHorizontally)
					{
						swipeDetected = Math.abs(velocity.x) >= velocityThreshold &&
							Math.abs(velocity.y) < sideVelocityThreshold;
						
						lastMoveX = _centralPoint.lastMove.x;
						lastMoveY = 0;
					}
					if (!swipeDetected && _canMoveVertically)
					{
						swipeDetected = Math.abs(velocity.y) >= velocityThreshold &&
							Math.abs(velocity.x) < sideVelocityThreshold;
						
						lastMoveX = 0;
						lastMoveY = _centralPoint.lastMove.y;
					}
					
					if (swipeDetected)
					{
						_reset();
//						trace("swipe detected:", lastMoveX, lastMoveY);
						_dispatch(new SwipeGestureEvent(SwipeGestureEvent.GESTURE_SWIPE, true, false, GesturePhase.ALL, target.mouseX, target.mouseY, 1, 1, 0, lastMoveX, lastMoveY));
					}
				}
			}
		}
		
		
		override public function onTouchEnd(touchPoint:TouchPoint):void
		{
			_forgetPoint(touchPoint);
		}
	}
}
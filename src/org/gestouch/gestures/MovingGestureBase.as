package org.gestouch.gestures
{
	import flash.display.InteractiveObject;
	import flash.geom.Point;
	import org.gestouch.Direction;



	/**
	 * Base class for those gestures where you have to move finger/mouse,
	 * i.e. DragGesture, SwipeGesture
	 * 
	 * @author Pavel fljot
	 */
	public class MovingGestureBase extends Gesture
	{
		/**
		 * Threshold for screen distance they must move to count as valid input 
		 * (not an accidental offset on touch). Once this distance is passed,
		 * gesture starts more intensive and specific processing in onTouchMove() method.
		 * 
		 * @default Gesture.DEFAULT_SLOP
		 * 
		 * @see org.gestouch.gestures.Gesture#DEFAULT_SLOP
		 */
		public var slop:Number = Gesture.DEFAULT_SLOP;
		
		protected var _slopPassed:Boolean = false;
		protected var _canMoveHorizontally:Boolean = true;
		protected var _canMoveVertically:Boolean = true;
		
		
		public function MovingGestureBase(target:InteractiveObject = null, settings:Object = null)
		{
			super(target, settings);
			
			if (reflect() == MovingGestureBase)
			{
				dispose();
				throw new Error("This is abstract class and cannot be instantiated.");
			}
		}
		
		
		/**
		 * @private
		 * Storage for direction property.
		 */
		protected var _direction:String = Direction.ALL;

		
		/**
		 * Allowed direction for this gesture. Used to determine slop overcome
		 * and could be used for specific calculations (as in SwipeGesture for example).
		 * 
		 * @default Direction.ALL
		 * 
		 * @see org.gestouch.Direction
		 * @see org.gestouch.gestures.SwipeGesture
		 */
		public function get direction():String
		{
			return _direction;
		}
		public function set direction(value:String):void
		{
			if (_direction == value) return;
			
			_validateDirection(value);
			
			_direction = value;
			
			_canMoveHorizontally = (_direction != Direction.VERTICAL);
			_canMoveVertically = (_direction != Direction.HORIZONTAL);
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		override protected function _preinit():void
		{
			super._preinit();
			
			_propertyNames.push("slop", "direction");
		}
		
			
		override protected function _reset():void
		{
			super._reset();
			
			_slopPassed = false;
		}
		
		
		/**
		 * Validates direction property (in setter) to help
		 * developer prevent accidental mistake (Strings suck).
		 * 
		 * @see org.gestouch.Direction
		 */
		protected function _validateDirection(value:String):void
		{
			if (value != Direction.HORIZONTAL &&
				value != Direction.VERTICAL &&
				value != Direction.STRAIGHT_AXES &&
				value != Direction.DIAGONAL_AXES &&
				value != Direction.OCTO &&
				value != Direction.ALL)
			{
				throw new ArgumentError("Invalid direction value \"" + value + "\".");
			}
		}
		
		
		/**
		 * Checks wether slop has been overcome.
		 * Typically used in onTouchMove() method.
		 * 
		 * @param moveDelta offset of touch point / central point
		 * starting from beginning of interaction cycle.
		 * 
		 * @see #onTouchMove()
		 */
		protected function _checkSlop(moveDelta:Point):Boolean
		{
			var slopPassed:Boolean = false;
			
			if (_canMoveHorizontally && _canMoveVertically)
			{
				slopPassed = moveDelta.length > slop;
			}
			else if (_canMoveHorizontally)
			{
				slopPassed = Math.abs(moveDelta.x) > slop;
			}
			else if (_canMoveVertically)
			{
				slopPassed = Math.abs(moveDelta.y) > slop;
			}		
			
			if (slopPassed)
			{
				var slopVector:Point;
				if (_canMoveHorizontally && _canMoveVertically)
				{
					slopVector = moveDelta.clone();
					slopVector.normalize(slop);
					slopVector.x = Math.round(slopVector.x);
					slopVector.y = Math.round(slopVector.y);
				}
				else if (_canMoveHorizontally)
				{
					slopVector = new Point(moveDelta.x >= slop ? slop : -slop, 0);		
				}
				else if (_canMoveVertically)
				{
					slopVector = new Point(0, moveDelta.y >= slop ? slop : -slop);
				}
//				_gestureAnchorPoint = _touchPoint.add(slopVector);
//				startGestureTrack();
			}
			
			return slopPassed;
		}
	}
}
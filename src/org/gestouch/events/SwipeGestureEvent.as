package org.gestouch.events
{
	import flash.events.Event;


	/**
	 * @author Pavel fljot
	 */
	public class SwipeGestureEvent extends TransformGestureEvent
	{
		public static const GESTURE_SWIPE:String = "gestureSwipe";
		
		
		public function SwipeGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
										  gestureState:uint = 0,
										  stageX:Number = 0, stageY:Number = 0,
										  localX:Number = 0, localY:Number = 0,
										  offsetX:Number = 0, offsetY:Number = 0)
		{
			super(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY, 1, 1, 0, offsetX, offsetY);
		}
		
		
		override public function clone():Event
		{
			return new SwipeGestureEvent(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY, offsetX, offsetY);
		}
		
		
		override public function toString():String
		{
			return super.toString().replace("TransformGestureEvent", "SwipeGestureEvent");
		}
	}
}
package org.gestouch.events
{
	import flash.events.Event;


	/**
	 * @author Pavel fljot
	 */
	public class RotateGestureEvent extends TransformGestureEvent
	{
		public static const GESTURE_ROTATE:String = "gestureRotate";
		
		
		public function RotateGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
										   gestureState:uint = 0,
										   stageX:Number = 0, stageY:Number = 0,
										   localX:Number = 0, localY:Number = 0,
										   rotation:Number = 0)
		{
			super(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY, 1, 1, rotation);
		}
		
		
		override public function clone():Event
		{
			return new RotateGestureEvent(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY, rotation);
		}
		
		
		override public function toString():String
		{
			return super.toString().replace("TransformGestureEvent", "RotateGestureEvent");
		}
	}
}
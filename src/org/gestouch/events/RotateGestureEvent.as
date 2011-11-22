package org.gestouch.events
{
	import flash.events.Event;
	import flash.events.TransformGestureEvent;


	/**
	 * @author Pavel fljot
	 */
	public class RotateGestureEvent extends TransformGestureEvent
	{
		public static const GESTURE_ROTATE:String = "gestureRotate";
		
		
		public function RotateGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, phase:String = null, localX:Number = 0, localY:Number = 0, rotation:Number = 0)
		{
			super(type, bubbles, cancelable, phase, localX, localY, 1, 1, rotation, localX, localY);
		}
		
		
		override public function clone():Event
		{
			return new RotateGestureEvent(type, bubbles, cancelable, phase, localX, localY, rotation);
		}
		
		
		override public function toString():String
		{
			return super.toString().replace("TransformGestureEvent", "RotateGestureEvent");
		}
	}
}
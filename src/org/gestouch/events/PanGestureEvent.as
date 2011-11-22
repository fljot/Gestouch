package org.gestouch.events
{
	import flash.events.Event;
	import flash.events.TransformGestureEvent;


	/**
	 * @author Pavel fljot
	 */
	public class PanGestureEvent extends TransformGestureEvent
	{
		public static const GESTURE_PAN:String = "gesturePan";
		
		
		public function PanGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, phase:String = null, localX:Number = 0, localY:Number = 0, offsetX:Number = 0, offsetY:Number = 0)
		{
			super(type, bubbles, cancelable, phase, localX, localY, 1, 1, 0, offsetX, offsetY);
		}
		
		
		override public function clone():Event
		{
			return new PanGestureEvent(type, bubbles, cancelable, phase, localX, localY, offsetX, offsetY);
		}
		
		
		override public function toString():String
		{
			return super.toString().replace("TransformGestureEvent", "PanGestureEvent");
		}
	}
}
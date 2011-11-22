package org.gestouch.events
{
	import flash.events.Event;
	import flash.events.GestureEvent;


	/**
	 * @author Pavel fljot
	 */
	public class LongPressGestureEvent extends GestureEvent
	{
		public static const GESTURE_LONG_PRESS:String = "gestureLongPress";
		
		
		public function LongPressGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, phase:String = null, localX:Number = 0, localY:Number = 0)
		{
			super(type, bubbles, cancelable, phase, localX, localY);
		}
		
		
		override public function clone():Event
		{
			return new LongPressGestureEvent(type, bubbles, cancelable, phase, localX, localY);
		}
		
		
		override public function toString():String
		{
			return super.toString().replace("GestureEvent", "LongPressGestureEvent");
		}
	}
}
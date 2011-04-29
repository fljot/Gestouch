package org.gestouch.events
{
	import flash.events.GestureEvent;


	/**
	 * @author Pavel fljot
	 */
	public class LongPressGestureEvent extends GestureEvent
	{
		public static const GESTURE_LONG_PRESS:String = "gestureLongPress";
		
		//TODO: default 
		public function LongPressGestureEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, phase:String = "begin", localX:Number = 0, localY:Number = 0, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false)
		{
			super(type, bubbles, cancelable, phase, localX, localY, ctrlKey, altKey, shiftKey);
		}
	}
}
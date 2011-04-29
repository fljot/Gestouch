package org.gestouch.events
{
	import flash.events.GestureEvent;


	/**
	 * @author Pavel fljot
	 */
	public class DoubleTapGestureEvent extends GestureEvent
	{
		public static const GESTURE_DOUBLE_TAP:String = "gestureDoubleTap";
		
		
		public function DoubleTapGestureEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, phase:String = null, localX:Number = 0, localY:Number = 0, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false)
		{
			super(type, bubbles, cancelable, phase, localX, localY, ctrlKey, altKey, shiftKey);
		}
	}
}
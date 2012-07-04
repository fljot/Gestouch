package org.gestouch.events
{
	import org.gestouch.core.GestureState;

	import flash.events.Event;


	/**
	 * @author Pavel fljot
	 */
	public class LongPressGestureEvent extends GestureEvent
	{
		public static const GESTURE_LONG_PRESS:String = "gestureLongPress";
		
		
		public function LongPressGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
											  gestureState:GestureState = null,
											  stageX:Number = 0, stageY:Number = 0,
											  localX:Number = 0, localY:Number = 0)
		{
			super(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY);
		}
		
		
		override public function clone():Event
		{
			return new LongPressGestureEvent(type, bubbles, cancelable, gestureState, localX, localY);
		}
		
		
		override public function toString():String
		{
			return super.toString().replace("GestureEvent", "LongPressGestureEvent");
		}
	}
}
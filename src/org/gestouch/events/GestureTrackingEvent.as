package org.gestouch.events
{
	import flash.events.Event;


	/**
	 * @author Pavel fljot
	 */
	public class GestureTrackingEvent extends Event
	{
		public static const GESTURE_TRACKING_BEGIN:String = "gestureTrackingBegin";
		public static const GESTURE_TRACKING_END:String = "gestureTrackingEnd";
		
		
		public function GestureTrackingEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
		
		
		override public function clone():Event
		{
			return new GestureTrackingEvent(type, bubbles, cancelable);
		}
		
		
		override public function toString():String
		{
			return formatToString("GestureTrackingEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}
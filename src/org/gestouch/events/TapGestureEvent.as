package org.gestouch.events
{
	import flash.events.Event;


	/**
	 * @author Pavel fljot
	 */
	public class TapGestureEvent extends GestureEvent
	{
		public static const GESTURE_TAP:String = "gestureTap";
		
		
		public function TapGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
										gestureState:uint = 0, stageX:Number = 0, stageY:Number = 0,
										localX:Number = 0, localY:Number = 0)
		{
			super(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY);
		}
		
		
		override public function clone():Event
		{
			return new TapGestureEvent(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY);
		}
		
		
		override public function toString():String
		{
			return super.toString().replace("GestureEvent", "TapGestureEvent");
		}
	}
}
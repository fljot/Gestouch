package org.gestouch.events
{
	import flash.events.Event;
	import flash.events.TransformGestureEvent;


	/**
	 * @author Pavel fljot
	 */
	public class ZoomGestureEvent extends TransformGestureEvent
	{
		public static const GESTURE_ZOOM:String = "gestureZoom";
		
		
		public function ZoomGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, phase:String = null, localX:Number = 0, localY:Number = 0, scaleX:Number = 1, scaleY:Number = 1)
		{
			super(type, bubbles, cancelable, phase, localX, localY, scaleX, scaleY);
		}
		
		
		override public function clone():Event
		{
			return new ZoomGestureEvent(type, bubbles, cancelable, phase, localX, localY, scaleX, scaleY);
		}
		
		
		override public function toString():String
		{
			return super.toString().replace("TransformGestureEvent", "ZoomGestureEvent");
		}
	}
}
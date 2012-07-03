package org.gestouch.events
{
	import org.gestouch.core.GestureState;

	import flash.events.Event;


	/**
	 * @author Pavel fljot
	 */
	public class ZoomGestureEvent extends TransformGestureEvent
	{
		public static const GESTURE_ZOOM:String = "gestureZoom";
		
		
		public function ZoomGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
										 gestureState:GestureState = null,
										 stageX:Number = 0, stageY:Number = 0,
										 localX:Number = 0, localY:Number = 0,
										 scaleX:Number = 1.0, scaleY:Number = 1.0)
		{
			super(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY, scaleX, scaleY);
		}
		
		
		override public function clone():Event
		{
			return new ZoomGestureEvent(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY, scaleX, scaleY);
		}
		
		
		override public function toString():String
		{
			return super.toString().replace("TransformGestureEvent", "ZoomGestureEvent");
		}
	}
}
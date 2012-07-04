package org.gestouch.events
{
	import org.gestouch.core.GestureState;

	import flash.events.Event;


	/**
	 * @author Pavel fljot
	 */
	public class PanGestureEvent extends TransformGestureEvent
	{
		public static const GESTURE_PAN:String = "gesturePan";
		
		
		public function PanGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
										gestureState:GestureState = null,
										stageX:Number = 0, stageY:Number = 0,
										localX:Number = 0, localY:Number = 0,
										offsetX:Number = 0, offsetY:Number = 0)
		{
			super(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY, 1, 1, 0, offsetX, offsetY);
		}
		
		
		override public function clone():Event
		{
			return new PanGestureEvent(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY, offsetX, offsetY);
		}
		
		
		override public function toString():String
		{
			return super.toString().replace("TransformGestureEvent", "PanGestureEvent");
		}
	}
}
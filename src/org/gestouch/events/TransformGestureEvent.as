package org.gestouch.events
{
	import flash.events.Event;


	/**
	 * @author Pavel fljot
	 */
	public class TransformGestureEvent extends GestureEvent
	{
		public static const GESTURE_TRANSFORM:String = "gestureTransform";
		
		public var scaleX:Number;
		public var scaleY:Number;
		public var rotation:Number;
		public var offsetX:Number;
		public var offsetY:Number;
		
		
		public function TransformGestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
									 gestureState:uint = 0,
									 stageX:Number = 0, stageY:Number = 0,
									 localX:Number = 0, localY:Number = 0,
									 scaleX:Number = 1.0, scaleY:Number = 1.0,
									 rotation:Number = 0,
									 offsetX:Number = 0, offsetY:Number = 0)
		{
			super(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY);
			
			this.scaleX = scaleX;
			this.scaleY = scaleY;
			this.rotation = rotation;
			this.offsetX = offsetX;
			this.offsetY = offsetY;
		}
		
		
		override public function clone():Event
		{
			return new TransformGestureEvent(type, bubbles, cancelable, gestureState,
				stageX, stageY, localX, localY, scaleX, scaleY, rotation, offsetX, offsetY);
		}
		
		
		override public function toString():String
		{
			return formatToString("org.gestouch.events.TransformGestureEvent", "bubbles", "cancelable",
				"gestureState", "stageX", "stageY", "localX", "localY", "scaleX", "scaleY", "offsetX", "offsetY", "rotation");
		}
	}
}
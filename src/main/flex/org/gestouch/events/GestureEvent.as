package org.gestouch.events
{
	import org.gestouch.core.GestureState;

	import flash.events.Event;


	/**
	 * @author Pavel fljot
	 */
	public class GestureEvent extends Event
	{
		public var gestureState:GestureState;
		public var stageX:Number;
		public var stageY:Number;
		public var localX:Number;
		public var localY:Number;
		
		
		public function GestureEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false,
									 gestureState:GestureState = null,
									 stageX:Number = 0, stageY:Number = 0,
									 localX:Number = 0, localY:Number = 0)
		{
			super(type, bubbles, cancelable);
			
			this.gestureState = gestureState;
			this.stageX = stageX;
			this.stageY = stageY;
			this.localX = localX;
			this.localY = localY;
		}
		
		
		override public function clone():Event
		{
			return new GestureEvent(type, bubbles, cancelable, gestureState, stageX, stageY, localX, localY);
		}
		
		
		override public function toString():String
		{
			return formatToString("org.gestouch.events.GestureEvent", "bubbles", "cancelable",
				"gestureState", "stageX", "stageY", "localX", "localY");
		}
	}
}
package org.gestouch.events
{
	import flash.events.Event;


	/**
	 * @author Pavel fljot
	 */
	public class GestureStateEvent extends Event
	{
		public static const STATE_CHANGE:String = "stateChange";
		
		public var newState:uint;
		public var oldState:uint;
		
		
		public function GestureStateEvent(type:String, newState:uint, oldState:uint)
		{
			super(type, false, false);
			
			this.newState = newState;
			this.oldState = oldState;
		}
		
		
		override public function clone():Event
		{
			return new GestureStateEvent(type, newState, oldState);
		}
		
		
		override public function toString():String
		{
			return formatToString("GestureStateEvent", newState, oldState);
		}
	}
}
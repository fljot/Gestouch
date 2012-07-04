package org.gestouch.events
{
	import org.gestouch.core.GestureState;

	import flash.events.Event;


	/**
	 * @author Pavel fljot
	 */
	public class GestureStateEvent extends Event
	{
		public static const STATE_CHANGE:String = "stateChange";
		
		public var newState:GestureState;
		public var oldState:GestureState;
		
		
		public function GestureStateEvent(type:String, newState:GestureState, oldState:GestureState)
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
			return formatToString("GestureStateEvent", "type", "oldState", "newState");
		}
	}
}
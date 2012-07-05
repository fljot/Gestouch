package org.gestouch.core
{
	import flash.errors.IllegalOperationError;


	/**
	 * @author Pavel fljot
	 */
	public class GestureState
	{
		public static const IDLE:GestureState = new GestureState(1 << 0, "IDLE");
		public static const POSSIBLE:GestureState = new GestureState(1 << 1, "POSSIBLE");
		public static const RECOGNIZED:GestureState = new GestureState(1 << 2, "RECOGNIZED");
		public static const BEGAN:GestureState = new GestureState(1 << 3, "BEGAN");
		public static const CHANGED:GestureState = new GestureState(1 << 4, "CHANGED");
		public static const ENDED:GestureState = new GestureState(1 << 5, "ENDED");
		public static const CANCELLED:GestureState = new GestureState(1 << 6, "CANCELLED");
		public static const FAILED:GestureState = new GestureState(1 << 7, "FAILED");
		
		private static const endStatesBitMask:uint =
			GestureState.CANCELLED.toUint() |
			GestureState.RECOGNIZED.toUint() |
			GestureState.ENDED.toUint() |
			GestureState.FAILED.toUint();
		
		private static var allStatesInitialized:Boolean;
		
		
		private var value:uint;
		private var name:String;
		private var validTransitionsBitMask:uint;
		
		{
			_initClass();
		}
		
		
		public function GestureState(value:uint, name:String)
		{
			if (allStatesInitialized)
			{
				throw new IllegalOperationError("You cannot create gesture states." +
				"Use predefined constats like GestureState.RECOGNIZED");
			}
			
			this.value = value;
			this.name = name;
		}
		
		
		private static function _initClass():void
		{
			IDLE.setValidNextStates(POSSIBLE);
			POSSIBLE.setValidNextStates(RECOGNIZED, BEGAN, FAILED);
			RECOGNIZED.setValidNextStates(IDLE);
			BEGAN.setValidNextStates(CHANGED, ENDED, CANCELLED);
			CHANGED.setValidNextStates(CHANGED, ENDED, CANCELLED);
			ENDED.setValidNextStates(IDLE);
			FAILED.setValidNextStates(IDLE);
			
			allStatesInitialized = true;
		}
		
		
		public function toString():String
		{
			return "GestureState." + name;
		}
		
		
		public function toUint():uint
		{
			return value;
		}
		
		
		private function setValidNextStates(...states):void
		{
			var mask:uint;
			for each (var state:GestureState in states)
			{
				mask = mask | state.value;
			}
			validTransitionsBitMask = mask;
		}
		
		
		gestouch_internal function canTransitionTo(state:GestureState):Boolean
		{
			return (validTransitionsBitMask & state.value) > 0;
		}
		
		
		gestouch_internal function get isEndState():Boolean
		{
			return (endStatesBitMask & value) > 0;
		}
	}
}

package org.gestouch.gestures.symbolic
{
	
	
	/**
	 * @author Aleksandr Kozlovskij (created: Sep 25, 2012)
	 */
	public class Symbol
	{
		public var data:*; 
		public var matcher:Function;
		public const moves:Vector.<int> = new Vector.<int>(); 
		
		public var numTouchesRequired:uint = 1;
		
		private var _personalMaxFiability:uint = 0;
		private var _usePersonalMaxFiability:Boolean;
		
		private var _gestureSource:String;
		
		//------------ constructor ------------//
		
		public function Symbol(data:*, gesture:String, touchesRequired:uint = 1, matcher:Function = null)
		{
			this.data = data;
			this.matcher = matcher;
			_gestureSource = gesture;
			parseGestureStringToMoves(gesture);
			numTouchesRequired = touchesRequired;
		}
		
		//------------ initialize ------------//
		
		private function parseGestureStringToMoves(gesture:String):void
		{
			var char:String;
			for(var i:uint = 0; i < gesture.length; i++)
			{
				char = gesture.charAt(i);
				moves.push(getCharValue(char));				
			}
			moves.fixed = true;
		}
		
		protected function getCharValue(char:String):int
		{
			return isNaN(Number(char)) ? -1 : parseInt(char, 16);
		}
		
		//--------------- ctrl ---------------//
		
		public function clone():Symbol
		{
			const result:Symbol = new Symbol(data, _gestureSource, numTouchesRequired, matcher);
				  result._personalMaxFiability = _personalMaxFiability;
				  result._usePersonalMaxFiability = _usePersonalMaxFiability;
			return result;
		}
		
		//------------ get / set -------------//
		
		public function get personalMaxFiability():uint
		{
			return _personalMaxFiability;
		}
		
		public function set personalMaxFiability(value:uint):void
		{
			_personalMaxFiability = value;
			_usePersonalMaxFiability = true;
		}
		
		public function get usePersonalMaxFiability():Boolean
		{
			return _usePersonalMaxFiability;
		}
		
		//------- handlers / callbacks -------//
		
	}
}
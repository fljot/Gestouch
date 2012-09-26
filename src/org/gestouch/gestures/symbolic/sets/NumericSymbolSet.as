package org.gestouch.gestures.symbolic.sets
{
	import org.gestouch.gestures.symbolic.Symbol;
	
	/**
	 * @author Aleksandr Kozlovskij (created: Sep 25, 2012)
	 */
	public class NumericSymbolSet extends SymbolSet
	{
		
		// -  -  -  -  -  -  -  -  -  -  -  -  constructor  -  -  -  -  -  -  -  -  -  -  -  - //
		
		public function NumericSymbolSet(touchesRequired:uint  =  1)
		{
			super(touchesRequired);
		}
		
		//------------ initialize ------------//
		
		override protected function initialize(touchesRequired:uint):void
		{
			addSymbol(new Symbol("0", "4321076542", touchesRequired));
			addSymbol(new Symbol("1", "2", touchesRequired));
			addSymbol(new Symbol("2", "701230", touchesRequired));
			addSymbol(new Symbol("3", "0123401234", touchesRequired));
			addSymbol(new Symbol("4", "302", touchesRequired));
			addSymbol(new Symbol("5", "4201234", touchesRequired, fiveMatch));
			addSymbol(new Symbol("6", "43210765", touchesRequired, sixMatch));
			addSymbol(new Symbol("7", "03", touchesRequired));
			addSymbol(new Symbol("8", "4321234567654", touchesRequired));
			addSymbol(new Symbol("9", "43210762", touchesRequired));
		}
		
		//--------------- cases ---------------//
		
		/**
		 * 5: Special case
		 */
		protected function fiveMatch(info:Object):uint
		{
			var pos:int = info.moves.join("").indexOf("111");
			return pos == -1 ? info.cost : 10000;
		}
		
		/**
		 * 6: Special case
		 */
		protected function sixMatch(info:Object):uint
		{
			var py:Number = (info.location.y - info.bounds.y) / (info.bounds.height);
			return py > .3 ? info.cost : 10000;
		}
	}
}
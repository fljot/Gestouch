package org.gestouch.gestures.symbolic.sets
{
	import org.gestouch.gestures.symbolic.Symbol;
	
	/**
	 * @author Aleksandr Kozlovskij (created: Sep 25, 2012)
	 */
	public class AlphabetSymbolSet extends SymbolSet
	{
		
		// -  -  -  -  -  -  -  -  -  -  -  -  constructor  -  -  -  -  -  -  -  -  -  -  -  - //
		
		public function AlphabetSymbolSet(touchesRequired:uint  =  1)
		{
			super(touchesRequired);
		}
		
		//------------ initialize ------------//
		
		override protected function initialize(touchesRequired:uint):void
		{
			addSymbol(new Symbol("A", "71", touchesRequired));
			addSymbol(new Symbol("B", "260123401234", touchesRequired));
			addSymbol(new Symbol("C", "43210", touchesRequired));
			addSymbol(new Symbol("D", "26701234", touchesRequired, matchD));
			addSymbol(new Symbol("E", "4321043210", touchesRequired));
			addSymbol(new Symbol("F", "42", touchesRequired));
			addSymbol(new Symbol("G", "432107650", touchesRequired, matchG));
			addSymbol(new Symbol("H", "267012", touchesRequired));
			addSymbol(new Symbol("I", "2", touchesRequired));
			addSymbol(new Symbol("J", "234", touchesRequired));
			addSymbol(new Symbol("K", "3456701", touchesRequired));
			addSymbol(new Symbol("L", "20", touchesRequired));
			addSymbol(new Symbol("M", "6172", touchesRequired));
			addSymbol(new Symbol("N", "616", touchesRequired));
			addSymbol(new Symbol("O", "432107654", touchesRequired, oMatch));
			addSymbol(new Symbol("P", "26701234", touchesRequired, matchP));
			addSymbol(new Symbol("Q", "4321076540", touchesRequired, matchQ));
			addSymbol(new Symbol("R", "267012341", touchesRequired));
			addSymbol(new Symbol("S", "432101234", touchesRequired, matchS));
			addSymbol(new Symbol("T", "02", touchesRequired));
			addSymbol(new Symbol("U", "21076", touchesRequired));
			addSymbol(new Symbol("V", "17", touchesRequired));
			addSymbol(new Symbol("W", "2716", touchesRequired));
			addSymbol(new Symbol("X", "1076543", touchesRequired));
			addSymbol(new Symbol("Y", "21076234567", touchesRequired));
			addSymbol(new Symbol("Z", "030", touchesRequired));
		}
		
		//----------- Special cases -----------//
		
		protected function matchG(info:Object):uint
		{
			var py:Number = (info.location.y - info.bounds.y) / (info.bounds.height);
			return py > .3 ? info.cost : 10000;
		}
		
		protected function matchQ(info:Object):uint
		{
			var py:Number  =  (info.location.y  -  info.bounds.y) / (info.bounds.height);
			return py < .3 ? info.cost : 10000;
		}
		
		protected function matchD(info:Object):uint
		{
			var py:Number = (info.location.y - info.bounds.y) / (info.bounds.height);
			return py > .8 ? info.cost : 10000;
		}
		
		protected function matchP(info:Object):uint
		{
			var py:Number = (info.location.y - info.bounds.y) / (info.bounds.height);
			return py < .7 ? info.cost : 10000;
		}
		
		protected function oMatch(info:Object):uint
		{
			var py:Number = (info.location.y - info.bounds.y) / (info.bounds.height);
			return py < .3 ? info.cost : 10000;
		}
		
		protected function matchS(info:Object):uint
		{
			var pos:int = info.moves.join("").indexOf("111");
			return pos > -1 ? info.cost : 10000;
		}
	}
}
package org.gestouch.gestures.symbolic.sets
{
	import org.gestouch.gestures.symbolic.Symbol;
	
	/**
	 * Base class for any set of Symbols
	 * @author Aleksandr Kozlovskij (created: Sep 25, 2012)
	 */
	public class SymbolSet
	{
		protected const _symbols:Vector.<Symbol> = new Vector.<Symbol>();
		
		//------------ constructor ------------//
		
		public function SymbolSet(touchesRequired:uint = 1)
		{
			initialize(touchesRequired)
		}
		
		//------------ initialize ------------//
		
		protected function initialize(touchesRequired:uint):void
		{
			// template method
		}
		
		//--------------- ctrl ---------------//
		
		public function addSymbol(symbol:Symbol):void
		{
			_symbols.push(symbol);
		}
		
		//------------ get / set -------------//
		
		public function get symbols():Vector.<Symbol>
		{
			return _symbols;
		}
		
		//------- handlers / callbacks -------//
		
	}
}
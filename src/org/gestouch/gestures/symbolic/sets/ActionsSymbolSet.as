package org.gestouch.gestures.symbolic.sets
{
	import org.gestouch.gestures.symbolic.Symbol;
	
	/**
	 * @author Aleksandr Kozlovskij (created: Sep 25, 2012)
	 */
	public class ActionsSymbolSet extends SymbolSet
	{
		
		//------------ constructor ------------//
		
		public function ActionsSymbolSet(touchesRequired:uint  =  2)
		{
			super(touchesRequired);
		}
		
		//------------ initialize ------------//
		
		override protected function initialize(touchesRequired:uint):void
		{
			// upper "/-\" :
			addSymbol(new Symbol("UNDO", "543", touchesRequired));
			addSymbol(new Symbol("REDO", "701", touchesRequired));
			
			// lower "\-/" :
			//addSymbol(new Symbol("UNDO", "345", touchesRequired));
			//addSymbol(new Symbol("REDO", "107", touchesRequired));
		}
		
		//----------- Special cases -----------//
		
	}
}

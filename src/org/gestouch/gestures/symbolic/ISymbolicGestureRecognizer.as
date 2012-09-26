package org.gestouch.gestures.symbolic
{
	import flash.geom.Point;
	
	/**
	 * @author Aleksandr Kozlovskij (created: Sep 25, 2012)
	 */
	public interface ISymbolicGestureRecognizer
	{
		//------------ initialize ------------//
		
		function initialize():void;
		
		function resetTemporaryData():void;
		
		function dispose():void;
		
		//--------------- ctrl ---------------//
		
		function pushLocation(location:Point, diffX:int, diffY:int):void;
		
		function findBestMatchingSymbol(etalons:Vector.<Symbol>, currentTouchesCount:uint):SymbolicGestureRecognizerMatchingVO;
		
		//------------ get / set -------------//
		
		function get lastBestMatchingResult():SymbolicGestureRecognizerMatchingVO;
		
		//------- handlers / callbacks -------//
	}
}
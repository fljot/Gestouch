package org.gestouch.core
{
	/**
	 * @author Pavel fljot
	 */
	public interface ITouchesManager
	{
		function get activeTouchesCount():uint;
		
		function createTouch():Touch;
		function addTouch(touch:Touch):Touch;
		function removeTouch(touch:Touch):Touch;
		function getTouch(touchPointID:int):Touch;
		function hasTouch(touchPointID:int):Boolean;
	}
}
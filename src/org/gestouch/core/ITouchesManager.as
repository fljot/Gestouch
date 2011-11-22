package org.gestouch.core
{
	import flash.display.Stage;
	/**
	 * @author Pavel fljot
	 */
	public interface ITouchesManager
	{
		function get activeTouchesCount():uint;
		
		function init(stage:Stage):void;
		function getTouch(touchPointID:int):Touch;
	}
}
package org.gestouch.core
{
	/**
	 * @author Pavel fljot
	 */
	public interface ITouchesManager
	{
		function set gesturesManager(value:IGesturesManager):void;
		
		function get activeTouchesCount():uint;
		
		function onTouchBegin(inputAdapter:IInputAdapter, touchID:uint, x:Number, y:Number, target:Object):void;
		function onTouchMove(inputAdapter:IInputAdapter, touchID:uint, x:Number, y:Number):void;
		function onTouchEnd(inputAdapter:IInputAdapter, touchID:uint, x:Number, y:Number):void;

		function onInputAdapterDispose(inputAdapter:IInputAdapter):void;
	}
}
package org.gestouch.core
{
	/**
	 * The class that implements this interface must also
	 * implement next methods under gestouch_internal namespace:
	 * 
	 * function addGesture(gesture:Gesture):void;
	 * function removeGesture(gesture:Gesture):void;
	 * function scheduleGestureStateReset(gesture:Gesture):void;
	 * function onGestureRecognized(gesture:Gesture):void;
	 */
	public interface IGesturesManager
	{
		function addInputAdapter(inputAdapter:IInputAdapter):void;
		function removeInputAdapter(inputAdapter:IInputAdapter, dispose:Boolean = true):void;
		
		function addDisplayListAdapter(targetClass:Class, adapter:IDisplayListAdapter):void;
	}
}
package org.gestouch.core
{
	import org.gestouch.gestures.Gesture;
	/**
	 * @author Pavel fljot
	 */
	public interface IGesturesManager
	{
		function addInputAdapter(inputAdapter:IInputAdapter):void;
		function removeInputAdapter(inputAdapter:IInputAdapter):void;
		
		function addGesture(gesture:Gesture):void;
		
		function removeGesture(gesture:Gesture):void;
		
		function scheduleGestureStateReset(gesture:Gesture):void;
		
		function onGestureRecognized(gesture:Gesture):void;
	}
}
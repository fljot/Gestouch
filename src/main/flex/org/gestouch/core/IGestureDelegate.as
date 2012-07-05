package org.gestouch.core
{
	import org.gestouch.gestures.Gesture;
	/**
	 * @author Pavel fljot
	 */
	public interface IGestureDelegate
	{
		function gestureShouldReceiveTouch(gesture:Gesture, touch:Touch):Boolean;
		function gestureShouldBegin(gesture:Gesture):Boolean;
		function gesturesShouldRecognizeSimultaneously(gesture:Gesture, otherGesture:Gesture):Boolean;
	}
}
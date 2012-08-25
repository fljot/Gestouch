package org.gestouch.gestures
{
	import org.gestouch.gestures.Gesture;


	/**
	 * Dispatched when the state of the gesture changes to GestureState.RECOGNIZED.
	 * 
	 * @eventType org.gestouch.events.GestureEvent
	 * @see #state
	 */
	[Event(name="gestureRecognized", type="org.gestouch.events.GestureEvent")]
	/**
	 * @author Pavel fljot
	 */
	public class AbstractDiscreteGesture extends Gesture
	{
		public function AbstractDiscreteGesture(target:Object = null)
		{
			super(target);
		}
	}
}

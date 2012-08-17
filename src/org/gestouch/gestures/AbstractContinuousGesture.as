package org.gestouch.gestures
{
	import org.gestouch.gestures.Gesture;


	/**
	 * Dispatched when the state of the gesture changes to GestureState.BEGAN.
	 * 
	 * @eventType org.gestouch.events.GestureEvent
	 * @see #state
	 */
	[Event(name="gestureBegan", type="org.gestouch.events.GestureEvent")]
	/**
	 * Dispatched when the state of the gesture changes to GestureState.CHANGED.
	 * 
	 * @eventType org.gestouch.events.GestureEvent
	 * @see #state
	 */
	[Event(name="gestureChanged", type="org.gestouch.events.GestureEvent")]
	/**
	 * Dispatched when the state of the gesture changes to GestureState.ENDED.
	 * 
	 * @eventType org.gestouch.events.GestureEvent
	 * @see #state
	 */
	[Event(name="gestureEnded", type="org.gestouch.events.GestureEvent")]
	/**
	 * Dispatched when the state of the gesture changes to GestureState.CANCELLED.
	 * 
	 * @eventType org.gestouch.events.GestureEvent
	 * @see #state
	 */
	[Event(name="gestureCancelled", type="org.gestouch.events.GestureEvent")]
	/**
	 * @author Pavel fljot
	 */
	public class AbstractContinuousGesture extends Gesture
	{
		public function AbstractContinuousGesture(target:Object = null)
		{
			super(target);
		}
	}
}

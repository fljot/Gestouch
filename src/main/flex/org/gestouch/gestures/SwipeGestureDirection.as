package org.gestouch.gestures
{
	/**
	 * @author Pavel fljot
	 */
	public class SwipeGestureDirection
	{
		public static const RIGHT:uint = 1 << 0;
		public static const LEFT:uint = 1 << 1;
		public static const UP:uint = 1 << 2;
		public static const DOWN:uint = 1 << 3;
		
		public static const NO_DIRECTION:uint = 0;
		public static const HORIZONTAL:uint = RIGHT | LEFT;
		public static const VERTICAL:uint = UP | DOWN;
		public static const ORTHOGONAL:uint = RIGHT | LEFT | UP | DOWN;
	}
}
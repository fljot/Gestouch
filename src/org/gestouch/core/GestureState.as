package org.gestouch.core
{
	/**
	 * @author Pavel fljot
	 */
	public class GestureState
	{
		public static const POSSIBLE:uint = 1 << 0;//1
		public static const BEGAN:uint = 1 << 1;//2
		public static const CHANGED:uint = 1 << 2;//4
		public static const ENDED:uint = 1 << 3;//8
		public static const CANCELLED:uint = 1 << 4;//16
		public static const FAILED:uint = 1 << 5;//32
		public static const RECOGNIZED:uint = 1 << 6;//64
	}
}
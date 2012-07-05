package org.gestouch.utils
{
	import flash.geom.Point;
	import flash.system.Capabilities;
	/**
	 * Set of constants.
	 * 
	 * @author Pavel fljot
	 */
	public class GestureUtils
	{
		/**
		 * Precalculated coefficient used to convert 'inches per second' value to 'pixels per millisecond' value.
		 */
		public static const IPS_TO_PPMS:Number = Capabilities.screenDPI * 0.001;
		/**
		 * Precalculated coefficient used to convert radians to degress.
		 */
		public static const RADIANS_TO_DEGREES:Number = 180 / Math.PI;
		/**
		 * Precalculated coefficient used to convert degress to radians.
		 */
		public static const DEGREES_TO_RADIANS:Number = Math.PI / 180;
		/**
		 * Precalculated coefficient Math.PI * 2
		 */
		public static const PI_DOUBLE:Number = Math.PI * 2;
		public static const GLOBAL_ZERO:Point = new Point();
	}
}
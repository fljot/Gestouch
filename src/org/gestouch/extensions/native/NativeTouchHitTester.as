package org.gestouch.extensions.native
{
	import org.gestouch.core.ITouchHitTester;

	import flash.display.InteractiveObject;
	import flash.geom.Point;


	/**
	 * @author Pavel fljot
	 */
	final public class NativeTouchHitTester implements ITouchHitTester
	{
		public function hitTest(point:Point, nativeTarget:InteractiveObject):Object
		{
			return nativeTarget;
		}
	}
}

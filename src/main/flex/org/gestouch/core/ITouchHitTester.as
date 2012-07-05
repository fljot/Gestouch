package org.gestouch.core
{
	import flash.display.InteractiveObject;
	import flash.geom.Point;


	/**
	 * @author Pavel fljot
	 */
	public interface ITouchHitTester
	{
		function hitTest(point:Point, nativeTarget:InteractiveObject):Object;
	}
}

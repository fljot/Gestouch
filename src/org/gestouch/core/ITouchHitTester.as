package org.gestouch.core
{
	import flash.geom.Point;


	/**
	 * @author Pavel fljot
	 */
	public interface ITouchHitTester
	{
		function hitTest(point:Point, possibleTarget:Object = null):Object;
	}
}

package org.gestouch.core
{
	import flash.geom.Point;
	/**
	 * @author Pavel fljot
	 */
	public interface IGestureTargetAdapter
	{
		function get target():Object;
		
		function globalToLocal(point:Point):Point;
		
		function contains(object:Object):Boolean;
	}
}
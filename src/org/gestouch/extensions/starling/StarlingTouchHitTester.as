package org.gestouch.extensions.starling
{
	import starling.core.Starling;

	import org.gestouch.core.ITouchHitTester;

	import flash.display.InteractiveObject;
	import flash.geom.Point;


	/**
	 * @author Pavel fljot
	 */
	final public class StarlingTouchHitTester implements ITouchHitTester
	{
		private var starling:Starling;
		
		
		public function StarlingTouchHitTester(starling:Starling)
		{
			if (!starling)
			{
				throw ArgumentError("Missing starling argument.");
			}
			
			this.starling = starling;
		}
		
		
		public function hitTest(point:Point, nativeTarget:InteractiveObject):Object
		{
			point = StarlingUtils.adjustGlobalPoint(starling, point);			
			return starling.stage.hitTest(point, true);
		}
	}
}

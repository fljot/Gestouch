package org.gestouch.extensions.starling
{
	import flash.geom.Point;

	import org.gestouch.core.ITouchHitTester;

	import starling.core.Starling;
	import starling.display.DisplayObject;


	/**
	 * @author Pavel fljot
	 */
	public class StarlingTouchHitTester implements ITouchHitTester
	{
		public function hitTest(point:Point, possibleTarget:Object = null):Object
		{
			if (possibleTarget && possibleTarget is starling.display.DisplayObject)
			{
				return possibleTarget;
			}

			var currStarling:Starling = Starling.current;
			if (!currStarling)
			{
				return null;
			}

			point = StarlingUtils.adjustGlobalPoint(currStarling, point);
			return currStarling.stage.hitTest(point, true) || currStarling.nativeStage;
		}
	}
}

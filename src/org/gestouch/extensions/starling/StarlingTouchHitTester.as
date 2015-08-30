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
		private var _starling:Starling;


		public function StarlingTouchHitTester(starling:Starling)
		{
			if (!starling)
			{
				throw ArgumentError("Missing starling argument.");
			}

			_starling = starling;
		}


		public function hitTest(point:Point, possibleTarget:Object = null):Object
		{
			if (possibleTarget && possibleTarget is starling.display.DisplayObject)
			{
				return possibleTarget;
			}

			point = StarlingUtils.adjustGlobalPoint(_starling, point);
			return _starling.stage.hitTest(point, true) || _starling.nativeStage;
		}
	}
}

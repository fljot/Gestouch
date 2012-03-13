package org.gestouch.extensions.starling
{
	import org.gestouch.core.IGestureTargetAdapter;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.utils.Dictionary;



	/**
	 * @author Pavel fljot
	 */
	final public class StarlingDisplayObjectAdapter implements IGestureTargetAdapter
	{
		private var _targetWeekStorage:Dictionary = new Dictionary(true);
		
		
		public function StarlingDisplayObjectAdapter(target:DisplayObject)
		{
			_targetWeekStorage[target] = true;
		}
		
		
		public function get target():Object
		{
			for (var key:Object in _targetWeekStorage)
			{
				return key;
			}
			return null;
		}
		
		
		public function globalToLocal(point:Point):Point
		{
			return (target as DisplayObject).globalToLocal(point);
		}
		
		
		public function contains(target:Object):Boolean
		{
			const targetAsDOC:DisplayObjectContainer = this.target as DisplayObjectContainer;
			return (targetAsDOC && targetAsDOC.contains(target as DisplayObject));
		}
	}
}
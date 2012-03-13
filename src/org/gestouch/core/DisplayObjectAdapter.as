package org.gestouch.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.utils.Dictionary;



	/**
	 * @author Pavel fljot
	 */
	final public class DisplayObjectAdapter implements IGestureTargetAdapter
	{
		private var _targetWeekStorage:Dictionary = new Dictionary(true);
		
		
		public function DisplayObjectAdapter(target:DisplayObject)
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
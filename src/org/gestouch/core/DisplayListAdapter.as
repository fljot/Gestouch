package org.gestouch.core
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;
	import flash.utils.Dictionary;


	/**
	 * @author Pavel fljot
	 */
	final public class DisplayListAdapter implements IDisplayListAdapter
	{
		private var _targetWeekStorage:Dictionary;
		
		
		public function DisplayListAdapter(target:DisplayObject = null)
		{
			if (target)
			{
				_targetWeekStorage = new Dictionary(true);
				_targetWeekStorage[target] = true;
			}
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
		
		
		public function getHierarchy(genericTarget:Object):Vector.<Object>
		{
			var list:Vector.<Object> = new Vector.<Object>();
			var i:uint = 0;
			var target:DisplayObject = genericTarget as DisplayObject;
			while (target)
			{
				list[i] = target;				
				target = target.parent;
				i++;
			}
			
			return list;
		}
		
		
		public function reflect():Class
		{
			return DisplayListAdapter;
		}
	}
}
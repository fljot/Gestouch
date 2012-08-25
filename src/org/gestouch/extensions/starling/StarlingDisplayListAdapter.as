package org.gestouch.extensions.starling
{
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;

	import org.gestouch.core.IDisplayListAdapter;

	import flash.utils.Dictionary;


	/**
	 * @author Pavel fljot
	 */
	final public class StarlingDisplayListAdapter implements IDisplayListAdapter
	{
		private var targetWeekStorage:Dictionary;
		
		
		public function StarlingDisplayListAdapter(target:DisplayObject = null)
		{
			if (target)
			{
				targetWeekStorage = new Dictionary(true);
				targetWeekStorage[target] = true;
			}
		}
		
		
		public function get target():Object
		{
			for (var key:Object in targetWeekStorage)
			{
				return key;
			}
			return null;
		}
		
		
		public function contains(object:Object):Boolean
		{
			const targetAsDOC:DisplayObjectContainer = this.target as DisplayObjectContainer;
			const objectAsDO:DisplayObject = object as DisplayObject;
			return (targetAsDOC && objectAsDO && targetAsDOC.contains(objectAsDO));
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
			return StarlingDisplayListAdapter;
		}
	}
}
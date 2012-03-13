package org.gestouch.core
{
	import flash.display.DisplayObject;
	import org.gestouch.core.IDisplayListAdapter;


	/**
	 * @author Pavel fljot
	 */
	public class DisplayListAdapter implements IDisplayListAdapter
	{
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
	}
}
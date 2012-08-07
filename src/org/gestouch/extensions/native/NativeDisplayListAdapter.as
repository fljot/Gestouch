package org.gestouch.extensions.native
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import org.gestouch.core.IDisplayListAdapter;


	/**
	 * @author Pavel fljot
	 */
	final public class NativeDisplayListAdapter implements IDisplayListAdapter
	{
		private var _targetWeekStorage:Dictionary;
		
		
		public function NativeDisplayListAdapter(target:DisplayObject = null)
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
		
		
		public function contains(object:Object):Boolean
		{
			const targetAsDOC:DisplayObjectContainer = this.target as DisplayObjectContainer;
			if (targetAsDOC is Stage)
			{
				return true;
			}
			const objectAsDO:DisplayObject = object as DisplayObject;
			if (objectAsDO)
			{
				return (targetAsDOC && targetAsDOC.contains(objectAsDO));
			}
			/**
			 * There might be case when we use some old "software" 3D library for instace,
			 * which viewport is added to classic Display List. So native stage, root and some other
			 * sprites will actually be parents of 3D objects. To ensure all gestures (both for
			 * native and 3D objects) work correctly with each other contains() method should be
			 * a bit more sophisticated.
			 * But as all 3D engines (at least it looks like that) are moving towards Stage3D layer
			 * this task doesn't seem significant anymore. So I leave this implementation as
			 * comments in case someone will actually need it.
			 * Just uncomment this and it should work. 
			
			// else: more complex case.
			// object is not of the same type as this.target (flash.display::DisplayObject)
			// it might we some 3D library object in it's viewport (which itself is in DisplayList).
			// So we perform more general check:
			const adapter:IDisplayListAdapter = Gestouch.gestouch_internal::getDisplayListAdapter(object);
			if (adapter)
			{
				return adapter.getHierarchy(object).indexOf(this.target) > -1;
			}
			*/
			
			return false;
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
			return NativeDisplayListAdapter;
		}
	}
}
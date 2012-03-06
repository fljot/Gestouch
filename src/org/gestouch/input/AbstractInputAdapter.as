package org.gestouch.input
{
	import org.gestouch.core.IGesturesManager;
	import org.gestouch.core.IInputAdapter;
	import org.gestouch.core.ITouchesManager;


	/**
	 * @author Pavel fljot
	 */
	public class AbstractInputAdapter implements IInputAdapter
	{
		protected var _touchesManager:ITouchesManager;
		protected var _gesturesManager:IGesturesManager;
		
		
		public function AbstractInputAdapter()
		{
			if (Object(this).constructor == AbstractInputAdapter)
			{
				throw new Error("This is abstract class and should not be directly instantiated.");
			}
		}
		
		
		public function set touchesManager(value:ITouchesManager):void
		{
			_touchesManager = value;
		}
		
		
		public function set gesturesManager(value:IGesturesManager):void
		{
			_gesturesManager = value;
		}
		
		
		[Abstract]
		public function init():void
		{
			throw new Error("This is abstract method.");
		}
		
		
		[Abstract]
		public function dispose():void
		{
			throw new Error("This is abstract method.");
		}
	}
}
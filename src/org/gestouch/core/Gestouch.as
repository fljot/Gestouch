package org.gestouch.core
{
	import flash.display.DisplayObject;


	/**
	 * @author Pavel fljot
	 */
	public class Gestouch
	{		
		{
			initClass();
		}
		
		
		/** @private */
		private static var _inputAdapter:IInputAdapter;
		
		/**
		 * 
		 */
		public static function get inputAdapter():IInputAdapter
		{
			return _inputAdapter;
		}
		public static function set inputAdapter(value:IInputAdapter):void
		{
			if (_inputAdapter == value)
				return;
			
			_inputAdapter = value;
			if (inputAdapter)
			{
				inputAdapter.touchesManager = touchesManager;
				inputAdapter.init();
			}
		}
		
		
		private static var _touchesManager:TouchesManager;
		/**
		 * 
		 */
		public static function get touchesManager():TouchesManager
		{
			return _touchesManager ||= new TouchesManager(gesturesManager);
		}
		
		
		private static var _gesturesManager:GesturesManager;
		public static function get gesturesManager():GesturesManager
		{
			return _gesturesManager ||= new GesturesManager();
		}
		
		
		public static function addDisplayListAdapter(targetClass:Class, adapter:IDisplayListAdapter):void
		{
			gesturesManager.gestouch_internal::addDisplayListAdapter(targetClass, adapter);
		}
		
		
		public static function addTouchHitTester(hitTester:ITouchHitTester, priority:int = 0):void
		{
			touchesManager.gestouch_internal::addTouchHitTester(hitTester, priority);
		}
		
		
		public static function removeTouchHitTester(hitTester:ITouchHitTester):void
		{
			touchesManager.gestouch_internal::removeInputAdapter(hitTester);
		}
		
		
//		public static function getTouches(target:Object = null):Array
//		{
//			return touchesManager.getTouches(target);
//		}
		
		
		private static function initClass():void
		{
			addDisplayListAdapter(DisplayObject, new DisplayListAdapter());
		}
	}
}

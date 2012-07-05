package org.gestouch.core
{
	import flash.utils.getQualifiedClassName;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;


	/**
	 * @author Pavel fljot
	 */
	final public class Gestouch
	{
		private static const _displayListAdaptersMap:Dictionary = new Dictionary();
		
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
			if (!targetClass || !adapter)
			{
				throw new Error("Argument error: both arguments required.");
			}
			
			_displayListAdaptersMap[targetClass] = adapter;
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
		
		gestouch_internal static function createGestureTargetAdapter(target:Object):IDisplayListAdapter
		{
			const adapter:IDisplayListAdapter = Gestouch.gestouch_internal::getDisplayListAdapter(target);
			if (adapter)
			{
				return new (adapter.reflect())(target);
			}
			
			throw new Error("Cannot create adapter for target " + target + " of type " + getQualifiedClassName(target) + ".");
		}
		
		
		gestouch_internal static function getDisplayListAdapter(object:Object):IDisplayListAdapter
		{
			for (var key:Object in _displayListAdaptersMap)
			{
				var targetClass:Class = key as Class;
				if (object is targetClass)
				{
					return _displayListAdaptersMap[key] as IDisplayListAdapter;
				}
			}
			
			return null;
		}
		
		
		private static function initClass():void
		{
			addDisplayListAdapter(DisplayObject, new DisplayListAdapter());
		}
	}
}

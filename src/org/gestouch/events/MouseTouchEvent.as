package org.gestouch.events
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;


	/**
	 * @author Pavel fljot
	 */
	public class MouseTouchEvent extends TouchEvent
	{
		private static const typeMap:Object = {};
		
		protected var _mouseEvent:MouseEvent;
		
		{
			MouseTouchEvent.typeMap[MouseEvent.MOUSE_DOWN] = TouchEvent.TOUCH_BEGIN;
			MouseTouchEvent.typeMap[MouseEvent.MOUSE_MOVE] = TouchEvent.TOUCH_MOVE;
			MouseTouchEvent.typeMap[MouseEvent.MOUSE_UP] = TouchEvent.TOUCH_END;
		}
		
		
		public function MouseTouchEvent(type:String, event:MouseEvent)
		{
			super(type, event.bubbles, event.cancelable, 0, true, event.localX, event.localY, NaN, NaN, NaN, event.relatedObject, event.ctrlKey, event.altKey, event.shiftKey);
			
			_mouseEvent = event;
		}
		
		
		public static function createMouseTouchEvent(event:MouseEvent):MouseTouchEvent
		{
			var type:String = MouseTouchEvent.typeMap[event.type];
			if (!type)
			{
				throw new Error("No match found for MouseEvent of type \"" + event.type + "\"");
			}
			
			return new MouseTouchEvent(type, event);
		}
		
		
		override public function get target():Object
		{
			return _mouseEvent.target;
		}
		
		
		override public function get currentTarget():Object
		{
			return _mouseEvent.currentTarget;
		}
		
		
		override public function get stageX():Number
		{
			return _mouseEvent.stageX;
		}
		
		
		override public function get stageY():Number
		{
			return _mouseEvent.stageY;
		}
		
			
		override public function stopPropagation():void
		{
			super.stopPropagation();
			_mouseEvent.stopPropagation();
		}
		
			
		override public function stopImmediatePropagation():void
		{
			super.stopImmediatePropagation();
			_mouseEvent.stopImmediatePropagation();
		}
		
		
		override public function clone():Event
		{
			return super.clone();
		}
		
		
		override public function toString():String
		{
			return super.toString() + " *faked";
		}
	}
}
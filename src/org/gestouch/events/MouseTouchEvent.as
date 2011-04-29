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
		public function MouseTouchEvent(type:String, event:MouseEvent)
		{
			super(type, event.bubbles, event.cancelable, 0, true, event.localX, event.localY, NaN, NaN, NaN, event.relatedObject, event.ctrlKey, event.altKey, event.shiftKey);
			
			_target = event.target;
			_stageX = event.stageX;
			_stageY = event.stageY;
		}
		
		
		protected var _target:Object;
		override public function get target():Object
		{
			return _target;
		}
		
		
		protected var _stageX:Number;
		override public function get stageX():Number
		{
			return _stageX;
		}
		
		
		protected var _stageY:Number;
		override public function get stageY():Number
		{
			return _stageY;
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
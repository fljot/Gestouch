package org.gestouch.core
{
	import flash.events.IEventDispatcher;
	import flash.display.InteractiveObject;
	import flash.events.TouchEvent;

	/**
	 * @author Pavel fljot
	 */
	public interface IGesture extends IEventDispatcher
	{
		function get target():InteractiveObject;
		function get trackingPoints():Vector.<TouchPoint>;
		function get trackingPointsCount():uint;
		function get enabled():Boolean;
		function set enabled(value:Boolean):void;
		
		function shouldTrackPoint(event:TouchEvent, tp:TouchPoint):Boolean;
		function isTracking(touchPointID:uint):Boolean;
		
		function cancel():void;
		function pickAndContinue(gesture:IGesture):void;
		function reflect():Class;
		function dispose():void;
		
		function onTouchBegin(touchPoint:TouchPoint):void;
		function onTouchMove(touchPoint:TouchPoint):void;
		function onTouchEnd(touchPoint:TouchPoint):void;
		function onCancel():void;
	}
}
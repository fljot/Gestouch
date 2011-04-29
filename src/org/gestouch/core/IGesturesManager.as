package org.gestouch.core
{
	import flash.display.InteractiveObject;
	import flash.display.Stage;

	/**
	 * @author Pavel fljot
	 */
	public interface IGesturesManager
	{
		function init(stage:Stage):void;
		
		function addGesture(gesture:IGesture):IGesture;
		function removeGesture(gesture:IGesture):IGesture;
		function removeGestureByTarget(gestureType:Class, target:InteractiveObject):IGesture;
		function getGestureByTarget(gestureType:Class, target:InteractiveObject):IGesture;
		function cancelGesture(gesture:IGesture):void;
		function addCurrentGesture(gesture:IGesture):void;
		
		function updateGestureTarget(gesture:IGesture, oldTarget:InteractiveObject, newTarget:InteractiveObject):void;
		
		function getTouchPoint(touchPointID:int):TouchPoint;
	}
}
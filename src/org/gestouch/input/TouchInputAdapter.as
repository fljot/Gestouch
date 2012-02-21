package org.gestouch.input
{
	import org.gestouch.core.Touch;
	import org.gestouch.core.gestouch_internal;

	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.EventPhase;
	import flash.events.TouchEvent;
	import flash.utils.getTimer;


	/**
	 * @author Pavel fljot
	 */
	public class TouchInputAdapter extends AbstractInputAdapter
	{		
		protected var _stage:Stage;
		/**
		 * The hash map of touches instantiated via TouchEvent.
		 * Used to avoid collisions (double processing) with MouseInputAdapter.
		 * 
		 * TODO: any better way?
		 */
		protected var _touchesMap:Object = {};
		
		
		public function TouchInputAdapter(stage:Stage)
		{
			super();
			
			if (!stage)
			{
				throw new Error("Stage must be not null.");
			}
			
			_stage = stage;
			
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, true);
		}
		
		
		protected function installStageListeners():void
		{
			// Maximum priority to prevent event hijacking	
			_stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true, int.MAX_VALUE);
			_stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler, true, int.MAX_VALUE);
			// To catch event out of stage
			_stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler, false, int.MAX_VALUE);
		}
		
		
		protected function uninstallStageListeners():void
		{
			_stage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true);
			_stage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler, true);
			_stage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler);
		}
		
		
		protected function touchBeginHandler(event:TouchEvent):void
		{
			// Way to prevent MouseEvent/TouchEvent collisions.
			// Also helps to ignore possible fake events.
			if (_touchesManager.hasTouch(event.touchPointID))
				return;
			
			installStageListeners();
			
			var touch:Touch = _touchesManager.createTouch();
			touch.id = event.touchPointID;
			touch.target = event.target as InteractiveObject;
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.sizeX = event.sizeX;
			touch.sizeY = event.sizeY;
			touch.pressure = event.pressure;
			//TODO: conditional compilation?
			if (event.hasOwnProperty("timestamp"))
			{
				touch.time = event["timestamp"];
			}
			else
			{
				touch.time = getTimer();
			}
			
			_touchesManager.addTouch(touch);
			_touchesMap[touch.id] = true;
			
			_gesturesManager.gestouch_internal::onTouchBegin(touch);
		}
		
		
		protected function touchMoveHandler(event:TouchEvent):void
		{
			// Way to prevent MouseEvent/TouchEvent collisions.
			// Also helps to ignore possible fake events.
			if (!_touchesManager.hasTouch(event.touchPointID) || !_touchesMap.hasOwnProperty(event.touchPointID))
				return;
			
			var touch:Touch = _touchesManager.getTouch(event.touchPointID);
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.sizeX = event.sizeX;
			touch.sizeY = event.sizeY;
			touch.pressure = event.pressure;
			//TODO: conditional compilation?
			if (event.hasOwnProperty("timestamp"))
			{
				touch.time = event["timestamp"];
			}
			else
			{
				touch.time = getTimer();
			}
			
			_gesturesManager.gestouch_internal::onTouchMove(touch);
		}
		
		
		protected function touchEndHandler(event:TouchEvent):void
		{
			// If event happens outside of stage it will be with AT_TARGET phase
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;
			
			// Way to prevent MouseEvent/TouchEvent collisions.
			// Also helps to ignore possible fake events.
			if (!_touchesManager.hasTouch(event.touchPointID))
				return;
			
			var touch:Touch = _touchesManager.getTouch(event.touchPointID);
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.sizeX = event.sizeX;
			touch.sizeY = event.sizeY;
			touch.pressure = event.pressure;
			//TODO: conditional compilation?
			if (event.hasOwnProperty("timestamp"))
			{
				touch.time = event["timestamp"];
			}
			else
			{
				touch.time = getTimer();
			}
			
			_gesturesManager.gestouch_internal::onTouchEnd(touch);
			
			_touchesManager.removeTouch(touch);
			delete _touchesMap[touch.id];
			
			if (_touchesManager.activeTouchesCount == 0)
			{
				uninstallStageListeners();
			}
			
			// TODO: handle cancelled touch:
			// if (event.hasOwnProperty("isTouchPointCanceled") && event["isTouchPointCanceled"] && ...
		}
	}
}
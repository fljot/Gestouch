package org.gestouch.input
{
	import org.gestouch.core.Touch;
	import org.gestouch.core.gestouch_internal;

	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;


	/**
	 * @author Pavel fljot
	 */
	public class MouseInputAdapter extends AbstractInputAdapter
	{
		private static const PRIMARY_TOUCH_POINT_ID:uint = 0;
		
		protected var _stage:Stage;
		
		
		public function MouseInputAdapter(stage:Stage)
		{
			super();
			
			if (!stage)
			{
				throw new Error("Stage must be not null.");
			}
			
			_stage = stage;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
		}
		
		
		override public function init():void
		{
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
		}
		
			
		override public function dispose():void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
			uninstallStageListeners();
		}
		
		
		protected function installStageListeners():void
		{
			// Maximum priority to prevent event hijacking
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true, int.MAX_VALUE);
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true,  int.MAX_VALUE);
			// To catch event out of stage
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false,  int.MAX_VALUE);
		}
		
		
		protected function uninstallStageListeners():void
		{			
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		
		protected function mouseDownHandler(event:MouseEvent):void
		{
			// Way to prevent MouseEvent/TouchEvent collisions.
			// Also helps to ignore possible fake events.
			if (_touchesManager.hasTouch(PRIMARY_TOUCH_POINT_ID))
				return;
			
			installStageListeners();
			
			var touch:Touch = _touchesManager.createTouch();
			touch.id = 0;
			touch.target = event.target as InteractiveObject;
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.time = getTimer();
			
			_touchesManager.addTouch(touch);
			
			_gesturesManager.gestouch_internal::onTouchBegin(touch);
		}
		
		
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			// Way to prevent MouseEvent/TouchEvent collisions.
			// Also helps to ignore possible fake events.
			if (!_touchesManager.hasTouch(PRIMARY_TOUCH_POINT_ID))
				return;
			
			var touch:Touch = _touchesManager.getTouch(PRIMARY_TOUCH_POINT_ID);
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.time = getTimer();
			
			_gesturesManager.gestouch_internal::onTouchMove(touch);
		}
		
		
		protected function mouseUpHandler(event:MouseEvent):void
		{
			// If event happens outside of stage it will be with AT_TARGET phase
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;
			
			
			// Way to prevent MouseEvent/TouchEvent collisions.
			// Also helps to ignore possible fake events.
			if (!_touchesManager.hasTouch(PRIMARY_TOUCH_POINT_ID))
				return;
			
			var touch:Touch = _touchesManager.getTouch(PRIMARY_TOUCH_POINT_ID);
			touch.x = event.stageX;
			touch.y = event.stageY;
			touch.time = getTimer();
			
			_gesturesManager.gestouch_internal::onTouchEnd(touch);
			
			_touchesManager.removeTouch(touch);
			
			if (_touchesManager.activeTouchesCount == 0)
			{
				uninstallStageListeners();
			}
		}
	}
}
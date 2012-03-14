package org.gestouch.input
{
	import org.gestouch.core.Touch;
	import org.gestouch.core.gestouch_internal;

	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.geom.Point;
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
		}
		
		
		override public function init():void
		{
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
			_stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);// to catch with EventPhase.AT_TARGET
		}
		
			
		override public function dispose():void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			uninstallStageListeners();
		}
		
		
		protected function installStageListeners():void
		{
			// Maximum priority to prevent event hijacking
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true, int.MAX_VALUE);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, int.MAX_VALUE);
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true,  int.MAX_VALUE);
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false,  int.MAX_VALUE);
		}
		
		
		protected function uninstallStageListeners():void
		{			
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		}
		
		
		protected function mouseDownHandler(event:MouseEvent):void
		{
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;//we listen in capture or at_target (to catch on empty stage)
			// Way to prevent MouseEvent/TouchEvent collisions.
			// Also helps to ignore possible fake events.
			if (_touchesManager.hasTouch(PRIMARY_TOUCH_POINT_ID))
				return;
			
			installStageListeners();
			
			var touch:Touch = _touchesManager.createTouch();
			touch.target = event.target as InteractiveObject;
			touch.id = PRIMARY_TOUCH_POINT_ID;
			touch.gestouch_internal::setLocation(new Point(event.stageX, event.stageY));
			touch.gestouch_internal::setTime(getTimer());
			touch.gestouch_internal::setBeginTime(getTimer());
			
			_touchesManager.addTouch(touch);
			
			_gesturesManager.gestouch_internal::onTouchBegin(touch);
		}
		
		
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;//we listen in capture or at_target (to catch on empty stage)
			// Way to prevent MouseEvent/TouchEvent collisions.
			// Also helps to ignore possible fake events.
			if (!_touchesManager.hasTouch(PRIMARY_TOUCH_POINT_ID))
				return;
			
			var touch:Touch = _touchesManager.getTouch(PRIMARY_TOUCH_POINT_ID);
			touch.gestouch_internal::updateLocation(event.stageX, event.stageY);
			touch.gestouch_internal::setTime(getTimer());
			
			_gesturesManager.gestouch_internal::onTouchMove(touch);
		}
		
		
		protected function mouseUpHandler(event:MouseEvent):void
		{
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;//we listen in capture or at_target (to catch on empty stage)			
			
			// Way to prevent MouseEvent/TouchEvent collisions.
			// Also helps to ignore possible fake events.
			if (!_touchesManager.hasTouch(PRIMARY_TOUCH_POINT_ID))
				return;
			
			var touch:Touch = _touchesManager.getTouch(PRIMARY_TOUCH_POINT_ID);
			touch.gestouch_internal::updateLocation(event.stageX, event.stageY);
			touch.gestouch_internal::setTime(getTimer());
			
			_gesturesManager.gestouch_internal::onTouchEnd(touch);
			
			_touchesManager.removeTouch(touch);
			
			if (_touchesManager.activeTouchesCount == 0)
			{
				uninstallStageListeners();
			}
		}
	}
}
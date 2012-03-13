package org.gestouch.input
{
	import flash.display.Stage;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;


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
			_touchesManager.onInputAdapterDispose(this);
			_touchesManager = null;
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
			
			_touchesManager.onTouchBegin(this, PRIMARY_TOUCH_POINT_ID, event.stageX, event.stageY, event.target);
			
			if (_touchesManager.activeTouchesCount > 0)
			{
				installStageListeners();			
			}
		}
		
		
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;//we listen in capture or at_target (to catch on empty stage)
			
			_touchesManager.onTouchMove(this, PRIMARY_TOUCH_POINT_ID, event.stageX, event.stageY);
		}
		
		
		protected function mouseUpHandler(event:MouseEvent):void
		{
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;//we listen in capture or at_target (to catch on empty stage)			
			
			_touchesManager.onTouchEnd(this, PRIMARY_TOUCH_POINT_ID, event.stageX, event.stageY);
			
			if (_touchesManager.activeTouchesCount == 0)
			{
				uninstallStageListeners();
			}
		}
	}
}
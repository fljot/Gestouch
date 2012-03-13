package org.gestouch.input
{
	import flash.display.Stage;
	import flash.events.EventPhase;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;


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
		
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		}
		
		
		public function TouchInputAdapter(stage:Stage)
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
			_stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, true);
			_stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);// to catch with EventPhase.AT_TARGET
		}
		
			
		override public function dispose():void
		{
			_stage.removeEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, true);
			_stage.removeEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
			uninstallStageListeners();
			_touchesManager.onInputAdapterDispose(this);
			_touchesManager = null;
		}
		
		
		protected function installStageListeners():void
		{
			// Maximum priority to prevent event hijacking	
			_stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true, int.MAX_VALUE);
			_stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, false, int.MAX_VALUE);
			_stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler, true, int.MAX_VALUE);
			_stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler, false, int.MAX_VALUE);
		}
		
		
		protected function uninstallStageListeners():void
		{
			_stage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true);
			_stage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler);
			_stage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler, true);
			_stage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler);
		}
		
		
		protected function touchBeginHandler(event:TouchEvent):void
		{
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;//we listen in capture or at_target (to catch on empty stage)
				
			_touchesManager.onTouchBegin(this, event.touchPointID, event.stageX, event.stageY, event.target);
			
			if (_touchesManager.activeTouchesCount > 0)
			{
				installStageListeners();			
			}
		}
		
		
		protected function touchMoveHandler(event:TouchEvent):void
		{
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;//we listen in capture or at_target (to catch on empty stage)
			
			_touchesManager.onTouchMove(this, event.touchPointID, event.stageX, event.stageY);
		}
		
		
		protected function touchEndHandler(event:TouchEvent):void
		{
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;//we listen in capture or at_target (to catch on empty stage)
			
			_touchesManager.onTouchEnd(this, event.touchPointID, event.stageX, event.stageY);
			
			if (_touchesManager.activeTouchesCount == 0)
			{
				uninstallStageListeners();
			}
			
			// TODO: handle cancelled touch:
			// if (event.hasOwnProperty("isTouchPointCanceled") && event["isTouchPointCanceled"] && ...
		}
	}
}
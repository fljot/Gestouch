package org.gestouch.extensions.starling
{
	import starling.core.Starling;

	import org.gestouch.input.AbstractInputAdapter;

	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.ui.Multitouch;



	/**
	 * @author Pavel fljot
	 */
	public class StarlingInputAdapter extends AbstractInputAdapter
	{
		private static const PRIMARY_TOUCH_POINT_ID:uint = 0;
		
		protected var _starling:Starling;
		
		 
		public function StarlingInputAdapter(starling:Starling)
		{
			super();
			
			if (!starling)
			{
				throw new Error("Argument error.");
			}
			
			_starling = starling;
		}
		
		
		override public function init():void
		{
			// We want to begin tracking only those touches that happen on Stage3D layer,
			// e.g. event.target == nativeStage. That's we don't listen for touch begin
			// in capture phase (as we do for native display list).
			if (Multitouch.supportsTouchEvents)
			{
				_starling.nativeStage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
			}
			else
			{
				_starling.nativeStage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}
		}
		
			
		override public function dispose():void
		{
			_starling.nativeStage.removeEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler);
			_starling.nativeStage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			uninstallStageListeners();
			_starling = null;
			_touchesManager.onInputAdapterDispose(this);
			_touchesManager = null;
		}
		
		
		protected function installStageListeners():void
		{
			// Maximum priority to prevent event hijacking
			if (Multitouch.supportsTouchEvents)
			{
				_starling.nativeStage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true, int.MAX_VALUE);
				_starling.nativeStage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, false, int.MAX_VALUE);
				_starling.nativeStage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler, true, int.MAX_VALUE);
				_starling.nativeStage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler, false, int.MAX_VALUE);
			}
			else
			{
				_starling.nativeStage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true, int.MAX_VALUE);
				_starling.nativeStage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false, int.MAX_VALUE);
				_starling.nativeStage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true, int.MAX_VALUE);
				_starling.nativeStage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, int.MAX_VALUE);
			}
		}
		
		
		protected function uninstallStageListeners():void
		{
			_starling.nativeStage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true);
			_starling.nativeStage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, false);
			_starling.nativeStage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler, true);
			_starling.nativeStage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler, false);
			_starling.nativeStage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			_starling.nativeStage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
			_starling.nativeStage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
			_starling.nativeStage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false);
		}
		
		
		protected function mouseDownHandler(event:MouseEvent):void
		{
			// We ignore event with bubbling phase because it happened on some native InteractiveObject,
			// which basically hovers Stage3D layer. So we treat it as if Starling wouldn't recieve any input. 
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;
			
			var target:Object = _starling.stage.hitTest(new Point(event.stageX, event.stageY), true);
			_touchesManager.onTouchBegin(this, PRIMARY_TOUCH_POINT_ID, event.stageX, event.stageY, target);
			
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
		
		
		protected function touchBeginHandler(event:TouchEvent):void
		{
			// We ignore event with bubbling phase because it happened on some native InteractiveObject,
			// which basically hovers Stage3D layer. So we treat it as if Starling wouldn't recieve any input. 
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;
			
			var target:Object = _starling.stage.hitTest(new Point(event.stageX, event.stageY), true);
			_touchesManager.onTouchBegin(this, event.touchPointID, event.stageX, event.stageY, target);
			
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
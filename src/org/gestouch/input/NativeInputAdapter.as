package org.gestouch.input
{
	import org.gestouch.core.IInputAdapter;
	import org.gestouch.core.TouchesManager;
	import org.gestouch.core.gestouch_internal;

	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.EventPhase;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;

	CONFIG::GestouchDebug
	import org.gestouch.utils.log;


	/**
	 * @author Pavel fljot
	 */
	public class NativeInputAdapter implements IInputAdapter
	{
		protected static const MOUSE_TOUCH_POINT_ID:uint = 0;
		
		protected var _stage:Stage;
		protected var _explicitlyHandleTouchEvents:Boolean;
		protected var _explicitlyHandleMouseEvents:Boolean;
		protected var _touchesManager:TouchesManager;
		
		use namespace gestouch_internal;
		
		
		{
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		}
		
		
		public function NativeInputAdapter(stage:Stage,
										   explicitlyHandleTouchEvents:Boolean = false,
										   explicitlyHandleMouseEvents:Boolean = false)
		{
			super();
			
			if (!stage)
			{
				throw new ArgumentError("Stage must be not null.");
			}
			
			_stage = stage;
			
			_explicitlyHandleTouchEvents = explicitlyHandleTouchEvents;
			_explicitlyHandleMouseEvents = explicitlyHandleMouseEvents;
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		public function init(touchesManager:TouchesManager):void
		{
			CONFIG::GestouchDebug
			{
				log("Multitouch.supportsTouchEvents:", Multitouch.supportsTouchEvents);
				log("_explicitlyHandleTouchEvents:", _explicitlyHandleTouchEvents);
			}

			_touchesManager = touchesManager;

			if (Multitouch.supportsTouchEvents || _explicitlyHandleTouchEvents)
			{
				_stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, true);
				_stage.addEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, false);
				_stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true);
				_stage.addEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, false);
				// Maximum priority to prevent event hijacking and loosing the touch
				_stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler, true, int.MAX_VALUE);
				_stage.addEventListener(TouchEvent.TOUCH_END, touchEndHandler, false, int.MAX_VALUE);
			}
			
			if (!Multitouch.supportsTouchEvents || _explicitlyHandleMouseEvents)
			{
				_stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
				_stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false);
			}
		}


		public function teardown():void
		{
			_touchesManager = null;
			
			_stage.removeEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, true);
			_stage.removeEventListener(TouchEvent.TOUCH_BEGIN, touchBeginHandler, false);
			_stage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, true);
			_stage.removeEventListener(TouchEvent.TOUCH_MOVE, touchMoveHandler, false);
			_stage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler, true);
			_stage.removeEventListener(TouchEvent.TOUCH_END, touchEndHandler, false);
			
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, true);
			_stage.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false);
			unstallMouseListeners();
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		protected function installMouseListeners():void
		{
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			_stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
			// Maximum priority to prevent event hijacking
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true, int.MAX_VALUE);
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false, int.MAX_VALUE);
		}
		
		
		protected function unstallMouseListeners():void
		{
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, false);
			// Maximum priority to prevent event hijacking
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, false);
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		protected function touchBeginHandler(event:TouchEvent):void
		{
			// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
			// (to catch on empty stage) phases only
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;

			CONFIG::GestouchDebug
			{
				log("Touch begin via touch event:", event);
			}

			_touchesManager.onTouchBegin(event.touchPointID, event.stageX, event.stageY, event.target as InteractiveObject);
		}
		
		
		protected function touchMoveHandler(event:TouchEvent):void
		{
			// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
			// (to catch on empty stage) phases only
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;

			CONFIG::GestouchDebug
			{
				log("Touch move via touch event:", event);
			}

			_touchesManager.onTouchMove(event.touchPointID, event.stageX, event.stageY);
		}
		
		
		protected function touchEndHandler(event:TouchEvent):void
		{
			// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
			// (to catch on empty stage) phases only
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;

			CONFIG::GestouchDebug
			{
				log("Touch end/cancel via touch event:", event);
			}
			
			if (event.hasOwnProperty("isTouchPointCanceled") && event["isTouchPointCanceled"])
			{
				_touchesManager.onTouchCancel(event.touchPointID, event.stageX, event.stageY);
			}
			else
			{
				_touchesManager.onTouchEnd(event.touchPointID, event.stageX, event.stageY);
			}
		}
		
		
		protected function mouseDownHandler(event:MouseEvent):void
		{
			// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
			// (to catch on empty stage) phases only
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;

			CONFIG::GestouchDebug
			{
				log("Touch begin via mouse event:", event);
			}
			
			const touchAccepted:Boolean = _touchesManager.onTouchBegin(MOUSE_TOUCH_POINT_ID, event.stageX, event.stageY, event.target as InteractiveObject);
			
			if (touchAccepted)
			{
				installMouseListeners();			
			}
		}
		
		
		protected function mouseMoveHandler(event:MouseEvent):void
		{
			// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
			// (to catch on empty stage) phases only
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;

			CONFIG::GestouchDebug
			{
				log("Touch move via mouse event:", event);
			}

			_touchesManager.onTouchMove(MOUSE_TOUCH_POINT_ID, event.stageX, event.stageY);
		}
		
		
		protected function mouseUpHandler(event:MouseEvent):void
		{
			// We listen in EventPhase.CAPTURE_PHASE or EventPhase.AT_TARGET
			// (to catch on empty stage) phases only
			if (event.eventPhase == EventPhase.BUBBLING_PHASE)
				return;

			CONFIG::GestouchDebug
			{
				log("Touch end via mouse event:", event);
			}
			
			_touchesManager.onTouchEnd(MOUSE_TOUCH_POINT_ID, event.stageX, event.stageY);
			
			if (_touchesManager.activeTouchesCount == 0)
			{
				unstallMouseListeners();
			}
		}
	}
}

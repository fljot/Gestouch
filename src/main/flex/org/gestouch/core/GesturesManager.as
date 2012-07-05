package org.gestouch.core
{
	import flash.errors.IllegalOperationError;
	import org.gestouch.gestures.Gesture;
	import org.gestouch.input.NativeInputAdapter;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	/**
	 * @author Pavel fljot
	 */
	public class GesturesManager
	{
		protected const _frameTickerShape:Shape = new Shape();
		protected var _inputAdapters:Vector.<IInputAdapter> = new Vector.<IInputAdapter>();
		protected var _gesturesMap:Dictionary = new Dictionary(true);
		protected var _gesturesForTouchMap:Dictionary = new Dictionary();
		protected var _gesturesForTargetMap:Dictionary = new Dictionary(true);
		protected var _dirtyGesturesCount:uint = 0;
		protected var _dirtyGesturesMap:Dictionary = new Dictionary(true);
		protected var _stage:Stage;
		
		use namespace gestouch_internal;
		
		
		public function GesturesManager()
		{
			
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		
		protected function onStageAvailable(stage:Stage):void
		{
			_stage = stage;
			
			Gestouch.inputAdapter ||= new NativeInputAdapter(stage);
		}
		
		
		protected function resetDirtyGestures():void
		{
			for (var gesture:* in _dirtyGesturesMap)
			{
				(gesture as Gesture).reset();
			}
			_dirtyGesturesCount = 0;
			_dirtyGesturesMap = new Dictionary(true);
			_frameTickerShape.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		
		gestouch_internal function addGesture(gesture:Gesture):void
		{
			if (!gesture)
			{
				throw new ArgumentError("Argument 'gesture' must be not null.");
			}
			
			const target:Object = gesture.target;
			if (!target)
			{
				throw new IllegalOperationError("Gesture must have target.");
			}
			
			var targetGestures:Vector.<Gesture> = _gesturesForTargetMap[target] as Vector.<Gesture>;
			if (targetGestures)
			{
				if (targetGestures.indexOf(gesture) == -1)
				{
					targetGestures.push(gesture);
				}
			}
			else
			{
				targetGestures = _gesturesForTargetMap[target] = new Vector.<Gesture>();
				targetGestures[0] = gesture;
			}
			
			
			_gesturesMap[gesture] = true;
			
			if (!_stage)
			{
				var targetAsDO:DisplayObject = target as DisplayObject;
				if (targetAsDO)
				{
					if (targetAsDO.stage)
					{
						onStageAvailable(targetAsDO.stage);
					}
					else
					{
						targetAsDO.addEventListener(Event.ADDED_TO_STAGE, gestureTarget_addedToStageHandler);
					}
				}
			}
		}
		
		
		gestouch_internal function removeGesture(gesture:Gesture):void
		{
			if (!gesture)
			{
				throw new ArgumentError("Argument 'gesture' must be not null.");
			}
			
			
			var target:Object = gesture.target;
			// check for target because it could be already GC-ed (since target reference is weak)
			if (target)
			{
				var targetGestures:Vector.<Gesture> = _gesturesForTargetMap[target] as Vector.<Gesture>;
				if (targetGestures.length > 1)
				{
					targetGestures.splice(targetGestures.indexOf(gesture), 1);
				}
				else
				{
					delete _gesturesForTargetMap[target];
					if (target is IEventDispatcher)
					{
						(target as IEventDispatcher).removeEventListener(Event.ADDED_TO_STAGE, gestureTarget_addedToStageHandler);
					}
				}
			}
			
			delete _gesturesMap[gesture];
			
			gesture.reset();
		}
		
		
		gestouch_internal function scheduleGestureStateReset(gesture:Gesture):void
		{
			if (!_dirtyGesturesMap[gesture])
			{
				_dirtyGesturesMap[gesture] = true;
				_dirtyGesturesCount++;
				_frameTickerShape.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
			}
		}
		
		
		gestouch_internal function onGestureRecognized(gesture:Gesture):void
		{
			const target:Object = gesture.target;
			
			for (var key:Object in _gesturesMap)
			{
				var otherGesture:Gesture = key as Gesture;
				var otherTarget:Object = otherGesture.target;
				
				// conditions for otherGesture "own properties"
				if (otherGesture != gesture &&
					target && otherTarget &&//in case GC worked half way through
					otherGesture.enabled &&
					otherGesture.state == GestureState.POSSIBLE)
				{
					if (otherTarget == target ||
						gesture.targetAdapter.contains(otherTarget) ||
						otherGesture.targetAdapter.contains(target)
						)
					{
						var gestureDelegate:IGestureDelegate = gesture.delegate;
						var otherGestureDelegate:IGestureDelegate = otherGesture.delegate;
						// conditions for gestures relations
						if (gesture.canPreventGesture(otherGesture) &&
							otherGesture.canBePreventedByGesture(gesture) &&
							(!gestureDelegate || !gestureDelegate.gesturesShouldRecognizeSimultaneously(gesture, otherGesture)) &&
							(!otherGestureDelegate || !otherGestureDelegate.gesturesShouldRecognizeSimultaneously(otherGesture, gesture)))
						{
							otherGesture.setState_internal(GestureState.FAILED);
						}
					}
				}
			}
		}
		
		
		gestouch_internal function onTouchBegin(touch:Touch):void
		{
			if (_dirtyGesturesCount > 0)
			{
				resetDirtyGestures();
			}
			
			var gesture:Gesture;
			var i:uint;
			
			// This vector will contain active gestures for specific touch during all touch session.
			var gesturesForTouch:Vector.<Gesture> = _gesturesForTouchMap[touch] as Vector.<Gesture>;
			if (!gesturesForTouch)
			{
				gesturesForTouch = _gesturesForTouchMap[touch] = new Vector.<Gesture>();
			}
			else
			{
				gesturesForTouch.length = 0;
			}
			
			var target:Object = touch.target;
			const displayListAdapter:IDisplayListAdapter = Gestouch.gestouch_internal::getDisplayListAdapter(target);
			const hierarchy:Vector.<Object> = displayListAdapter.getHierarchy(target);
			if (!hierarchy)
			{
				throw new Error("Display list adapter not found for target of type '" + getQualifiedClassName(target) + "'.");
			}
			const hierarchyLength:uint = hierarchy.length;
			if (hierarchyLength == 0)
			{
				throw new Error("No hierarchy build for target '" + target +"'. Something is wrong with that IDisplayListAdapter.");
			}
			if (_stage && !(hierarchy[hierarchyLength - 1] is Stage))
			{
				// Looks like some non-native (non DisplayList) hierarchy
				// but we must always handle gestures with Stage target
				// since Stage is anyway the top-most parent
				hierarchy[hierarchyLength] = _stage;
			}
			
			// Create a sorted(!) list of gestures which are interested in this touch.
			// Sorting priority: deeper target has higher priority, recently added gesture has higher priority.
			var gesturesForTarget:Vector.<Gesture>;
			for each (target in hierarchy)
			{
				gesturesForTarget = _gesturesForTargetMap[target] as Vector.<Gesture>;
				if (gesturesForTarget)
				{
					i = gesturesForTarget.length;
					while (i-- > 0)
					{
						gesture = gesturesForTarget[i] as Gesture;
						if (gesture.enabled &&
							(!gesture.delegate || gesture.delegate.gestureShouldReceiveTouch(gesture, touch)))
						{
							//TODO: optimize performance! decide between unshift() vs [i++] = gesture + reverse()
							gesturesForTouch.unshift(gesture);
						}
					}
				}
			}
			
			// Then we populate them with this touch and event.
			// They might start tracking this touch or ignore it (via Gesture#ignoreTouch())
			i = gesturesForTouch.length;
			while (i-- > 0)
			{
				gesture = gesturesForTouch[i] as Gesture;
				// Check for state because previous (i+1) gesture may already abort current (i) one
				if (gesture.state != GestureState.FAILED)
				{
					gesture.touchBeginHandler(touch);
				}
				else
				{
					gesturesForTouch.splice(i, 1);
				}
			}
		}
		
		
		gestouch_internal function onTouchMove(touch:Touch):void
		{
			if (_dirtyGesturesCount > 0)
			{
				resetDirtyGestures();
			}
			
			var gesturesForTouch:Vector.<Gesture> = _gesturesForTouchMap[touch] as Vector.<Gesture>;
			var gesture:Gesture;
			var i:int = gesturesForTouch.length;
			while (i-- > 0)
			{
				gesture = gesturesForTouch[i] as Gesture;
				
				if (gesture.state != GestureState.FAILED && gesture.isTrackingTouch(touch.id))
				{
					gesture.touchMoveHandler(touch);
				}
				else
				{
					// gesture is no more interested in this touch (e.g. ignoreTouch was called)
					gesturesForTouch.splice(i, 1);
				}
			}
		}
		
		
		gestouch_internal function onTouchEnd(touch:Touch):void
		{
			if (_dirtyGesturesCount > 0)
			{
				resetDirtyGestures();
			}
			
			var gesturesForTouch:Vector.<Gesture> = _gesturesForTouchMap[touch] as Vector.<Gesture>;
			var gesture:Gesture;
			var i:int = gesturesForTouch.length;
			while (i-- > 0)
			{
				gesture = gesturesForTouch[i] as Gesture;
				
				if (gesture.state != GestureState.FAILED && gesture.isTrackingTouch(touch.id))
				{
					gesture.touchEndHandler(touch);
				}
			}
			
			gesturesForTouch.length = 0;// release for GC
		}
		
		
		gestouch_internal function onTouchCancel(touch:Touch):void
		{
			//TODO
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		protected function gestureTarget_addedToStageHandler(event:Event):void
		{
			var target:DisplayObject = event.target as DisplayObject;
			target.removeEventListener(Event.ADDED_TO_STAGE, gestureTarget_addedToStageHandler);
			if (!_stage)
			{
				onStageAvailable(target.stage);
			}
		}
		
		
		private function enterFrameHandler(event:Event):void
		{
			resetDirtyGestures();
		}
	}
}
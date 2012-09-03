package org.gestouch.gestures
{
	import org.gestouch.core.Gestouch;
	import org.gestouch.core.GestureState;
	import org.gestouch.core.GesturesManager;
	import org.gestouch.core.IGestureDelegate;
	import org.gestouch.core.IGestureTargetAdapter;
	import org.gestouch.core.Touch;
	import org.gestouch.core.gestouch_internal;
	import org.gestouch.events.GestureEvent;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	
	/**
	 * Dispatched when the state of the gesture changes.
	 * 
	 * @eventType org.gestouch.events.GestureEvent
	 * @see #state
	 */
	[Event(name="gestureStateChange", type="org.gestouch.events.GestureEvent")]
	/**
	 * Dispatched when the state of the gesture changes to GestureState.POSSIBLE.
	 * 
	 * @eventType org.gestouch.events.GestureEvent
	 * @see #state
	 */
	[Event(name="gesturePossible", type="org.gestouch.events.GestureEvent")]
	/**
	 * Dispatched when the state of the gesture changes to GestureState.FAILED.
	 * 
	 * @eventType org.gestouch.events.GestureEvent
	 * @see #state
	 */
	[Event(name="gestureFailed", type="org.gestouch.events.GestureEvent")]
	/**
	 * Base class for all gestures. Gesture is essentially a detector that tracks touch points
	 * in order detect specific gesture motion and form gesture event on target.
	 * 
	 * @author Pavel fljot
	 */
	public class Gesture extends EventDispatcher
	{
		/**
		 * Threshold for screen distance they must move to count as valid input 
		 * (not an accidental offset on touch), 
		 * based on 20 pixels on a 252ppi device.
		 */
		public static var DEFAULT_SLOP:uint = Math.round(20 / 252 * flash.system.Capabilities.screenDPI);
		
		
		protected const _gesturesManager:GesturesManager = Gestouch.gesturesManager;
		/**
		 * Map (generic object) of tracking touch points, where keys are touch points IDs.
		 */
		protected var _touchesMap:Object = {};
		protected var _centralPoint:Point = new Point();
		/**
		 * List of gesture we require to fail.
		 * @see requireGestureToFail()
		 */
		protected var _gesturesToFail:Dictionary = new Dictionary(true);
		protected var _pendingRecognizedState:GestureState;
		
		private var eventListeners:Dictionary = new Dictionary();
		
		use namespace gestouch_internal;
		
		
		public function Gesture(target:Object = null)
		{
			super();
			
			preinit();
			
			this.target = target;
		}
		
		
		/** @private */
		protected var _targetAdapter:IGestureTargetAdapter;
		/**
		 * 
		 */
		gestouch_internal function get targetAdapter():IGestureTargetAdapter
		{
			return _targetAdapter;
		}
		protected function get targetAdapter():IGestureTargetAdapter
		{
			return _targetAdapter;
		}
		
		
		/**
		 * FIXME
		 * InteractiveObject (DisplayObject) which this gesture is tracking the actual gesture motion on.
		 * 
		 * <p>Could be some image, component (like map) or the larger view like Stage.</p>
		 * 
		 * <p>You can change the target in the runtime, e.g. you have a gallery
		 * where only one item is visible at the moment, so use one gesture instance
		 * and change the target to the currently visible item.</p>
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html
		 */
		public function get target():Object
		{
			return _targetAdapter ? _targetAdapter.target : null;
		}
		public function set target(value:Object):void
		{
			var target:Object = this.target;
			if (target == value)
				return;
			
			uninstallTarget(target);
			_targetAdapter = value ? Gestouch.createGestureTargetAdapter(value) : null;
			installTarget(value);
		}
		
		
		/** @private */
		protected var _enabled:Boolean = true;
		
		/** 
		 * @default true
		 */
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(value:Boolean):void
		{
			if (_enabled == value)
				return;
			
			_enabled = value;
			
			if (!_enabled)
			{
				if (state == GestureState.POSSIBLE)
				{
					setState(GestureState.FAILED);
				}
				else
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					setState(GestureState.CANCELLED);
				}
			}
		}
		
		
		private var _delegateWeekStorage:Dictionary;
		public function get delegate():IGestureDelegate
		{
			for (var key:Object in _delegateWeekStorage)
			{
				return key as IGestureDelegate;
			}
			return null;
		}
		public function set delegate(value:IGestureDelegate):void
		{
			for (var key:Object in _delegateWeekStorage)
			{
				delete _delegateWeekStorage[key];
			}
			if (value)
			{
				(_delegateWeekStorage ||= new Dictionary(true))[value] = true;
			}
		}
		
		
		protected var _state:GestureState = GestureState.POSSIBLE;
		public function get state():GestureState
		{
			return _state;
		}
		
		
		protected var _idle:Boolean = true;
		gestouch_internal function get idle():Boolean
		{
			return _idle;
		}
		
		
		protected var _touchesCount:uint = 0;
		/**
		 * Amount of currently tracked touch points.
		 * 
		 * @see #_touches
		 */
		public function get touchesCount():uint
		{
			return _touchesCount;
		}
		
		
		protected var _location:Point = new Point();
		/**
		 * Virtual central touch point among all tracking touch points (geometrical center).
		 */
		public function get location():Point
		{
			return _location.clone();
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
		override public function addEventListener(type:String, listener:Function, 
												  useCapture:Boolean = false, priority:int = 0,
												  useWeakReference:Boolean = false):void
		{
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			
			const listenerProps:Array = eventListeners[listener] as Array;
			if (listenerProps)
			{
				listenerProps.push(type, useCapture);
			}
			else
			{
				eventListeners[listener] = [type, useCapture];
			}
		}
		
		
		public function removeAllEventListeners():void
		{
			for (var listener:Object in eventListeners)
			{
				const listenerProps:Array = eventListeners[listener] as Array;
				
				var n:uint = listenerProps.length;
				for (var i:uint = 0; i < n;)
				{
					super.removeEventListener(listenerProps[i++] as String, listener as Function, listenerProps[i++] as Boolean);
				}
				
				delete eventListeners[listener];
			}
			
//			eventListeners = new Dictionary(true);
		}
		
		
		[Abstract]
		/**
		 * Reflects gesture class (for better perfomance).
		 * 
		 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
		 * 
		 * @see performance optimization tips
		 */
		public function reflect():Class
		{
			throw Error("reflect() is abstract method and must be overridden.");
		}
		
		
		public function isTrackingTouch(touchID:uint):Boolean
		{
			return (_touchesMap[touchID] != undefined);
		}
		
		
		/**
		 * Cancels current tracking (interaction) cycle.
		 * 
		 * <p>Could be useful to "stop" gesture for the current interaction cycle.</p>
		 */
		public function reset():void
		{
			if (idle)
				return;// Do nothing as we are idle and there is nothing to reset
			
			const state:GestureState = this.state;//caching getter
			
			_location.x = 0;
			_location.y = 0;
			_touchesMap = {};
			_touchesCount = 0;
			_idle = true;
			
			for (var key:* in _gesturesToFail)
			{
				var gestureToFail:Gesture = key as Gesture;
				gestureToFail.removeEventListener(GestureEvent.GESTURE_STATE_CHANGE, gestureToFail_stateChangeHandler);
			}
			_pendingRecognizedState = null;
			
			if (state == GestureState.POSSIBLE)
			{
				// manual reset() call. Set to FAILED to keep our State Machine clean and stable
				setState(GestureState.FAILED);
			}
			else if (state == GestureState.BEGAN || state == GestureState.CHANGED)
			{
				// manual reset() call. Set to CANCELLED to keep our State Machine clean and stable
				setState(GestureState.CANCELLED);
			}
			else
			{
				// reset from GesturesManager after reaching one of the 4 final states:
				// (state == GestureState.RECOGNIZED ||
				// state == GestureState.ENDED ||
				// state == GestureState.FAILED ||
				// state == GestureState.CANCELLED)
				setState(GestureState.POSSIBLE);
			}
		}
		
		
		/**
		 * Remove gesture and prepare it for GC.
		 * 
		 * <p>The gesture is not able to use after calling this method.</p>
		 */
		public function dispose():void
		{
			//TODO
			reset();
			removeAllEventListeners();
			target = null;
			delegate = null;
			_gesturesToFail = null;
			eventListeners = null;
		}
		
		
		public function canBePreventedByGesture(preventingGesture:Gesture):Boolean
		{
			return true;
		}
		
		
		public function canPreventGesture(preventedGesture:Gesture):Boolean
		{
			return true;
		}
		
		
		/**
		 * <b>NB! Current implementation is highly experimental!</b> See examples for more info. 
		 */
		public function requireGestureToFail(gesture:Gesture):void
		{
			//TODO
			if (!gesture)
			{
				throw new ArgumentError();
			}
			
			_gesturesToFail[gesture] = true;
		}
		
		


		// --------------------------------------------------------------------------
		// 
		// Protected methods
		// 
		// --------------------------------------------------------------------------
		
		/**
		 * First method, called in constructor.
		 */
		protected function preinit():void
		{
		}
		
		
		/**
		 * Called internally when changing the target.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html
		 */
		protected function installTarget(target:Object):void
		{
			if (target)
			{
				_gesturesManager.addGesture(this);
			}
		}
		
		
		/**
		 * Called internally when changing the target.
		 * 
		 * <p>You should remove all listeners from target here.</p>
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html
		 */
		protected function uninstallTarget(target:Object):void
		{
			if (target)
			{
				_gesturesManager.removeGesture(this);
			}
		}
		
		
		/**
		 * TODO: clarify usage. For now it's supported to call this method in onTouchBegin with return.
		 */
		protected function ignoreTouch(touch:Touch):void
		{
			if (_touchesMap.hasOwnProperty(touch.id))
			{
				delete _touchesMap[touch.id];
				_touchesCount--;
			}
		}
		
		
		protected function failOrIgnoreTouch(touch:Touch):void
		{
			if (state == GestureState.POSSIBLE)
			{
				setState(GestureState.FAILED);
			}
			else
			{
				ignoreTouch(touch);
			}
		}
		
		
		[Abstract]
		/**
		 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
		 */
		protected function onTouchBegin(touch:Touch):void
		{
		}
		
		
		[Abstract]
		/**
		 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
		 */
		protected function onTouchMove(touch:Touch):void
		{
		}
		
		
		[Abstract]
		/**
		 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
		 */
		protected function onTouchEnd(touch:Touch):void
		{
		}
		
		
		/**
		 * 
		 */
		protected function onTouchCancel(touch:Touch):void
		{
		}
		
		
		protected function setState(newState:GestureState):Boolean
		{
			if (_state == newState && _state == GestureState.CHANGED)
			{
				// shortcut for better performance
				
				if (hasEventListener(GestureEvent.GESTURE_STATE_CHANGE))
				{
					dispatchEvent(new GestureEvent(GestureEvent.GESTURE_STATE_CHANGE, _state, _state));
				}
				
				if (hasEventListener(GestureEvent.GESTURE_CHANGED))
				{
					dispatchEvent(new GestureEvent(GestureEvent.GESTURE_CHANGED, _state, _state));
				}
				
				resetNotificationProperties();
				
				return true;
			}
			
			if (!_state.canTransitionTo(newState))
			{
				throw new IllegalOperationError("You cannot change from state " +
					_state + " to state " + newState  + ".");
			}
			
			if (newState != GestureState.POSSIBLE)
			{
				// in case instantly switch state in touchBeganHandler()
				_idle = false;
			}
			
			
			if (newState == GestureState.BEGAN || newState == GestureState.RECOGNIZED)
			{
				var gestureToFail:Gesture;
				var key:*;
				// first we check if other required-to-fail gestures recognized
				// TODO: is this really necessary? using "requireGestureToFail" API assume that
				// required-to-fail gesture always recognizes AFTER this one.
				for (key in _gesturesToFail)
				{
					gestureToFail = key as Gesture;
					if (!gestureToFail.idle &&
						gestureToFail.state != GestureState.POSSIBLE &&
						gestureToFail.state != GestureState.FAILED)
					{
						// Looks like other gesture won't fail,
						// which means the required condition will not happen, so we must fail
						setState(GestureState.FAILED);
						return false;
					}
				}
				// then we check if other required-to-fail gestures are actually tracked (not IDLE)
				// and not still not recognized (e.g. POSSIBLE state)
				for (key in _gesturesToFail)
				{
					gestureToFail = key as Gesture;
					if (gestureToFail.state == GestureState.POSSIBLE)
					{
						// Other gesture might fail soon, so we postpone state change
						_pendingRecognizedState = newState;
						
						for (key in _gesturesToFail)
						{
							gestureToFail = key as Gesture;
							gestureToFail.addEventListener(GestureEvent.GESTURE_STATE_CHANGE, gestureToFail_stateChangeHandler, false, 0, true);
						}
						
						return false;
					}
					// else if gesture is in IDLE state it means it doesn't track anything,
					// so we simply ignore it as it doesn't seem like conflict from this perspective
					// (perspective of using "requireGestureToFail" API)
				}
				
				
				if (delegate && !delegate.gestureShouldBegin(this))
				{
					setState(GestureState.FAILED);
					return false;
				}
			}
				
			var oldState:GestureState = _state;	
			_state = newState;
			
			if (_state.isEndState)
			{
				_gesturesManager.scheduleGestureStateReset(this);
			}
			
			//TODO: what if RTE happens in event handlers?
			
			if (hasEventListener(GestureEvent.GESTURE_STATE_CHANGE))
			{
				dispatchEvent(new GestureEvent(GestureEvent.GESTURE_STATE_CHANGE, _state, oldState));
			}
			
			if (hasEventListener(_state.toEventType()))
			{
				dispatchEvent(new GestureEvent(_state.toEventType(), _state, oldState));
			}
			
			resetNotificationProperties();
			
			if (_state == GestureState.BEGAN || _state == GestureState.RECOGNIZED)
			{
				_gesturesManager.onGestureRecognized(this);
			}
			
			return true;
		}
		
		
		gestouch_internal function setState_internal(state:GestureState):void
		{
			setState(state);
		}
		
		
		protected function updateCentralPoint():void
		{
			var touchLocation:Point;
			var x:Number = 0;
			var y:Number = 0;
			for (var touchID:String in _touchesMap)
			{
				touchLocation = (_touchesMap[int(touchID)] as Touch).location; 
				x += touchLocation.x;
				y += touchLocation.y;
			}
			_centralPoint.x = x / _touchesCount;
			_centralPoint.y = y / _touchesCount;
		}
		
		
		protected function updateLocation():void
		{
			updateCentralPoint();
			_location.x = _centralPoint.x;
			_location.y = _centralPoint.y;
		}
		
		
		protected function resetNotificationProperties():void
		{
			
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Event handlers
		//
		//--------------------------------------------------------------------------
		
		gestouch_internal function touchBeginHandler(touch:Touch):void
		{
			_touchesMap[touch.id] = touch;
			_touchesCount++;
			
			onTouchBegin(touch);
			
			if (_touchesCount == 1 && state == GestureState.POSSIBLE)
			{
				_idle = false;
			}
		}
		
		
		gestouch_internal function touchMoveHandler(touch:Touch):void
		{
			_touchesMap[touch.id] = touch;
			onTouchMove(touch);
		}
		
		
		gestouch_internal function touchEndHandler(touch:Touch):void
		{
			delete _touchesMap[touch.id];
			_touchesCount--;
			
			onTouchEnd(touch);
		}
		
		
		gestouch_internal function touchCancelHandler(touch:Touch):void
		{
			delete _touchesMap[touch.id];
			_touchesCount--;
			
			onTouchCancel(touch);
			
			if (!state.isEndState)
			{
				if (state == GestureState.BEGAN || state == GestureState.CHANGED)
				{
					setState(GestureState.CANCELLED);
				}
				else
				{
					setState(GestureState.FAILED);
				}
			}
		}
		
		
		protected function gestureToFail_stateChangeHandler(event:GestureEvent):void
		{
			if (!_pendingRecognizedState || state != GestureState.POSSIBLE)
				return;
			
			if (event.newState == GestureState.FAILED)
			{
				for (var key:* in _gesturesToFail)
				{
					var gestureToFail:Gesture = key as Gesture;
					if (gestureToFail.state == GestureState.POSSIBLE)
					{
						// we're still waiting for some gesture to fail
						return;
					}
				}
				
				// at this point all gestures-to-fail are either in IDLE or in FAILED states
				setState(_pendingRecognizedState);
			}
			else if (event.newState != GestureState.POSSIBLE)
			{
				//TODO: need to re-think this over
				
				setState(GestureState.FAILED);
			}
		}
	}
}

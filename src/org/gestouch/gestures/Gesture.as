package org.gestouch.gestures
{
	import org.gestouch.core.Gestouch;
	import org.gestouch.core.GestureState;
	import org.gestouch.core.GesturesManager;
	import org.gestouch.core.IGestureDelegate;
	import org.gestouch.core.IGestureTargetAdapter;
	import org.gestouch.core.Touch;
	import org.gestouch.core.gestouch_internal;
	import org.gestouch.events.GestureStateEvent;

	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	
	/**
	 * Dispatched when the state of the gesture changes.
	 * 
	 * @eventType org.gestouch.events.GestureStateEvent
	 * @see #state
	 */
	[Event(name="stateChange", type="org.gestouch.events.GestureStateEvent")]
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
		protected var _localLocation:Point;
		/**
		 * List of gesture we require to fail.
		 * @see requireGestureToFail()
		 */
		protected var _gesturesToFail:Dictionary = new Dictionary(true);
		protected var _pendingRecognizedState:GestureState;
		
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
		
		
		protected var _state:GestureState = GestureState.IDLE;
		public function get state():GestureState
		{
			return _state;
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
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			if (!eventTypeIsValid(type))
			{
				throw new ArgumentError("Event type does not match any of allowed values.");
			}
			
			super.addEventListener(type, listener, useCapture, priority, useWeakReference);
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
			var state:GestureState = this.state;//caching getter
			
			if (state == GestureState.IDLE)
				return;// Do nothing as we're in IDLE and nothing to reset
			
			_location.x = 0;
			_location.y = 0;
			_touchesMap = {};
			_touchesCount = 0;
			
			for (var key:* in _gesturesToFail)
			{
				var gestureToFail:Gesture = key as Gesture;
				gestureToFail.removeEventListener(GestureStateEvent.STATE_CHANGE, gestureToFail_stateChangeHandler);
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
				setState(GestureState.IDLE);
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
			target = null;
			delegate = null;
			_gesturesToFail = null;
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
			else if (state != GestureState.IDLE)
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
				if (hasEventListener(GestureStateEvent.STATE_CHANGE))
				{
					dispatchEvent(new GestureStateEvent(GestureStateEvent.STATE_CHANGE, _state, _state));
				}
				
				return true;
			}
			
			if (!_state.canTransitionTo(newState))
			{
				throw new IllegalOperationError("You cannot change from state " +
					_state + " to state " + newState  + ".");
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
					if (gestureToFail.state != GestureState.IDLE &&
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
							gestureToFail.addEventListener(GestureStateEvent.STATE_CHANGE, gestureToFail_stateChangeHandler, false, 0, true);
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
			
			if (hasEventListener(GestureStateEvent.STATE_CHANGE))
			{
				dispatchEvent(new GestureStateEvent(GestureStateEvent.STATE_CHANGE, _state, oldState));
			}
			
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
			_localLocation = targetAdapter.globalToLocal(_location);
		}
		
		
		/**
		 * Executed once requiredToFail gestures have been failed and
		 * pending (delayed) recognized state has been entered.
		 * You must dispatch gesture event here.
		 */
		protected function onDelayedRecognize():void
		{
			
		}
		
		
		protected function eventTypeIsValid(type:String):Boolean
		{
			// propertyChange just in case for bindings?
			return type == GestureStateEvent.STATE_CHANGE || type == "propertyChange";
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
			
			if (_touchesCount == 1 && state == GestureState.IDLE)
			{
				setState(GestureState.POSSIBLE);
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
		
		
		protected function gestureToFail_stateChangeHandler(event:GestureStateEvent):void
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
				if (setState(_pendingRecognizedState))
				{
					onDelayedRecognize();
				}
			}
			else if (event.newState != GestureState.IDLE && event.newState != GestureState.POSSIBLE)
			{
				// NB: _other_ gesture may switch to IDLE state if it was in FAILED when
				// _this_ gesture initially attempted to switch to one of recognized state.
				// ...and that's OK (we ignore that)
				
				setState(GestureState.FAILED);
			}
		}
	}
}

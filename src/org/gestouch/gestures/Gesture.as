package org.gestouch.gestures
{
	import org.gestouch.core.GestureState;
	import org.gestouch.core.GesturesManager;
	import org.gestouch.core.IGestureDelegate;
	import org.gestouch.core.IGesturesManager;
	import org.gestouch.core.ITouchesManager;
	import org.gestouch.core.Touch;
	import org.gestouch.core.TouchesManager;
	import org.gestouch.core.gestouch_internal;
	import org.gestouch.events.GestureStateEvent;

	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.GestureEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;
	
	
//	[Event(name="gestureTrackingBegin", type="org.gestouch.events.GestureTrackingEvent")]
//	[Event(name="gestureTrackingEnd", type="org.gestouch.events.GestureTrackingEvent")]
	[Event(name="stateChange", type="org.gestouch.events.GestureStateEvent")]
	/**
	 * Base class for all gestures. Gesture is essentially a detector that tracks touch points
	 * in order detect specific gesture motion and form gesture event on target.
	 * 
	 * TODO: locationOfTouchPoint(touchPointID):Point
	 * - ignoreTouch(touch:Touch, event:TouchEvent) ?
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
		public static const DEFAULT_SLOP:uint = Math.round(20 / 252 * flash.system.Capabilities.screenDPI);
		public static const TOUCH_EVENT_CAPTURE_PRIORITY:int = 10;
		
		
		public var delegate:IGestureDelegate;
		
		protected const _touchesManager:ITouchesManager = TouchesManager.getInstance();
		protected const _gesturesManager:IGesturesManager = GesturesManager.getInstance();
		/**
		 * Map (generic object) of tracking touch points, where keys are touch points IDs.
		 */
		protected var _touchesMap:Object = {};
		protected var _centralPoint:Point = new Point();
		protected var _localLocation:Point;
		
		
		public function Gesture(target:InteractiveObject = null)
		{
			super();
			
			preinit();
			
			this.target = target;
		}
		
		
		/** @private */
		protected var _target:InteractiveObject;
		
		/**
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
		public function get target():InteractiveObject
		{
			return _target;
		}
		public function set target(value:InteractiveObject):void
		{
			if (_target == value)
				return;
			
			uninstallTarget(target);
			_target = value;
			installTarget(target);
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
			//TODO
			if (!_enabled && touchesCount > 0)
			{
				setState(GestureState.CANCELLED);
				reset();
			}
		}
		
		
		protected var _state:uint = GestureState.POSSIBLE;
		public function get state():uint
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
			//TODO: to clone or not clone? performance & convention or ...
			return _location.clone();
		}
		
		
		
		
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		
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
			//TODO			
			_location.x = 0;
			_location.y = 0;
			_touchesMap = {};
			_touchesCount = 0;
			
			setState(GestureState.POSSIBLE);
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
		}
		
		
		public function canBePreventedByGesture(preventingGesture:Gesture):Boolean
		{
			return true;
		}
		
		
		public function canPreventGesture(preventedGesture:Gesture):Boolean
		{
			return true;
		}
		
		
		public function requireGestureToFail(gesture:Gesture):void
		{
			//TODO
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
		protected function installTarget(target:InteractiveObject):void
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
		protected function uninstallTarget(target:InteractiveObject):void
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
		
		
		protected function setState(newState:uint):Boolean
		{
			if (_state == newState && _state == GestureState.CHANGED)
			{
				return true;
			}
			
			//TODO: is state sequence validation needed? e.g.:
			//POSSIBLE should be followed by BEGAN or RECOGNIZED or FAILED
			//BEGAN should be follwed by CHANGED or ENDED or CANCELLED
			//CHANGED should be followed by CHANGED or ENDED or CANCELLED
			//...
			
			if (newState == GestureState.BEGAN || newState == GestureState.RECOGNIZED)
			{
				if (delegate && !delegate.gestureShouldBegin(this))
				{
					setState(GestureState.FAILED);
					return false;
				}
			}
				
			var oldState:uint = _state;			
			_state = newState;
			
			if (((GestureState.CANCELLED | GestureState.RECOGNIZED | GestureState.ENDED | GestureState.FAILED) & _state) > 0)
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
		
		
		gestouch_internal function setState_internal(state:uint):void
		{
			setState(state);
		}
		
		
		protected function updateCentralPoint():void
		{
			var touch:Touch;
			var x:Number = 0;
			var y:Number = 0;
			for (var touchID:String in _touchesMap)
			{
				touch = _touchesMap[int(touchID)] as Touch;
				x += touch.x;
				y += touch.y;
			}
			_centralPoint.x = x / _touchesCount;
			_centralPoint.y = y / _touchesCount;
		}
		
		
		protected function updateLocation():void
		{
			updateCentralPoint();
			_location.x = _centralPoint.x;
			_location.y = _centralPoint.y;
			_localLocation = target.globalToLocal(_location);
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
	}
}
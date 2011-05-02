package org.gestouch.gestures
{
	import flash.errors.IllegalOperationError;
	import flash.display.InteractiveObject;
	import flash.events.GestureEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.system.Capabilities;

	import org.gestouch.core.GesturesManager;
	import org.gestouch.core.IGesture;
	import org.gestouch.core.TouchPoint;
	import org.gestouch.core.gestouch_internal;


	/**
	 * Base class for all gestures. Gesture is essentially a detector that tracks touch points
	 * in order detect specific gesture motion and form gesture event on target.
	 * 
	 * @author Pavel fljot
	 */
	public class Gesture implements IGesture
	{
		/**
		 * Threshold for screen distance they must move to count as valid input 
		 * (not an accidental offset on touch), 
		 * based on 20 pixels on a 252ppi device.
		 */
		public static const DEFAULT_SLOP:uint = Math.round(20 / 252 * flash.system.Capabilities.screenDPI);
		
		/**
		 * Array of configuration properties (Strings).
		 */
		protected var _propertyNames:Array = ["minTouchPointsCount", "maxTouchPointsCount"];
		/**
		 * Map (generic object) of tracking touch points, where keys are touch points IDs.
		 */
		protected var _trackingPointsMap:Object = {};
		protected var _trackingPointsCount:int = 0;
		protected var _firstTouchPoint:TouchPoint;
		protected var _lastLocalCentralPoint:Point;
		
		
		public function Gesture(target:InteractiveObject = null, settings:Object = null)
		{
			// Check if gesture reflects it's class properly
			reflect();
						
			_preinit();
			
			GesturesManager.gestouch_internal::addGesture(this);
			
			this.target = target;

			if (settings != null)
			{
				_parseSettings(settings);
			}
		}
		
		
		/** @private */
		private var _minTouchPointsCount:uint = 1;
		/**
		 * Minimum amount of touch points required for gesture.
		 * 
		 * @default 1
		 */
		public function get minTouchPointsCount():uint
		{
			return _minTouchPointsCount;
		}
		public function set minTouchPointsCount(value:uint):void
		{
			if (_minTouchPointsCount == value) return;
			
			_minTouchPointsCount = value;
			if (maxTouchPointsCount < minTouchPointsCount)
			{
				maxTouchPointsCount = minTouchPointsCount;
			}
		}
		
		
		/** @private */
		private var _maxTouchPointsCount:uint = 1;
		
		/**
		 * Maximum amount of touch points required for gesture.
		 * 
		 * @default 1
		 */
		public function get maxTouchPointsCount():uint
		{
			return _maxTouchPointsCount;
		}
		public function set maxTouchPointsCount(value:uint):void
		{
			if (value < minTouchPointsCount)
			{
				throw new IllegalOperationError("maxTouchPointsCount can not be less then minTouchPointsCount");
			}
			if (_maxTouchPointsCount == value) return;
			
			_maxTouchPointsCount = value;
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
			if (_target == value) return;
			
			GesturesManager.gestouch_internal::updateGestureTarget(this, target, value);
			
			// if GesturesManager hasn't thrown any error we can safely continue
			
			if (target)
			{
				_uninstallTarget(target);
			}
			
			_target = value;
			
			if (target)
			{
				_installTarget(target);
			}
		}
		
		
		/**
		 * Storage for the trackingPoints property.
		 */
		protected var _trackingPoints:Vector.<TouchPoint> = new Vector.<TouchPoint>();
		/**
		 * Vector of tracking touch points — touch points this gesture is interested in.
		 * 
		 * <p>For the most gestures these points are which on top of the target.</p>
		 * 
		 * @see #isTracking()
		 * @see #shouldTrackPoint()
		 */
		public function get trackingPoints():Vector.<TouchPoint>
		{
			return _trackingPoints.concat();
		}
		
		
		/**
		 * Amount of currently tracked touch points. Cached value of trackingPoints.length
		 * 
		 * @see #trackingPoints
		 */
		public function get trackingPointsCount():uint
		{
			return _trackingPointsCount;
		}
		
		
		/**
		 * Storage for centralPoint property.
		 */
		protected var _centralPoint:TouchPoint;
		/**
		 * Virtual central touch point among all tracking touch points (geometrical center).
		 * 
		 * <p>Designed for multitouch gestures, where center could be used for
		 * approximation or anchor. Use _adjustCentralPoint() method for updating centralPoint.</p>
		 * 
		 * @see #_adjustCentralPoint()
		 */
		public function get centralPoint():TouchPoint
		{
			return _centralPoint;
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
		
		
		[Abstract]
		/**
		 * Used by GesturesManager to check wether this gesture is interested in
		 * tracking this touch point upon this event (of type TouchEvent.TOUCH_BEGIN).
		 * 
		 * <p>Most of the gestures check, if event.target is target or target contains event.target</p>
		 * 
		 * <p>No need to use it directly.</p>
		 * 
		 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
		 * 
		 * @see org.gestouch.core.GesturesManager
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/TouchEvent.html
		 */
		public function shouldTrackPoint(event:TouchEvent, tp:TouchPoint):Boolean
		{
			throw Error("shouldTrackPoint() is abstract method and must be overridden.");
		}
		
		
		/**
		 * Used by GesturesManager to check wether this gesture is tracking this touch point.
		 * (Not to invoke onTouchBegin, onTouchMove and onTouchEnd methods with no need)
		 * 
		 * @see org.gestouch.core.GesturesManager
		 */
		public function isTracking(touchPointID:uint):Boolean
		{
			return (_trackingPointsMap[touchPointID] === true);
		}
		
		
		/**
		 * Cancels current tracking (interaction) cycle.
		 * 
		 * <p>Could be useful to "stop" gesture for the current interaction cycle.</p>
		 */
		public function cancel():void
		{
			GesturesManager.gestouch_internal::cancelGesture(this);
		}
		
		
		/**
		 * TODO: write description, decide wethere this API is good.
		 */
		public function pickAndContinue(gesture:IGesture):void
		{
			GesturesManager.gestouch_internal::addCurrentGesture(this);
			
			for each (var tp:TouchPoint in gesture.trackingPoints)
			{
				onTouchBegin(tp);
			}
		}
		
		
		/**
		 * Remove gesture and prepare it for GC.
		 * 
		 * <p>The gesture is not able to use after calling this method.</p>
		 */
		public function dispose():void
		{
			_reset();
			target = null;
			try
			{
				GesturesManager.gestouch_internal::removeGesture(this);
			}
			catch (err:Error)
			{
				// do nothing
				// GesturesManager may throw Error if this gesture is already removed:
				// in case dispose() is called by GesturesManager upon GestureClass.remove(target)
				
				// this part smells a bit, eh?
			}
		}
		
		
		[Abstract]
		/**
		 * Internal method, used by GesturesManager.
		 * 
		 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
		 */
		public function onTouchBegin(touchPoint:TouchPoint):void
		{
			
		}
		
		
		[Abstract]
		/**
		 * Internal method, used by GesturesManager.
		 * 
		 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
		 */
		public function onTouchMove(touchPoint:TouchPoint):void
		{
		}
		
		
		[Abstract]
		/**
		 * Internal method, used by GesturesManager.
		 * 
		 * <p><b>NB!</b> This is abstract method and must be overridden.</p>
		 */
		public function onTouchEnd(touchPoint:TouchPoint):void
		{
			
		}
		
		
		/**
		 * Internal method, used by GesturesManager. Called upon gesture is cancelled.
		 * 
		 * @see #cancel()
		 */
		public function onCancel():void
		{
			_reset();
		}
		



		// --------------------------------------------------------------------------
		// 
		// Protected methods
		// 
		// --------------------------------------------------------------------------
		
		/**
		 * First method, called in constructor.
		 * 
		 * <p>Good place to put gesture configuration related code. For example (abstract):</p>
		 * <listing version="3.0">
minTouchPointsCount = 2;
_propertyNames.push("timeThreshold", "moveThreshold");
		 * </listing>
		 */
		protected function _preinit():void
		{
		}
		
		
		/**
		 * Called internally when changing the target.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html
		 */
		protected function _installTarget(target:InteractiveObject):void
		{
			
		}
		
		
		/**
		 * Called internally when changing the target.
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/InteractiveObject.html
		 */
		protected function _uninstallTarget(target:InteractiveObject):void
		{
			
		}
		
		
		/**
		 * Dispatches gesture event from the name of target.
		 * 
		 * @param event GestureEvent to be dispatched from target
		 * 
		 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/events/GestureEvent.html
		 */
		protected function _dispatch(event:GestureEvent):void
		{
			target.dispatchEvent(event);
		}


		/**
		 * Parses settings and configures the gesture.
		 * 
		 * @param settings Generic object with configuration properties
		 */
		protected function _parseSettings(settings:Object):void
		{
			for each (var propertyName:String in _propertyNames)
			{
				if (settings.hasOwnProperty(propertyName))
				{
					this[propertyName] = settings[propertyName];
				}
			}
		}
		
		
		/**
		 * Saves touchPoint for tracking for the current gesture cycle.
		 * 
		 * <p>If this is the first touch point, it updates _firstTouchPoint and _centralPoint.</p>
		 * 
		 * @see #_firstTouchPoint
		 * @see #centralPoint
		 * @see #trackingPointsCount
		 */
		protected function _trackPoint(touchPoint:TouchPoint):void
		{
			_trackingPointsMap[touchPoint.id] = true;
			var index:uint = _trackingPoints.push(touchPoint);
			_trackingPointsCount++;
			if (index == 1)
			{
				_firstTouchPoint = touchPoint;
				_centralPoint = touchPoint.clone() as TouchPoint;
			}
		}
		
		
		/**
		 * Removes touchPoint from the list of tracking points.
		 * 
		 * <p>If this is the first touch point, it updates _firstTouchPoint and _centralPoint.</p>
		 * 
		 * @see #trackingPoints
		 * @see #_trackingPointsMap
		 * @see #trackingPointsCount
		 */
		protected function _forgetPoint(touchPoint:TouchPoint):void
		{
			delete _trackingPointsMap[touchPoint.id];
			_trackingPoints.splice(_trackingPoints.indexOf(touchPoint), 1);
			_trackingPointsCount--;
		}
		
		
		/**
		 * Adjusts (recalculates) _centralPoint and all it's properties
		 * (such as positions, offsets, velocity, etc...).
		 * Also updates _lastLocalCentralPoint (used for dispatching events).
		 * 
		 * @see #centralPoint
		 * @see #_lastLocalCentralPoint
		 * @see #trackingPoints
		 */
		protected function _adjustCentralPoint():void
		{
			var x:Number = 0;
			var y:Number = 0;
			var velX:Number = 0;
			var velY:Number = 0;
			for each (var tp:TouchPoint in _trackingPoints)
			{
				x += tp.x;
				y += tp.y;
				velX += tp.velocity.x;
				velY += tp.velocity.y;
			}
			x /= _trackingPointsCount;
			y /= _trackingPointsCount;
			var lastMoveX:Number = x - _centralPoint.x;
			var lastMoveY:Number = y - _centralPoint.y;
			velX /= _trackingPointsCount;
			velY /= _trackingPointsCount;
			
			_centralPoint.x = x;
			_centralPoint.y = y;
			_centralPoint.lastMove.x = lastMoveX;
			_centralPoint.lastMove.y = lastMoveY;
			_centralPoint.velocity.x = velX;
			_centralPoint.velocity.y = velY;
			// tp.moveOffset = tp.subtract(tp.touchBeginPos);
			_centralPoint.moveOffset.x = x - _centralPoint.touchBeginPos.x;
			_centralPoint.moveOffset.y = y - _centralPoint.touchBeginPos.y;
			
			_lastLocalCentralPoint = target.globalToLocal(_centralPoint);
		}
		
		
		/**
		 * Reset data for the current tracking (interaction) cycle.
		 * 
		 * <p>Clears up _trackingPointsMap, _trackingPoints, _trackingPointsCount
		 * and other custom gestures-specific things.</p>
		 * 
		 * <p>Generally invoked in onCancel method and when certain conditions of gesture
		 * have been failed and gesture doesn't need to continue processsing
		 * (e.g. timer has completed in DoubleTapGesture)</p>
		 * 
		 * @see #trackingPoints
		 * @see #trackingPointsCount
		 * @see #onCancel()
		 */
		protected function _reset():void
		{
			// forget all touch points
			_trackingPointsMap = {};
			_trackingPoints.length = 0;
			_trackingPointsCount = 0;
		}
	}
}
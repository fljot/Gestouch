package org.gestouch.gestures.symbolic
{
	import flash.geom.Point;
	import flash.system.Capabilities;
	
	import org.gestouch.core.GestureState;
	import org.gestouch.core.Touch;
	import org.gestouch.gestures.AbstractDiscreteGesture;
	import org.gestouch.gestures.Gesture;
	import org.gestouch.gestures.symbolic.sets.SymbolSet;
	
	
	/**
	 * <b>Example:</b>
	 * <br/>
	 * <listing version="3.0">
	 * // initialization:
	 * var symbolic:SymbolicGesture;
	 * symbolic = new SymbolicGesture(stage, new SymbolicGestureLevenstheinRecognizer(10, 8));
	 * //symbolic.addEventListener(GestureEvent.GESTURE_STATE_CHANGE, symbolicGestureStateChangeHandler);
	 * symbolic.addEventListener(GestureEvent.GESTURE_RECOGNIZED, symbolicGestureRecognizeHandler);
	 * 
	 * //symbolic.addSymbolSet(new AlphabetSymbolSet());
	 * //symbolic.addSymbolSet(new NumericSymbolSet());
	 * symbolic.addSymbolSet(new ActionsSymbolSet(1));
	 * 
	 * symbolic.addSymbol(new Symbol("BACKSPACE", "4"));
	 * symbolic.addSymbol(new Symbol("SPACE", "0"));
	 * symbolic.addSymbol(new Symbol("SPIRAL", "6543210765"));
	 * 
	 * // ....
	 * 
	 * private function symbolicGestureRecognizeHandler(e:GestureEvent):void
	 * {
	 * 	removeChildren();
	 * 	trace('RECOGNIZED:', symbolic.bestMatch.fiability, '"' + symbolic.bestMatch.symbol.data + '"', '[' + symbolic.bestMatch.moves + ']', '[' + symbolic.bestMatch.symbol.moves + ']');
	 * 	
	 * 	const bounds:Rectangle = symbolic.bestMatch.bounds;
	 * 	var q:Quad = new Quad(bounds.width, bounds.height, 0xFFFFFF);
	 * 	q.x = bounds.x;
	 * 	q.y = bounds.y;
	 * 	addChild(q);
	 * 	
	 * 	const points:Vector.<Point> = symbolic.bestMatch.points.concat();
	 * 	for each(var p:Point in points)
	 * 	{
	 * 		q = new Quad(20, 20, 0xFFFFFF * Math.random());
	 * 		q.x = p.x;
	 * 		q.y = p.y;
	 * 		addChild(q);
	 * 	}
	 * }
	 * </listing>
	 * <br/>
	 * <i>Idea and some algorithms are partially based on MouseGesture</i> (http://www.bytearray.org/?p=91)
	 * @author Aleksandr Kozlovskij (created: Sep 24, 2012)
	 */
	//TODO: extends AbstractContinuousGesture
	public final class SymbolicGesture extends AbstractDiscreteGesture
	{
		// defaults:
		public static const DEFAULT_RECOGNIZER:Class = SymbolicGestureLevenstheinRecognizer;
		
		// properties:
		public var allowProcessingInCapturingPhase:Boolean;
		
		/**
		 * Precision of catpure in pixels (or one segment on path).
		 */		
		public var slop:Number = Gesture.DEFAULT_SLOP;
		
		/**
		 * Last touch point
		 */		
		private var prevLocation:Point;
		
		private var _maxTouchesPossible:uint = 1;
		private var _minTouchesRequired:uint = 1;
		private var _minTouchesRequiredReached:Boolean;
		
		// instances:
		private var _recognizer:ISymbolicGestureRecognizer;
		
		/**
		 * Gestures to match
		 */		
		private var symbols:Vector.<Symbol> = new Vector.<Symbol>();
		
		//------------ constructor ------------//
		
		public function SymbolicGesture(target:Object = null, recognizer:ISymbolicGestureRecognizer = null)
		{
			super(target);
			this.recognizer = recognizer;
		}
		
		//------------ initialize ------------//
		
		override protected function preinit():void
		{
			super.preinit();
			
			if(!_recognizer)
				_recognizer = new DEFAULT_RECOGNIZER();
			_recognizer.initialize();
			
			// clean gesture-spots:
			symbols.length = 0;
		}
		
		
		override public function reset():void
		{
			super.reset();
			
			_recognizer.resetTemporaryData();
			//_recognizer.dispose();
			
			_maxTouchesPossible = _minTouchesRequired = 1;
			_minTouchesRequiredReached = false;
		}
		
		//--------------- CTRL ---------------//
		
		public function addSymbol(symbol:Symbol):void
		{
			const index:int = symbols.indexOf(symbol);
			
			if(index === -1)
				symbols.push(symbol);
			else
				trace(this, ':', symbol, 'already added and have index:', index);
			
			_minTouchesRequired = Math.min(symbol.numTouchesRequired, _minTouchesRequired);
			_maxTouchesPossible = Math.max(symbol.numTouchesRequired, _maxTouchesPossible);
		}
		
		public function addSymbolSet(set:SymbolSet):void
		{
			const symbols:Vector.<Symbol> = set.symbols;
			for each(var symbol:Symbol in symbols)
				addSymbol(symbol);
		}
		
		//--------------- ctrl ---------------//
		
		override public function reflect():Class
		{
			return SymbolicGesture;
		}
		
		private final function captureStep():void
		{
			// get clone:
			const current:Point = location;
			
			// calculate diff:
			const diffX:int = current.x - prevLocation.x;
			const diffY:int = current.y - prevLocation.y;
			const squareDistance:Number = diffX * diffX + diffY * diffY;
			const squarePrecision:Number = slop * slop;
			
			if(squareDistance > squarePrecision)
			{
				_recognizer.pushLocation(current, diffX, diffY);
				prevLocation.setTo(current.x, current.y);
			}
			
			// dispatch
			//TODO: промежуточные совпадения, если в настройках сказано allowProcessingInCapturingPhase = true
			//onCapturing.dispatch(this);
		}
		
		//------------ get / set -------------//
		
		public function get recognizer():ISymbolicGestureRecognizer
		{
			return _recognizer;
		}
		
		public function set recognizer(value:ISymbolicGestureRecognizer):void
		{
			if(value === _recognizer)
				return;
			
			if(_recognizer)
				_recognizer.dispose();
			
			_recognizer = value;
			_recognizer.initialize();
		}
		
		/*public function get capturingDelay():uint
		{
			return _timer.delay;
		}
		
		public function set capturingDelay(value:uint):void
		{
			_timer.delay = value || DEFAULT_TIME_STEP;
		}*/
		
		public function get maxTouchesPossible():uint
		{
			return _maxTouchesPossible;
		}
		
		public function get minTouchesRequired():uint
		{
			return _minTouchesRequired;
		}
		
		public function get bestMatch():SymbolicGestureRecognizerMatchingVO
		{
			return _recognizer.lastBestMatchingResult;
		}
		
		//------- handlers / callbacks -------//
		
		override protected function onTouchBegin(touch:Touch):void
		{
			if(touchesCount < _minTouchesRequired || touchesCount > _maxTouchesPossible)
				return failOrIgnoreTouch(touch);
			
			
			_minTouchesRequiredReached = true;
			
			// reset data in recognizer:
			_recognizer.resetTemporaryData();
			
			//start capture:
			prevLocation = new Point(location.x, location.y);
		}
		
		
		override protected function onTouchMove(touch:Touch):void
		{
			if(touchesCount > _maxTouchesPossible)
			{
				//return failOrIgnoreTouch(touch);
				setState(GestureState.FAILED);
				return;
			}
			
			if(state == GestureState.POSSIBLE && slop > 0 && touch.locationOffset.length > slop)
			{
				updateLocation();
				captureStep();
			}
		}
		
		
		override protected function onTouchEnd(touch:Touch):void
		{
			if(_minTouchesRequiredReached)
			{
				if(state == GestureState.POSSIBLE)
				{
					const touchesCount:uint = !this.touchesCount && Capabilities.isDebugger ? 1 : this.touchesCount;
					
					// match & dispatch:
					if(_recognizer.findBestMatchingSymbol(symbols, touchesCount))
						setState(GestureState.RECOGNIZED);
					else
						setState(GestureState.FAILED);
				}
			}
			else
			{
				setState(GestureState.FAILED);
			}
		}
	}
}
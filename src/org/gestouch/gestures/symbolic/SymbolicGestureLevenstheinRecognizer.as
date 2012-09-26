package org.gestouch.gestures.symbolic
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.gestouch.utils.GestureUtils;
	
	/**
	 * @see http://ru.wikipedia.org/wiki/Расстояние_Левенштейна
	 * @author Aleksandr Kozlovskij (created: Sep 25, 2012)
	 */
	public final class SymbolicGestureLevenstheinRecognizer implements ISymbolicGestureRecognizer
	{
		/** Number of sectors
		 */		
		public static const DEFAULT_NUM_SECTORS:uint = 8;
		
		/** Default fiability level
		 */		
		public static const DEFAULT_FIABILITY:uint = 30;
		
		public var sectors:uint = DEFAULT_NUM_SECTORS;
		public var fiability:uint = DEFAULT_FIABILITY;
		
		/** Angle of one sector
		 */		
		private var sector:Number;
		
		/** Angles map
		 */		
		private const angles:Vector.<Number> = new Vector.<Number>();
		
		/** Current gestures
		 */		
		private const moves:Vector.<int> = new Vector.<int>();
		
		/** Current points
		 */		
		private var points:Vector.<Point> = new Vector.<Point>();
		
		/** Last touch point
		 */		
		private const prevLocation:Point = new Point(NaN, NaN);
		
		/** Rectangular current gesture zone
		 */		
		private var bounds:Object;
		
		/**
		 * Saved result after last call <code>findBestMatchingSymbol()</code> method 
		 */		
		private var _lastBestMatchingResult:SymbolicGestureRecognizerMatchingVO; // mb. null if not has matches
		private var _catchedBestMatchingResult:SymbolicGestureRecognizerMatchingVO; // always not eq null, if possible
		
		//------------ constructor ------------//
		
		public function SymbolicGestureLevenstheinRecognizer(fiability:uint = DEFAULT_FIABILITY, sectors:uint = DEFAULT_NUM_SECTORS)
		{
			this.sectors = sectors;
			this.fiability = fiability;
		}
		
		//------------ initialize ------------//
		
		public function initialize():void
		{
			// Build the angles map
			buildAnglesMap();
			
		}
		
		private final function buildAnglesMap():void
		{
			// Angle of one sector
			sector = GestureUtils.PI_DOUBLE / sectors;
			
			// map containing sectors no from 0 to PI*2
			angles.length = 0;
			
			// the precision is Math.PI * 2 / 100
			const step:Number = GestureUtils.PI_DOUBLE / 100;
			
			// memorize sectors
			var _sector:Number;
			for(var i:Number = -sector / 2; i <= GestureUtils.PI_DOUBLE -sector / 2; i += step)
			{
				_sector = Math.floor((i + sector / 2) / sector);
				angles.push(_sector);
			}
			
			angles.fixed = true;
		}
		
		public function resetTemporaryData():void
		{
			// moves
			moves.length = 0;
			points.length = 0;
			prevLocation.setTo(NaN, NaN);
			
			bounds = {minx: Number.POSITIVE_INFINITY,
				maxx: Number.NEGATIVE_INFINITY,
				miny: Number.POSITIVE_INFINITY,
				maxy: Number.NEGATIVE_INFINITY
			};
			
			//TODO: _lastBestMatchingResult.dispose();
			_lastBestMatchingResult = null;
		}
		
		public function dispose():void
		{
			resetTemporaryData();
			
			//TODO: _catchedBestMatchingResult.dispose();
			_catchedBestMatchingResult = null;
		}
		
		//--------------- ctrl ---------------//
		
		public final function pushLocation(location:Point, diffX:int, diffY:int):void
		{
			prevLocation.setTo(location.x, location.y);
			
			points.push(location);
			addMove(diffX, diffY);
			
			
			if(location.x < bounds.minx)
				bounds.minx = location.x;
			
			if(location.x > bounds.maxx)
				bounds.maxx = location.x;
			
			if(location.y < bounds.miny)
				bounds.miny = location.y;
			
			if(location.y > bounds.maxy)
				bounds.maxy = location.y;
		}
		
		private final function addMove(dx:int, dy:int):void
		{
			var angle:Number = Math.atan2(dy, dx) + sector / 2;
			
			if(angle < 0)
				angle += GestureUtils.PI_DOUBLE;
			
			const no:int = Math.floor(angle / (GestureUtils.PI_DOUBLE) * 100);
			moves.push(angles[no]);
		}
		
		
		
		public final function findBestMatchingSymbol(etalons:Vector.<Symbol>, currentTouchesCount:uint):SymbolicGestureRecognizerMatchingVO
		{
			const symbolsNum:uint = etalons.length;
			var bestCost:uint = 1000000;
			var cost:uint;
			var etalon:Vector.<int>;
			var bestSymbol:Symbol;
			
			const info:Object = new Object();
			info.points = points;
			info.moves = moves;
			info.location = prevLocation.clone();
			info.bounds = new Rectangle(bounds.minx, bounds.miny, bounds.maxx - bounds.minx, bounds.maxy - bounds.miny);
			
			for(var i:uint = 0; i < symbolsNum; i++)
			{
				if(etalons[i].numTouchesRequired > currentTouchesCount)
					continue;
				
				etalon = etalons[i].moves;
				info.data = etalons[i].data;
				cost = calculateSymbolCost(etalon, moves);
				
				if(cost <= fiability)
				{
					if(etalons[i].matcher != null)
					{
						info.cost = cost;
						cost = etalons[i].matcher(info);
					}
					
					if(cost < bestCost)
					{
						bestCost = cost;
						bestSymbol = etalons[i];
					}
				}
			}
			
			if(bestSymbol)
			{
				_lastBestMatchingResult = new SymbolicGestureRecognizerMatchingVO(bestSymbol, bestCost, moves, points, info.bounds);
				_lastBestMatchingResult && (_catchedBestMatchingResult = _lastBestMatchingResult);
			}
			else
				_lastBestMatchingResult = null;
			
			return _lastBestMatchingResult;
		}
		
		private final function calculateSymbolCost(etalon:Vector.<int>, current:Vector.<int>):uint
		{
			if(current.length === 0)
				return 100000;
			
			// precalculation diff-angles:
			const d:Array = fill2DTable(etalon.length + 1, current.length + 1, 0);
			const w:Array = d.slice();
			
			for(var x:uint = 1; x <= etalon.length; x++)
			{
				for(var y:uint = 1; y < current.length; y++)
				{
					d[x][y] = diffAngle(etalon[x-1], current[y-1]);
				}
			}
			
			// max cost:
			for(y = 1; y <= current.length; y++)
				w[0][y] = 100000;
			
			for(x = 1; x <= etalon.length; x++)
				w[x][0] = 100000;
			
			w[0][0] = 0;
			
			// levensthein application:
			var cost:uint = 0;
			var pa:uint;
			var pb:uint;
			var pc:uint;
			
			for(x = 1; x <= etalon.length; x++)
			{
				for(y = 1; y < current.length; y++)
				{
					cost = d[x][y];
					pa = w[x - 1][y] + cost;
					pb = w[x][y - 1] + cost;
					pc = w[x - 1][y - 1] + cost;
					w[x][y] = Math.min(Math.min(pa, pb), pc)
				}
			}
			
			return w[x - 1][y - 1];
		}
		
		private final function diffAngle(a:uint, b:uint):uint
		{
			var dif:uint = Math.abs(a - b);
			if(dif > sectors / 2)
				dif = sectors - dif;
			return dif;
		}
		
		private final function fill2DTable(w:uint, h:uint, f:*):Array
		{
			var o:Array = new Array(w);
			for(var x:uint = 0; x < w; x++)
			{
				o[x] = new Array(h);
				for(var y:uint = 0; y < h; y++)
					o[x][y] = f;
			}
			return o;
		}
		
		//------------ get / set -------------//
		
		public function get lastBestMatchingResult():SymbolicGestureRecognizerMatchingVO
		{
			return _lastBestMatchingResult;
		}
		
		public function get catchedBestMatchingResult():SymbolicGestureRecognizerMatchingVO
		{
			return _catchedBestMatchingResult;
		}
		
		//------- handlers / callbacks -------//
	}
}
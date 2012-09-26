package org.gestouch.gestures.symbolic
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * @author Aleksandr Kozlovskij (created: Sep 25, 2012)
	 */
	public final class SymbolicGestureRecognizerMatchingVO
	{
		private var _symbol:Symbol = null;
		private var _fiability:uint = 0;
		private var _bounds:Rectangle = null;
		private var _moves:Vector.<int> = null;
		private var _points:Vector.<Point> = null;
		private var _lastPoint:Point;
		
		private var _data:*;
		
		//------------ constructor ------------//
		
		public function SymbolicGestureRecognizerMatchingVO(symbol:Symbol = null, fiability:uint = 0, movies:Vector.<int> = null, points:Vector.<Point> = null, bounds:Rectangle = null)
		{
			_symbol = symbol;
			_bounds = bounds;
			_moves = movies;
			_points = points;
			_fiability = fiability;
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
		public function get data():*
		{
			return _data || symbol.data;
		}

		public function set data(value:*):void
		{
			_data = value;
		}

		public function get symbol():Symbol
		{
			return _symbol;
		}

		public function get fiability():uint
		{
			return _fiability;
		}

		public function get bounds():Rectangle
		{
			return _bounds;
		}

		public function get moves():Vector.<int>
		{
			return _moves;
		}

		public function get points():Vector.<Point>
		{
			return _points;
		}

		public function get lastPoint():Point
		{
			return _lastPoint;
		}
	}
}
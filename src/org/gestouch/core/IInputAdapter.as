package org.gestouch.core
{
	/**
	 * @author Pavel fljot
	 */
	public interface IInputAdapter
	{
		function set touchesManager(value:ITouchesManager):void;
		
		function init():void;
		function dispose():void;
	}
}
package org.gestouch.core
{
	/**
	 * @author Pavel fljot
	 */
	public interface IInputAdapter
	{
		/**
		 * @private
		 */
		function set touchesManager(value:TouchesManager):void;
		
		/**
		 * Called when input adapter is set.
		 */
		function init():void;
	}
}

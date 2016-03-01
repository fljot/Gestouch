package org.gestouch.core
{
	/**
	 * Responsible for system input.
	 * Must receive input and pass it to TouchesManager.
	 */
	public interface IInputAdapter
	{
		/**
		 * Starts input handling.
		 * Called when input adapter is set.
		 */
		function init(touchesManager:TouchesManager):void;

		/**
		 * Stops all input handling.
		 * Called when input adapter is unset or replaced by another one.
		 */
		function teardown():void;
	}
}

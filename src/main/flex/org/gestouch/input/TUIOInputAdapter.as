package org.gestouch.input
{
	import org.gestouch.core.IInputAdapter;
	import org.gestouch.core.TouchesManager;


	/**
	 * TODO: You can implement your own TUIO Input Adapter (and supply touchesManager with
	 * touch info), but IMHO it is way easier to use NativeInputAdapter and any TUIO library
	 * and manually dispatch native TouchEvents using DisplayObjectContainer#getObjectsUnderPoint()
	 * 
	 * @see NativeInputAdapter
	 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/DisplayObjectContainer.html#getObjectsUnderPoint() DisplayObjectContainer#getObjectsUnderPoint() 
	 * 
	 * @author Pavel fljot
	 */
	public class TUIOInputAdapter implements IInputAdapter
	{
		public function init():void
		{
		}


		public function onDispose():void
		{
		}


		public function set touchesManager(value:TouchesManager):void
		{
		}
	}
}

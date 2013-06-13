package org.gestouch.extensions.native
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.geom.Point;


/**
 * @author    Valentin Simonov
 */
public class DisplayObjectUtils
{
	/**
	 * Searches display list for top most instance of InteractiveObject.
	 * Checks if mouseEnabled is true and (optionally) parent's mouseChildren.
	 * @param stage                Stage object.
	 * @param point                Global point to test.
	 * @param mouseChildren        If true also checks parents chain for mouseChildren == true.
	 * @param startFrom            An index to start looking from in objects under point array.
	 * @return                    Top most InteractiveObject or Stage.
	 */
	public static function getTopTarget(stage:Stage, point:Point, mouseChildren:Boolean = true, startFrom:uint = 0):InteractiveObject
	{
		var targets:Array = stage.getObjectsUnderPoint(point);
		if (!targets.length) return stage;

		var startIndex:int = targets.length - 1 - startFrom;
		if (startIndex < 0) return stage;

		outer:
				for (var i:int = startIndex; i >= 0; i--)
				{
					var target:DisplayObject = targets[i] as DisplayObject;
					while (target != stage)
					{
						if (target is InteractiveObject)
						{
							if ((target as InteractiveObject).mouseEnabled)
							{
								if (mouseChildren)
								{
									var lastMouseActive:InteractiveObject = target as InteractiveObject;
									var parent:DisplayObjectContainer = target.parent;
									while (parent)
									{
										if (!lastMouseActive && parent.mouseEnabled)
										{
											lastMouseActive = parent;
										}
										else if (!parent.mouseChildren)
										{
											if (parent.mouseEnabled)
											{
												lastMouseActive = parent;
											}
											else
											{
												lastMouseActive = null;
											}
										}
										parent = parent.parent;
									}
									if (lastMouseActive)
									{
										return lastMouseActive;
									}
									else
									{
										return stage;
									}
								}
								else
								{
									return target as InteractiveObject;
								}
							}
							else
							{
								continue outer;
							}
						}
						else
						{
							target = target.parent;
						}
					}
				}

		return stage;
	}
}
}

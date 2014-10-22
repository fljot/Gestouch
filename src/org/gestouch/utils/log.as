package org.gestouch.utils
{
public function log(...args):void
{
	// You can switch to custom logging if you really need it for debugging

	var tmp:Array = new Error().getStackTrace().split("\n");
	tmp = tmp[2].split(" ");
	tmp = tmp[1].split("[");
	// tmp[0] is a string "class/method()"

	args.unshift("[Gestouch]", tmp[0]);
	trace.apply(null, args);
}
}

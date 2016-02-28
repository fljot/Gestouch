# Changelog

## Version 0.4.8 (SNAPSHOT)

* Refactored library initialization from semi-automatic to manual as it was bringing certain confusion with Starling
and Stage. To initialize library use:

```
// Minimum configuration
Gestouch.inputAdapter = new NativeInputAdapter(stage);

// If you are going to use gestures with flash.display.DisplayObject
Gestouch.addDisplayListAdapter(flash.display.DisplayObject, new NativeDisplayListAdapter());
Gestouch.addTouchHitTester(new NativeTouchHitTester(stage));

// If you are going to use gestures with Starling
Gestouch.addDisplayListAdapter(starling.display.DisplayObject, new StarlingDisplayListAdapter());
Gestouch.addTouchHitTester(new StarlingTouchHitTester(starling), -1);

```

h1. Gestouch: multitouch gesture recognition library for Flash (ActionScript) development.

Gestouch is a ActionScript (AS3) library that helps you to deal with single- and multitouch gestures for building better NUI (Natural User Interface).


h3. Why? There's already gesture support in Flash/AIR!

Yes, last versions of Flash Player and AIR runtimes have built-in touch and multitouch support, but the gestures support is very poor: only small set of gestures are supported, they depend on OS, they are not customizable in any way, only one can be processed at the same time and, finally, you are forced to use either raw TouchEvents, or gestures (@see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/ui/Multitouch.html#inputMode).
_Upd:_ With "native way" you also won't get anything out of Stage3D and of custom input like TUIO protocol. 



h3. What Gestouch does in short?

Well basically there's 3 distinctive tasks to solve.
# To provide various input. It can be native MouseEvents, TouchEvents or more complex things like custom input via TUIO protocol for your hand-made installation. So what we get here is Touches (touch points).
# To recognize gesture analyzing touches. Each type of Gesture has it's own inner algorithms that ... 
# To manage gestures conflicts. As multiple gestures may be recognized simultaneously, we need to be able to control whether it's allowed or some of them should not be recognized (fail).

Gestouch solves these 3 tasks.
I was hardly inspired by Apple team, how they solved this (quite recently to my big surprise! I thought they had it right from the beginning) in they Cocoa-touch UIKit framework. Gestouch is very similar in many ways. But I wouldn't call it "direct port" because 1) the whole architecture was implemented based just on conference videos and user documentation 2) flash platform is a different platform with own specialization, needs, etc.
So I want Gestouch to go far beyond that.

Features:
* Pretty neat architecture! Very similar to Apple's UIGestureRecognizers (Cocoa-Touch UIKit)
* Works with any display list hierarchy structures: native DisplayList (pure AS3/Flex/your UI framework), Starling or ND2D (Stage3D) and 3D libs...
* Doesn't require any additional software (may use runtime's build-in touch support)
* Works across all platforms (where Flash Player or AIR run of course) in exactly same way
* Extendable. You can write your own application-specific gestures
* Open-source and free



h3. Getting Started

All gestures dispatch (if you listen to!) GestureEvent with the next types:
GestureEvent.GESTURE_STATE_CHANGE
GestureEvent.GESTURE_IDLE
GestureEvent.GESTURE_POSSIBLE
GestureEvent.GESTURE_FAILED

Discrete gestures also dispatch:
GestureEvent.GESTURE_RECOGNIZED

Continuous gestures also dispatch:
GestureEvent.GESTURE_BEGAN
GestureEvent.GESTURE_CHANGED
GestureEvent.GESTURE_ENDED

If you use a good IDE (such as IntelliJ IDEA, FDT, FlashDevelop, Flash Builder) you should see these events in autocompletion.

Quick start:
<pre><code>var doubleTap:TapGesture = new TapGesture(myButton);
doubleTap.numTapsRequired = 2;
doubleTap.addEventListener(GestureEvent.GESTURE_RECOGNIZED, onDoubleTap);
...
private function onDoubleTap(event:GestureEvent):void
{
	// handle double tap!
}
</code></pre>
or
<pre><code>var freeTransform:TransformGesture = new TransformGesture(myImage);
freeTransform.addEventListener(GestureEvent.GESTURE_BEGAN, onFreeTransform);
freeTransform.addEventListener(GestureEvent.GESTURE_CHANGED, onFreeTransform);
...
private function onFreeTransform(event:GestureEvent):void
{
	// move, rotate, scale — all at once for better performance!
	trace(freeTransform.offsetX, freeTransform.offsetY, freeTransform.rotation, freeTransform.scale);
}
</code></pre>

* Check the "Gestouch Examples":http://github.com/fljot/GestouchExamples project for a quick jump-in
* *+Highly recommended+* to watch videos from Apple WWDC conferences as they explain all the concepts and show more or less real-life examples. @see links below
* "Introduction video":http://www.youtube.com/watch?v=NjkmB8rfQjY - my first video, currently outdated
* TODO: wiki



h3. Advanced usage: Starling, ...

Recent changes made it possible to work with "Starling":http://www.starling-framework.org display list objects as well as any other display list hierarchical structures, e.g. other Stage3D frameworks that have display objects hierarchy like "ND2D":https://github.com/nulldesign/nd2d or even 3D libraries.
In order to use Gestouch with Starling all you need to do is a bit of bootstrapping:
<pre><code>starling = new Starling(MyStarlingRootClass, stage);
/* setup & start your Starling instance here */

// Gestouch initialization step 1 of 3:
// Initialize native (default) input adapter. Needed for non-DisplayList usage.
Gestouch.inputAdapter ||= new NativeInputAdapter(stage);

// Gestouch initialization step 2 of 3:
// Register instance of StarlingDisplayListAdapter to be used for objects of type starling.display.DisplayObject.
// What it does: helps to build hierarchy (chain of parents) for any Starling display object and
// acts as a adapter for gesture target to provide strong-typed access to methods like globalToLocal() and contains().
Gestouch.addDisplayListAdapter(starling.display.DisplayObject, new StarlingDisplayListAdapter());

// Gestouch initialization step 3 of 3:
// Initialize and register StarlingTouchHitTester.
// What it does: finds appropriate target for the new touches (uses Starling Stage#hitTest() method)
// What does "-1" mean: priority for this hit-tester. Since Stage3D layer sits behind native DisplayList
// we give it lower priority in the sense of interactivity.
Gestouch.addTouchHitTester(new StarlingTouchHitTester(starling), -1);
// NB! Use Gestouch#removeTouchHitTester() method if you manage multiple Starling instances during
// your application lifetime.
</code></pre>

Now you can register gestures as usual:
<pre><code>var tap:TapGesture = new TapGesture(starlingSprite);</code></pre>



h3. Roadmap, TODOs

* "Massive gestures" & Clusters. For bigger form-factor multitouch usage, when gestures must be a bit less about separate fingers but rather touch clusters (massive multitouch) 
* -Simulator (for testing multitouch gestures without special devices)- With new architecture it must be relatively easy to create SimulatorInputAdapter
* Chained gestures concept? To transfer touches from one gesture to another. Example: press/hold for circular menu, then drag it around.
* 3-fingers (3D) gestures (two fingers still, one moving)



h3. News

* "Follow me on Twitter":http://twitter.com/fljot for latest updates
* Don't forget about "issues":https://github.com/fljot/Gestouch/issues section as a good platform for discussions.



h3. Contribution, Donations

Contribute, share. Found it useful, nothing to add? Hire me for some project.



h3. Links

* "Gestouch Examples":http://github.com/fljot/GestouchExamples

* "Apple WWDC 2011: Making the Most of Multi-Touch on iOS":https://developer.apple.com/videos/wwdc/2011/?id=118
* "Apple WWDC 2010: Simplifying Touch Event Handling with Gesture Recognizers":https://developer.apple.com/videos/wwdc/2010/?id=120
* "Apple WWDC 2010: Advanced Gesture Recognition":https://developer.apple.com/videos/wwdc/2010/?id=121
* "Event Handling Guide for iOS":https://developer.apple.com/library/ios/documentation/EventHandling/Conceptual/EventHandlingiPhoneOS/
* "UIGestureRecognizer Class Reference":https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIGestureRecognizer_Class/

* "TUIO":http://www.tuio.org


h2. License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
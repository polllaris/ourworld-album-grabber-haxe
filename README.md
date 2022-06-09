# ourWorld Album Grabber (haxe)

## A haxe application that will read the games cache directory and move downloaded album photos to a temporary directory where you can then save them.

### Goal
The goal of this script is to get back any photos that were loaded in the past with the game client and give players the chance to get back photos that they may not have saved prior to the game shutting down, due to adobe air downloading all album photos for caching and not just a single persons: that means if one person didn't load their album then someone else may have and the photos may be recoverable through the computer of that other person.

# Simple Usage
This has been compiled for the C++ windows target and has an icon added with resource hacker which can be found on the releases page.
Simply download the windows release and run albumgrab.exe.

# Simple Compilation

In order to build for the C++ target you will need the respective C++ tools installed which will not be documented here,
building will result in making an executable that will use the neko interpreter installed on your system to run it and if
the appropriate tools for compiling to C++ aren't installed then it will fail and you will still have a neko executable built.

```
haxelib install build.hxml
haxe build.hxml
```

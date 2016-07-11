Prerequisites:

Please install cocoapods from: https://cocoapods.org/

Dependencies:

Please see Podfile for 3rd party libraries being used.


Building:

From the command line (Terminal) run the following command:

	pod install
	
Then open the generated file 'FlickeringLights.xcworkspace' using Xcode


Notes:

Extra Feature - 'Ambilight' (TM) Philips
The App does a very simple color analysis to determine the average color of the displayed image.
The average color is then used for the background of the picture, but also for Bluetooth Light (BLE) connected LED.
Tested with 'Smart LED Bulb' and 'Magic Blue LED'.



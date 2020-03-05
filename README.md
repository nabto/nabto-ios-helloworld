# Nabto iOS Hello World App

Swift based app that demonstrates how to use the Nabto Client SDK to do P2P RPC invocations and establish tunnels.

First, if you have not installed Cocoapods, do so: `sudo gem install cocoapods`

Next, run `pod install`.

Open `NabtoHelloWorld.xcworkspace` and run the app.

## Notes

To keep the app simple, device ids are hard coded in the source code to public Nabto demos. Also, there is no device pairing - meaning that the target device must have access control disabled. 

You can replace the hard coded device ids with ids of your own devices, obtained through the [Nabto Cloud Console](https://console.cloud.nabto.com). As device applications to run on your own, use the Nabto [weather station demo](https://github.com/nabto/unabto/tree/master/apps/weather_station) and the [device tunnel application](https://github.com/nabto/unabto/tree/master/apps/tunnel). They both support disabled access control and can be used as-is with this demo.

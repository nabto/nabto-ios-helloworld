# Nabto iOS Hello World App

Swift based app that demonstrates how to use the Nabto Client SDK to do P2P RPC invocations and establish tunnels.

The project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `NabtoHelloWorld/project.yml`. The Nabto Client SDK is pulled in as a Swift Package Manager dependency.

First, if you have not installed XcodeGen, do so: `brew install xcodegen`

Next, generate the Xcode project:

```
cd NabtoHelloWorld && xcodegen
```

Open `NabtoHelloWorld/NabtoHelloWorld.xcodeproj` and run the app. Xcode resolves the SPM dependencies on first open.

## Building from the command line

To build for an iOS Simulator (e.g. iPhone 16) without code signing:

```
cd NabtoHelloWorld
xcodebuild \
  -project NabtoHelloWorld.xcodeproj \
  -scheme NabtoHelloWorld \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

To build for a physical device (requires a valid signing team configured in `project.yml`):

```
cd NabtoHelloWorld
xcodebuild \
  -project NabtoHelloWorld.xcodeproj \
  -scheme NabtoHelloWorld \
  -destination 'generic/platform=iOS' \
  build
```

To resolve SPM dependencies without building:

```
xcodebuild -project NabtoHelloWorld.xcodeproj -resolvePackageDependencies
```

List available simulator destinations with `xcrun simctl list devices available`. Note that the `NabtoAPI.xcframework` shipped by the SPM package only contains an `arm64` simulator slice, so building for an `x86_64` (Intel Mac) simulator is not supported — use an Apple Silicon Mac or a physical device.

## Notes

To keep the app simple, device ids are hard coded in the source code to public Nabto demos. Also, there is no device pairing - meaning that the target device must have access control disabled. 

You can replace the hard coded device ids with ids of your own devices, obtained through the [Nabto Cloud Console](https://console.cloud.nabto.com). As device applications to run on your own, use the Nabto [weather station demo](https://github.com/nabto/unabto/tree/master/apps/weather_station) and the [device tunnel application](https://github.com/nabto/unabto/tree/master/apps/tunnel). They both support disabled access control and can be used as-is with this demo.

For production, of course access control must be enabled - read more about access control in [this article](https://www.nabto.com/pairing-and-access-control-part-1-intro-and-device/). For a more advanced demo that includes full access control, see the [Nabto Heat Control](https://github.com/nabto/ios-starter-nabto) demo.

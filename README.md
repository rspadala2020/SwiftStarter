# SwiftStarter

A small SwiftUI task-list app for iPhone and iPad, targeting iOS 17.6 or later.

## Features

- Add tasks; blank titles are ignored and surrounding whitespace is trimmed.
- Tap a task to mark it complete or incomplete.
- Swipe to delete, or use the Edit button.
- Keep tasks between launches using Codable and UserDefaults.
- Support Dynamic Type, VoiceOver, and the system's light and dark appearance.

## Run

Open `SwiftStarter.xcodeproj` in Xcode 26.5 or later, select the SwiftStarter
scheme and an iOS simulator, then press Cmd+R. There are no external dependencies.
To run on a physical device, select your development team under Signing & Capabilities
and choose a unique bundle identifier.

From this directory, build without a signing account:

```sh
xcodebuild -project SwiftStarter.xcodeproj -scheme SwiftStarter \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /tmp/SwiftStarterDerivedData CODE_SIGNING_ALLOWED=NO build
```

## Code structure

- `SwiftStarterApp.swift`: app entry point and ownership of shared state.
- `TaskStore.swift`: observable state, task mutations, and local persistence.
- `ContentView.swift`: list, task composer, and accessible task rows.

This is a learning sample: storage stays on the device and does not sync to a server.
There is no automated test target. To check behavior, add a task, mark it complete,
relaunch the app to confirm it persists, then delete it and relaunch again.

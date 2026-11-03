# SimpleAE — Simplified After Effects-like iOS Editor

A minimal SwiftUI animation editor for iOS: layers, timeline, keyframes, easing curves,
and live preview. Built to be compiled via GitHub Actions (macOS runner) into an IPA.

## Features
- Layer types: Rectangle, Circle, Text, Solid, Null, Adjustment, Camera, Light, Shape
- 2D/3D toggle (posX/Y/Z, rotX/Y/Z, scale, opacity)
- Timeline with playhead and per-layer keyframes
- Effects list per layer (Gaussian Blur, Color Correction, Drop Shadow, Glow)
- Easing: Linear, Ease In, Ease Out, Ease In/Out, Bezier (cubic)
- Visibility toggle, solid size, layer selection, parenting
- Play/pause preview
- Export current frame as PNG (share sheet)

## Build IPA (GitHub Actions)
1. Create a new GitHub repository and push this folder.
2. Go to Actions tab → "Build iOS IPA" → Run workflow.
3. Download the `SimpleAE-ipa` artifact (SimpleAE.ipa).

The IPA is unsigned (CODE_SIGNING_ALLOWED=NO). Sideload it with AltStore,
Sideloadly, or a jailbreak tool. For App Store / signed distribution, add your
Apple Developer signing credentials to the workflow.

## Build locally (macOS + Xcode)
1. Install XcodeGen: `brew install xcodegen`
2. `xcodegen generate`
3. Open `SimpleAE.xcodeproj` in Xcode and Run on a simulator/device.

## Notes
This is a teaching/simplified editor, not a full After Effects clone.

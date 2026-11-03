import SwiftUI

struct ContentView: View {
    @StateObject private var vm = ProjectViewModel()

    var body: some View {
        GeometryReader { geo in
            if geo.size.width > geo.size.height {
                // landscape: canvas left, inspector right, timeline bottom
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        CanvasView(vm: vm)
                        PropertyInspectorView(vm: vm)
                            .frame(width: 220)
                    }
                    TimelineView(vm: vm)
                        .frame(height: 180)
                }
            } else {
                // portrait: canvas top, timeline, inspector
                VStack(spacing: 0) {
                    CanvasView(vm: vm)
                        .frame(height: geo.size.height * 0.45)
                    TimelineView(vm: vm)
                        .frame(height: 200)
                    PropertyInspectorView(vm: vm)
                }
            }
        }
        .ignoresSafeArea()
    }
}

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ExportButton: View {
    @ObservedObject var vm: ProjectViewModel
    @State private var showShare = false
    @State private var shareItems: [Any] = []

    var body: some View {
        Button(action: { renderAndShare() }) {
            Label("Export PNG", systemImage: "square.and.arrow.up")
                .font(.caption)
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: shareItems)
        }
    }

    func renderAndShare() {
        let renderer = ImageRenderer(content: CanvasView(vm: vm).frame(width: 1080, height: 1920))
        renderer.scale = 2.0
        if let uiImage = renderer.uiImage {
            shareItems = [uiImage]
            showShare = true
        }
    }
}

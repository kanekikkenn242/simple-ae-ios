import SwiftUI

struct TimelineView: View {
    @ObservedObject var vm: ProjectViewModel

    var body: some View {
        VStack(spacing: 0) {
            // header with play controls
            HStack {
                Button(action: { vm.togglePlay() }) {
                    Image(systemName: vm.isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                }
                Text(String(format: "%.2fs", vm.currentTime))
                    .foregroundColor(.white)
                    .font(.caption)
                Spacer()
                Button(action: { vm.addKeyframe() }) {
                    Label("Add Key", systemImage: "diamond.fill")
                        .font(.caption)
                }
                .buttonStyle(.borderedProminent)
                ExportButton(vm: vm)
            }
            .padding(8)
            .background(Color(white: 0.15))

            // time ruler
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color(white: 0.12))
                    // ticks
                    ForEach(0..<Int(vm.project.duration) + 1, id: \.self) { s in
                        let x = CGFloat(Double(s) / vm.project.duration) * geo.size.width
                        VStack {
                            Text("\(s)").font(.system(size: 8)).foregroundColor(.gray)
                            Rectangle().fill(Color.gray).frame(width: 1, height: 6)
                        }
                        .position(x: x, y: 8)
                    }
                    // playhead
                    let px = CGFloat(vm.currentTime / vm.project.duration) * geo.size.width
                    Rectangle().fill(Color.yellow).frame(width: 2, height: geo.size.height)
                        .position(x: px, y: geo.size.height / 2)
                }
                .gesture(DragGesture().onChanged { v in
                    let t = Double(v.location.x / geo.size.width) * vm.project.duration
                    vm.seek(t)
                })
            }
            .frame(height: 24)

            // layers
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(vm.project.layers) { layer in
                        LayerRowView(layer: layer, vm: vm)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .background(Color(white: 0.1))
    }
}

struct LayerRowView: View {
    let layer: Layer
    @ObservedObject var vm: ProjectViewModel

    var body: some View {
        HStack(spacing: 0) {
            // layer icon + name
            HStack(spacing: 4) {
                Image(systemName: layer.type.icon).font(.caption2).foregroundColor(layer.color.color)
                Text(layer.name).font(.caption).foregroundColor(.white).lineLimit(1)
            }
            .frame(width: 110, alignment: .leading)
            .padding(.leading, 6)
            .onTapGesture { vm.selectLayer(layer) }
            // track area
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color(white: 0.18))
                    // keyframes for selected property
                    if let tr = layer.tracks.first(where: { $0.property == vm.selectedProperty }) {
                        ForEach(tr.keyframes) { kf in
                            let x = CGFloat(kf.time / vm.project.duration) * geo.size.width
                            Image(systemName: "diamond.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 10))
                                .position(x: x, y: geo.size.height / 2)
                                .onTapGesture { vm.deleteKeyframe(track: vm.selectedProperty, at: kf.time) }
                        }
                    }
                }
            }
        }
        .frame(height: 26)
        .background(vm.selectedLayerId == layer.id ? Color(white: 0.25) : Color.clear)
    }
}

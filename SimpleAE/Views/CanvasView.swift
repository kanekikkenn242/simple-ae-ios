import SwiftUI

struct CanvasView: View {
    @ObservedObject var vm: ProjectViewModel

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                // grid
                Canvas { ctx, size in
                    let step: CGFloat = 40
                    var x: CGFloat = 0
                    while x <= size.width {
                        var p = Path()
                        p.move(to: CGPoint(x: x, y: 0))
                        p.addLine(to: CGPoint(x: x, y: size.height))
                        ctx.stroke(p, with: .color(Color.white.opacity(0.06)), lineWidth: 1)
                        x += step
                    }
                    var y: CGFloat = 0
                    while y <= size.height {
                        var p = Path()
                        p.move(to: CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: size.width, y: y))
                        ctx.stroke(p, with: .color(Color.white.opacity(0.06)), lineWidth: 1)
                        y += step
                    }
                }
                ForEach(vm.project.layers) { layer in
                    if layer.visible && layer.type.isVisual {
                        let baseX = layer.value(of: "posX", at: vm.currentTime)
                        let baseY = layer.value(of: "posY", at: vm.currentTime)
                        let (px, py) = parentOffset(layer: layer, vm: vm)
                        let cx = baseX + px
                        let cy = baseY + py
                        let sc = layer.value(of: "scale", at: vm.currentTime)
                        let rot = layer.threeD ? layer.value(of: "rotZ", at: vm.currentTime) : layer.value(of: "rotation", at: vm.currentTime)
                        let op = layer.value(of: "opacity", at: vm.currentTime)
                        layerView(layer: layer)
                            .scaleEffect(sc)
                            .rotationEffect(.radians(rot))
                            .opacity(op)
                            .position(x: geo.size.width / 2 + CGFloat(cx),
                                     y: geo.size.height / 2 + CGFloat(cy))
                            .onTapGesture { vm.selectLayer(layer) }
                            .overlay(
                                vm.selectedLayerId == layer.id ?
                                RoundedRectangle(cornerRadius: 4).stroke(Color.yellow, lineWidth: 2).padding(-4) : nil
                            )
                    } else if layer.visible && !layer.type.isVisual {
                        // null/camera/light/adjustment indicator
                        let baseX = layer.value(of: "posX", at: vm.currentTime)
                        let baseY = layer.value(of: "posY", at: vm.currentTime)
                        let (px, py) = parentOffset(layer: layer, vm: vm)
                        let cx = baseX + px
                        let cy = baseY + py
                        Image(systemName: layer.type.icon)
                            .foregroundColor(layer.color.color)
                            .position(x: geo.size.width / 2 + CGFloat(cx),
                                     y: geo.size.height / 2 + CGFloat(cy))
                            .onTapGesture { vm.selectLayer(layer) }
                    }
                }
            }
        }
    }

    // helper
    func parentOffset(layer: Layer, vm: ProjectViewModel) -> (Double, Double) {
        guard let pid = layer.parentId,
              let parent = vm.project.layers.first(where: { $0.id == pid }) else {
            return (0, 0)
        }
        let px = parent.value(of: "posX", at: vm.currentTime)
        let py = parent.value(of: "posY", at: vm.currentTime)
        // recursive
        let (gpx, gpy) = parentOffset(layer: parent, vm: vm)
        return (px + gpx, py + gpy)
    }

    @ViewBuilder
    func layerView(layer: Layer) -> some View {
        switch layer.type {
        case .rectangle, .shape:
            Rectangle()
                .fill(layer.color.color)
                .frame(width: 80, height: 60)
        case .solid:
            Rectangle()
                .fill(layer.color.color)
                .frame(width: CGFloat(layer.solidWidth), height: CGFloat(layer.solidHeight))
        case .circle:
            Circle()
                .fill(layer.color.color)
                .frame(width: 70, height: 70)
        case .text:
            Text(layer.name)
                .foregroundColor(layer.color.color)
                .font(.title2)
        case .null, .adjustment, .camera, .light:
            EmptyView()
        }
    }
}

import SwiftUI

struct PropertyInspectorView: View {
    @ObservedObject var vm: ProjectViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Layers & Properties").font(.headline).foregroundColor(.white)

            // Layer list with type icon
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(vm.project.layers) { layer in
                        HStack {
                            Image(systemName: layer.type.icon).foregroundColor(layer.color.color)
                            Text(layer.name).font(.caption).foregroundColor(.white)
                            Spacer()
                            Button(action: { vm.toggleVisibility(layer.id) }) {
                                Image(systemName: layer.visible ? "eye" : "eye.slash")
                                    .font(.caption)
                            }
                        }
                        .padding(6)
                        .background(vm.selectedLayerId == layer.id ? Color(white: 0.25) : Color(white: 0.15))
                        .cornerRadius(6)
                        .onTapGesture { vm.selectLayer(layer) }
                    }
                }
            }
            .frame(height: 140)

            if let layer = vm.selectedLayer {
                Divider().background(Color.gray)
                Text(layer.name).font(.subheadline).foregroundColor(.gray)

                // Layer type picker
                Picker("Type", selection: Binding(
                    get: { layer.type },
                    set: { newType in
                        if let li = vm.selectedLayerIndex {
                            var l = vm.project.layers[li]
                            l.type = newType
                            vm.project.layers[li] = l
                        }
                    })) {
                    ForEach(LayerType.allCases) { t in
                        Label(t.label, systemImage: t.icon).tag(t)
                    }
                }
                .pickerStyle(.menu)

                // 3D toggle
                Toggle("3D Layer", isOn: Binding(
                    get: { layer.threeD },
                    set: { _ in vm.toggle3D() }
                ))
                .foregroundColor(.white)

                // Parent picker
                Picker("Parent", selection: Binding(
                    get: { layer.parentId },
                    set: { new in
                        if let li = vm.selectedLayerIndex {
                            vm.project.layers[li].parentId = new
                        }
                    })) {
                    Text("None").tag(UUID?.none)
                    ForEach(vm.project.layers.filter { $0.id != layer.id }) { p in
                        Text(p.name).tag(Optional(p.id))
                    }
                }
                .pickerStyle(.menu)

                // Property picker
                Picker("Property", selection: $vm.selectedProperty) {
                    ForEach(vm.availableProperties, id: \.self) { p in
                        Text(p).tag(p)
                    }
                }
                .pickerStyle(.menu)

                let v = layer.value(of: vm.selectedProperty, at: vm.currentTime)
                Text(String(format: "Value: %.3f", v)).foregroundColor(.white).font(.caption)

                // Solid size
                if layer.type == .solid {
                    HStack {
                        Text("W").foregroundColor(.gray).font(.caption)
                        Slider(value: Binding(get: { layer.solidWidth }, set: { new in
                            if let li = vm.selectedLayerIndex { vm.project.layers[li].solidWidth = new }
                        }), in: 10...500)
                    }
                    HStack {
                        Text("H").foregroundColor(.gray).font(.caption)
                        Slider(value: Binding(get: { layer.solidHeight }, set: { new in
                            if let li = vm.selectedLayerIndex { vm.project.layers[li].solidHeight = new }
                        }), in: 10...500)
                    }
                }

                // Effects
                DisclosureGroup("Effects (\(layer.effects.count))", isExpanded: $vm.showEffects) {
                    ForEach(layer.effects) { eff in
                        HStack {
                            Text(eff.name).font(.caption).foregroundColor(.white)
                            Spacer()
                            Button(action: { vm.removeEffect(eff.id) }) {
                                Image(systemName: "trash").font(.caption)
                            }
                        }
                    }
                    Menu("Add Effect") {
                        Button("Gaussian Blur") { vm.addEffect("Gaussian Blur") }
                        Button("Color Correction") { vm.addEffect("Color Correction") }
                        Button("Drop Shadow") { vm.addEffect("Drop Shadow") }
                        Button("Glow") { vm.addEffect("Glow") }
                    }
                    .font(.caption)
                }
                .foregroundColor(.white)

                // Buttons
                Menu("Add Layer") {
                    ForEach(LayerType.allCases) { t in
                        Button { vm.addLayer(type: t) } label: {
                            Label(t.label, systemImage: t.icon)
                        }
                    }
                }
                .buttonStyle(.bordered)
                Button("Delete") { vm.deleteSelectedLayer() }
                    .buttonStyle(.bordered)

                Button("Add Key") { vm.addKeyframe() }
                    .buttonStyle(.borderedProminent)
            } else {
                Text("No layer selected").foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color(white: 0.12))
    }
}

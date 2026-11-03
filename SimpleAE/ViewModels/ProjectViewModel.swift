import SwiftUI
import Combine

class ProjectViewModel: ObservableObject {
    @Published var project: Project = .empty()
    @Published var currentTime: Double = 0
    @Published var isPlaying: Bool = false
    @Published var selectedLayerId: UUID?
    @Published var selectedProperty: String = "posX"
    @Published var showEffects: Bool = false

    private var timer: Timer?
    private var lastTick: Date?

    var selectedLayer: Layer? {
        guard let id = selectedLayerId else { return project.layers.first }
        return project.layers.first { $0.id == id }
    }

    var selectedLayerIndex: Int? {
        guard let id = selectedLayerId else { return project.layers.isEmpty ? nil : 0 }
        return project.layers.firstIndex { $0.id == id }
    }

    var availableProperties: [String] {
        selectedLayer?.properties ?? Layer.defaultProperties2D
    }

    func selectLayer(_ layer: Layer) { selectedLayerId = layer.id }

    func addLayer(type: LayerType, threeD: Bool = false) {
        let colors: [CodableColor] = [.blue, .red, .green, .yellow, .white]
        let c = colors[project.layers.count % colors.count]
        let name = "\(type.label) \(project.layers.count + 1)"
        project.layers.append(Layer(name: name, type: type, color: c, threeD: threeD))
    }

    func deleteSelectedLayer() {
        guard let idx = selectedLayerIndex else { return }
        project.layers.remove(at: idx)
        selectedLayerId = project.layers.first?.id
    }

    func toggleVisibility(_ id: UUID) {
        if let idx = project.layers.firstIndex(where: { $0.id == id }) {
            project.layers[idx].visible.toggle()
        }
    }

    func toggle3D() {
        guard let li = selectedLayerIndex else { return }
        var layer = project.layers[li]
        layer.threeD = !layer.threeD
        let props = layer.threeD ? Layer.defaultProperties3D : Layer.defaultProperties2D
        // rebuild tracks preserving existing keyframes for common props
        var newTracks: [AnimationTrack] = []
        for p in props {
            if let existing = layer.tracks.first(where: { $0.property == p }) {
                newTracks.append(existing)
            } else {
                newTracks.append(AnimationTrack(property: p))
            }
        }
        layer.tracks = newTracks
        project.layers[li] = layer
        if !props.contains(selectedProperty) { selectedProperty = props.first ?? "posX" }
    }

    func addEffect(_ name: String) {
        guard let li = selectedLayerIndex else { return }
        var layer = project.layers[li]
        layer.effects.append(EffectInstance(name: name))
        project.layers[li] = layer
    }

    func removeEffect(_ id: UUID) {
        guard let li = selectedLayerIndex else { return }
        var layer = project.layers[li]
        layer.effects.removeAll { $0.id == id }
        project.layers[li] = layer
    }

    func addKeyframe() {
        guard let li = selectedLayerIndex else { return }
        let prop = selectedProperty
        let t = currentTime
        let current = project.layers[li].value(of: prop, at: t)
        var layer = project.layers[li]
        if let ti = layer.tracks.firstIndex(where: { $0.property == prop }) {
            layer.tracks[ti].keyframes.removeAll { abs($0.time - t) < 0.001 }
            layer.tracks[ti].keyframes.append(Keyframe(time: t, value: current))
            layer.tracks[ti].keyframes.sort { $0.time < $1.time }
        }
        project.layers[li] = layer
    }

    func deleteKeyframe(track: String, at time: Double) {
        guard let li = selectedLayerIndex else { return }
        var layer = project.layers[li]
        if let ti = layer.tracks.firstIndex(where: { $0.property == track }) {
            layer.tracks[ti].keyframes.removeAll { abs($0.time - time) < 0.001 }
        }
        project.layers[li] = layer
    }

    func play() {
        isPlaying = true
        lastTick = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    func pause() { isPlaying = false; timer?.invalidate(); timer = nil }
    func togglePlay() { isPlaying ? pause() : play() }

    func tick() {
        guard let last = lastTick else { lastTick = Date(); return }
        let now = Date()
        let dt = now.timeIntervalSince(last)
        lastTick = now
        var nt = currentTime + dt
        if nt > project.duration { nt = 0 }
        currentTime = nt
    }

    func seek(_ t: Double) {
        currentTime = min(max(t, 0), project.duration)
    }

    deinit { timer?.invalidate() }
}

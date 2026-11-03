import SwiftUI

enum LayerType: String, Codable, CaseIterable, Identifiable {
    case rectangle, circle, text, solid, null, adjustment, camera, light, shape
    var id: String { rawValue }
    var label: String {
        switch self {
        case .rectangle: return "Rectangle"
        case .circle: return "Circle"
        case .text: return "Text"
        case .solid: return "Solid"
        case .null: return "Null"
        case .adjustment: return "Adjustment"
        case .camera: return "Camera"
        case .light: return "Light"
        case .shape: return "Shape"
        }
    }
    var icon: String {
        switch self {
        case .rectangle: return "rectangle"
        case .circle: return "circle"
        case .text: return "textformat"
        case .solid: return "square.fill"
        case .null: return "xmark"
        case .adjustment: return "wand.and.stars"
        case .camera: return "camera"
        case .light: return "lightbulb"
        case .shape: return "pentagon"
        }
    }
    var isVisual: Bool {
        switch self {
        case .null, .camera, .light, .adjustment: return false
        default: return true
        }
    }
}

struct CodableColor: Codable, Equatable {
    var r: Double, g: Double, b: Double, a: Double
    var color: Color { Color(red: r, green: g, blue: b, opacity: a) }
    static let white = CodableColor(r: 1, g: 1, b: 1, a: 1)
    static let blue = CodableColor(r: 0.2, g: 0.5, b: 1.0, a: 1)
    static let red = CodableColor(r: 1, g: 0.3, b: 0.3, a: 1)
    static let green = CodableColor(r: 0.3, g: 0.8, b: 0.4, a: 1)
    static let black = CodableColor(r: 0, g: 0, b: 0, a: 1)
    static let yellow = CodableColor(r: 1, g: 0.9, b: 0.2, a: 1)
}

enum EasingType: String, Codable, CaseIterable, Identifiable {
    case linear, easeIn, easeOut, easeInOut, bezier
    var id: String { rawValue }
    var label: String {
        switch self {
        case .linear: return "Linear"
        case .easeIn: return "Ease In"
        case .easeOut: return "Ease Out"
        case .easeInOut: return "Ease In/Out"
        case .bezier: return "Bezier"
        }
    }
}

struct Keyframe: Identifiable, Codable, Equatable {
    let id: UUID
    var time: Double
    var value: Double
    var easing: EasingType
    var cx1: Double = 0.42
    var cy1: Double = 0.0
    var cx2: Double = 0.58
    var cy2: Double = 1.0
    init(time: Double, value: Double, easing: EasingType = .easeInOut) {
        self.id = UUID()
        self.time = time
        self.value = value
        self.easing = easing
    }
}

struct AnimationTrack: Identifiable, Codable, Equatable {
    let id: UUID
    var property: String
    var keyframes: [Keyframe]
    init(property: String, keyframes: [Keyframe] = []) {
        self.id = UUID()
        self.property = property
        self.keyframes = keyframes
    }
}

struct EffectInstance: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var enabled: Bool = true
    init(name: String) { self.id = UUID(); self.name = name }
}

struct Layer: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var type: LayerType
    var color: CodableColor
    var tracks: [AnimationTrack]
    var visible: Bool = true
    var locked: Bool = false
    var threeD: Bool = false
    var effects: [EffectInstance] = []
    var parentId: UUID? = nil
    var solidWidth: Double = 200
    var solidHeight: Double = 100

    static let defaultProperties2D = ["posX", "posY", "scale", "rotation", "opacity"]
    static let defaultProperties3D = ["posX", "posY", "posZ", "scale", "rotX", "rotY", "rotZ", "opacity"]

    init(name: String, type: LayerType, color: CodableColor = .blue, threeD: Bool = false) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.color = color
        self.threeD = threeD
        let props = threeD ? Layer.defaultProperties3D : Layer.defaultProperties2D
        self.tracks = props.map { AnimationTrack(property: $0) }
    }

    var properties: [String] { threeD ? Layer.defaultProperties3D : Layer.defaultProperties2D }

    func value(of property: String, at time: Double) -> Double {
        guard let track = tracks.first(where: { $0.property == property }) else { return defaultValue(property) }
        let ks = track.keyframes.sorted { $0.time < $1.time }
        if ks.isEmpty { return defaultValue(property) }
        if time <= ks.first!.time { return ks.first!.value }
        if time >= ks.last!.time { return ks.last!.value }
        for i in 0..<(ks.count - 1) {
            let a = ks[i], b = ks[i + 1]
            if time >= a.time && time <= b.time {
                let span = b.time - a.time
                let t = span > 0 ? (time - a.time) / span : 0
                let eased = applyEasing(t, type: a.easing, a: a, b: b)
                return a.value + (b.value - a.value) * eased
            }
        }
        return ks.last!.value
    }

    func defaultValue(_ property: String) -> Double {
        switch property {
        case "posX", "posY", "posZ", "rotX", "rotY", "rotZ": return 0
        case "scale": return 1
        case "opacity": return 1
        default: return 0
        }
    }
}

func applyEasing(_ t: Double, type: EasingType, a: Keyframe, b: Keyframe) -> Double {
    switch type {
    case .linear: return t
    case .easeIn: return t * t
    case .easeOut: return 1 - (1 - t) * (1 - t)
    case .easeInOut:
        return t < 0.5 ? 2 * t * t : 1 - pow(-2 * t + 2, 2) / 2
    case .bezier:
        return cubicBezier(t, x1: a.cx1, y1: a.cy1, x2: a.cx2, y2: a.cy2)
    }
}

func cubicBezier(_ t: Double, x1: Double, y1: Double, x2: Double, y2: Double) -> Double {
    let u = 1 - t
    let y = 3 * u * u * t * y1 + 3 * u * t * t * y2 + t * t * t
    return y
}

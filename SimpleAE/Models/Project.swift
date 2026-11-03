import SwiftUI

struct Project: Codable {
    var name: String
    var duration: Double
    var fps: Double
    var layers: [Layer]

    static func empty() -> Project {
        Project(name: "Untitled", duration: 5.0, fps: 30, layers: [
            Layer(name: "Rectangle 1", type: .rectangle, color: .blue),
            Layer(name: "Circle 1", type: .circle, color: .red),
            Layer(name: "Null 1", type: .null, color: .white),
            Layer(name: "Solid 1", type: .solid, color: .green),
            Layer(name: "Camera 1", type: .camera, color: .yellow)
        ])
    }
}

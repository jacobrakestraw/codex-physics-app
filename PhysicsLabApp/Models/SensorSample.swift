import Foundation

struct SensorSample: Identifiable, Hashable {
    let id = UUID()
    let timestamp: TimeInterval
    let value: Double
}

struct SensorSeries: Identifiable {
    let id = UUID()
    var label: String
    var samples: [SensorSample]

    init(label: String, samples: [SensorSample] = []) {
        self.label = label
        self.samples = samples
    }
}

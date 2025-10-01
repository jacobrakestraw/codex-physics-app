import Foundation
import Combine

protocol DataCollector: AnyObject {
    var dataSeries: [SensorSeries] { get }
    var isCollecting: Bool { get }
    func start()
    func stop()
    func reset()
}

final class AccelerometerMagnitudeCollector: DataCollector, ObservableObject {
    @Published private(set) var dataSeries: [SensorSeries]
    private(set) var isCollecting: Bool = false

    private let sensorManager: SensorManager
    private let samplingInterval: TimeInterval
    private var timer: Timer?
    private var startTime: Date?

    init(sensorManager: SensorManager, samplingInterval: TimeInterval) {
        self.sensorManager = sensorManager
        self.samplingInterval = samplingInterval
        self.dataSeries = [SensorSeries(label: "Acceleration Magnitude")]
    }

    func start() {
        guard !isCollecting else { return }
        isCollecting = true
        startTime = Date()
        sensorManager.startAccelerometerUpdates()
        timer = Timer.scheduledTimer(withTimeInterval: samplingInterval, repeats: true) { [weak self] _ in
            self?.sample()
        }
    }

    func stop() {
        guard isCollecting else { return }
        isCollecting = false
        timer?.invalidate()
        timer = nil
        sensorManager.stopAccelerometerUpdates()
    }

    func reset() {
        dataSeries = dataSeries.map { SensorSeries(label: $0.label) }
        startTime = nil
    }

    private func sample() {
        guard let magnitude = sensorManager.currentAccelerationMagnitude(),
              let startTime else { return }
        let elapsed = Date().timeIntervalSince(startTime)
        let sample = SensorSample(timestamp: elapsed, value: magnitude)
        dataSeries[0].samples.append(sample)
    }
}

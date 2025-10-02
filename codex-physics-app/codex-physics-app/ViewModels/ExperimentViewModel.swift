import Foundation
import Combine

// Refine ObservableObject to those using the standard ObservableObjectPublisher
private protocol DefaultObservableObject: ObservableObject where ObjectWillChangePublisher == ObservableObjectPublisher {}

@MainActor
final class ExperimentViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    enum Phase {
        case idle
        case running
        case completed
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var elapsedTime: TimeInterval = 0
    @Published private(set) var remainingTime: TimeInterval?
    @Published private(set) var dataSeries: [SensorSeries] = []

    private let experiment: any Experiment
    private let sensorManager: SensorManager
    private var dataCollector: DataCollector?
    private var timer: Timer?
    private var collectorCancellable: AnyCancellable?
    private var targetDuration: TimeInterval?
    private var startDate: Date?

    init(experiment: any Experiment, sensorManager: SensorManager = .shared) {
        self.experiment = experiment
        self.sensorManager = sensorManager
        configureCollector()
    }

    deinit {
        timer?.invalidate()
    }

    func start(runMode: ExperimentConfiguration.RunMode, customDuration: TimeInterval? = nil) {
        guard phase != .running else { return }
        configureCollector()
        dataCollector?.reset()
        dataCollector?.start()

        dataSeries = dataCollector?.dataSeries ?? []
        phase = .running
        elapsedTime = 0
        startDate = Date()

        switch runMode {
        case .stopwatch:
            remainingTime = nil
            targetDuration = nil
        case .timer:
            let duration = customDuration ?? experiment.configuration.defaultDuration
            targetDuration = duration
            remainingTime = duration
        }

        startTimer()
    }

    func stop() {
        guard phase == .running else { return }
        dataCollector?.stop()
        timer?.invalidate()
        timer = nil
        phase = .completed
        remainingTime = targetDuration.map { max(0, $0 - elapsedTime) }
    }

    func reset() {
        dataCollector?.stop()
        dataCollector?.reset()
        timer?.invalidate()
        timer = nil
        phase = .idle
        elapsedTime = 0
        remainingTime = targetDuration
    }

    func exportData() throws -> URL {
        let exporter = CSVExporter()
        return try exporter.export(series: dataSeries, fileName: experiment.title.replacingOccurrences(of: " ", with: "_"))
    }

    private func configureCollector() {
        dataCollector?.stop()
        collectorCancellable?.cancel()
        let collector = experiment.makeDataCollector(using: sensorManager)
        dataCollector = collector
        dataSeries = collector.dataSeries

        if let observableCollector = collector as? any DefaultObservableObject {
            collectorCancellable = observableCollector.objectWillChange
                .receive(on: RunLoop.main)
                .sink { [weak self] _ in
                    guard let self else { return }
                    self.dataSeries = collector.dataSeries
                    self.objectWillChange.send()
                }
        }
    }

    private func startTimer() {
        timer?.invalidate()
        let timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.updateTimers(referenceDate: Date())
        }
        self.timer = timer
        RunLoop.main.add(timer, forMode: .common)
    }

    private func updateTimers(referenceDate date: Date) {
        guard let startDate else { return }
        elapsedTime = date.timeIntervalSince(startDate)

        if let targetDuration {
            let remaining = max(0, targetDuration - elapsedTime)
            remainingTime = remaining
            if remaining <= 0 {
                stop()
            }
        }
    }
}


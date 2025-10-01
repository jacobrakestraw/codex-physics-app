import Foundation
import Combine

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
    private var timerCancellable: AnyCancellable?
    private var collectorCancellable: AnyCancellable?
    private var targetDuration: TimeInterval?
    private var startDate: Date?

    init(experiment: any Experiment, sensorManager: SensorManager = .shared) {
        self.experiment = experiment
        self.sensorManager = sensorManager
        configureCollector()
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
        timerCancellable?.cancel()
        timerCancellable = nil
        phase = .completed
        remainingTime = targetDuration.map { max(0, $0 - elapsedTime) }
    }

    func reset() {
        dataCollector?.stop()
        dataCollector?.reset()
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

        if let observableCollector = collector as? any ObservableObject {
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
        timerCancellable?.cancel()
        timerCancellable = Timer.publish(every: 0.05, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.updateTimers(referenceDate: date)
            }
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

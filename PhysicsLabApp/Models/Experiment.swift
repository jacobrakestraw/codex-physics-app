import Foundation
import CoreMotion

enum ExperimentCategory: String, CaseIterable, Identifiable {
    case motion = "Motion"
    case environment = "Environment"
    case time = "Time"

    var id: String { rawValue }
}

protocol Experiment: Identifiable {
    var id: UUID { get }
    var title: String { get }
    var summary: String { get }
    var category: ExperimentCategory { get }
    var configuration: ExperimentConfiguration { get }
    func makeDataCollector(using sensorManager: SensorManager) -> DataCollector
}

struct AnyExperiment: Experiment {
    let id: UUID
    let title: String
    let summary: String
    let category: ExperimentCategory
    let configuration: ExperimentConfiguration

    private let collectorFactory: (SensorManager) -> DataCollector

    init<E: Experiment>(_ experiment: E) {
        self.id = experiment.id
        self.title = experiment.title
        self.summary = experiment.summary
        self.category = experiment.category
        self.configuration = experiment.configuration
        self.collectorFactory = experiment.makeDataCollector
    }

    func makeDataCollector(using sensorManager: SensorManager) -> DataCollector {
        collectorFactory(sensorManager)
    }
}

struct ExperimentConfiguration {
    enum RunMode: String, CaseIterable, Identifiable {
        case stopwatch
        case timer

        var id: String { rawValue }
    }

    /// Default duration in seconds when using timer mode.
    var defaultDuration: TimeInterval
    var supportedRunModes: [RunMode]
    var samplingFrequency: TimeInterval
}

/// A concrete example experiment for reference and initial implementation.
struct AccelerometerMagnitudeExperiment: Experiment {
    let id = UUID()
    let title = "Accelerometer Magnitude"
    let summary = "Measure and record the magnitude of the device's acceleration vector."
    let category: ExperimentCategory = .motion

    let configuration = ExperimentConfiguration(
        defaultDuration: 30,
        supportedRunModes: [.stopwatch, .timer],
        samplingFrequency: 1.0 / 60.0
    )

    func makeDataCollector(using sensorManager: SensorManager) -> DataCollector {
        AccelerometerMagnitudeCollector(sensorManager: sensorManager, samplingInterval: configuration.samplingFrequency)
    }
}

/// Extend this to register additional built-in experiments.
struct ExperimentCatalog {
    let experiments: [AnyExperiment]

    init() {
        self.experiments = [
            AnyExperiment(AccelerometerMagnitudeExperiment())
        ]
    }
}

final class ExperimentStore: ObservableObject {
    @Published var catalog = ExperimentCatalog()
}

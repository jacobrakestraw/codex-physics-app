import SwiftUI

struct ExperimentDetailView: View {
    let experiment: any Experiment
    @StateObject private var viewModel: ExperimentViewModel
    @State private var runMode: ExperimentConfiguration.RunMode = .stopwatch
    @State private var timerDuration: Double = 30
    @State private var exportError: AlertItem?

    init(experiment: any Experiment) {
        self.experiment = experiment
        _viewModel = StateObject(wrappedValue: ExperimentViewModel(experiment: experiment))
        _runMode = State(initialValue: experiment.configuration.supportedRunModes.first ?? .stopwatch)
        _timerDuration = State(initialValue: experiment.configuration.defaultDuration)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(experiment.summary)
                    .font(.body)

                runConfigurationSection
                SensorChartView(series: viewModel.dataSeries)
                    .frame(minHeight: 240)
                    .padding(.vertical)
                RunControlsView(
                    phase: viewModel.phase,
                    runMode: runMode,
                    elapsedTime: viewModel.elapsedTime,
                    remainingTime: viewModel.remainingTime,
                    onStart: startExperiment,
                    onStop: viewModel.stop,
                    onReset: viewModel.reset
                )

                exportButton
            }
            .padding()
        }
        .navigationTitle(experiment.title)
        .alert(item: $exportError) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message ?? ""), dismissButton: .default(Text("OK")))
        }
    }

    private var runConfigurationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Run Configuration")
                .font(.headline)

            Picker("Mode", selection: $runMode) {
                ForEach(experiment.configuration.supportedRunModes) { mode in
                    Text(mode.rawValue.capitalized).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            if runMode == .timer {
                Stepper(value: $timerDuration, in: 5...600, step: 5) {
                    Text("Duration: \(Int(timerDuration)) seconds")
                }
            }
        }
    }

    private var exportButton: some View {
        Button(action: exportData) {
            Label("Export CSV", systemImage: "square.and.arrow.up")
        }
        .buttonStyle(.borderedProminent)
        .disabled(viewModel.dataSeries.allSatisfy { $0.samples.isEmpty })
    }

    private func startExperiment() {
        viewModel.start(runMode: runMode, customDuration: runMode == .timer ? timerDuration : nil)
    }

    private func exportData() {
        do {
            let url = try viewModel.exportData()
            exportError = AlertItem(title: "Data exported", message: "Saved to \(url.lastPathComponent)")
        } catch {
            exportError = AlertItem(title: "Export failed", message: error.localizedDescription)
        }
    }
}

private struct AlertItem: Identifiable {
    let id = UUID()
    let title: String
    let message: String?
}

struct ExperimentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExperimentDetailView(experiment: AccelerometerMagnitudeExperiment())
        }
    }
}

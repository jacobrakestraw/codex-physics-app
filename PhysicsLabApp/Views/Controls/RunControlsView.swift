import SwiftUI

struct RunControlsView: View {
    let phase: ExperimentViewModel.Phase
    let runMode: ExperimentConfiguration.RunMode
    let elapsedTime: TimeInterval
    let remainingTime: TimeInterval?
    let onStart: () -> Void
    let onStop: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mode: \(runMode.rawValue.capitalized)")
                .font(.caption)
                .foregroundColor(.secondary)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Elapsed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(elapsedTime.formattedTime)
                        .font(.title2)
                        .monospacedDigit()
                }

                Spacer()

                if let remainingTime {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(remainingTime.formattedTime)
                            .font(.title2)
                            .monospacedDigit()
                    }
                }
            }

            HStack(spacing: 16) {
                Button(action: onStart) {
                    Label(phase == .running ? "Running" : "Start", systemImage: "play.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(phase == .running)

                Button(action: onStop) {
                    Label("Stop", systemImage: "stop.fill")
                }
                .buttonStyle(.bordered)
                .disabled(phase != .running)

                Button(action: onReset) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                }
                .buttonStyle(.borderless)
                .disabled(phase == .idle)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private extension TimeInterval {
    var formattedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: self) ?? "0:00"
    }
}

struct RunControlsView_Previews: PreviewProvider {
    static var previews: some View {
        RunControlsView(
            phase: .idle,
            runMode: .stopwatch,
            elapsedTime: 65,
            remainingTime: 120,
            onStart: {},
            onStop: {},
            onReset: {}
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

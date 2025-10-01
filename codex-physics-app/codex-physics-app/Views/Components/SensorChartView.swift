import SwiftUI
import Charts

struct SensorChartView: View {
    let series: [SensorSeries]

    var body: some View {
        Chart {
            ForEach(series) { series in
                ForEach(series.samples) { sample in
                    LineMark(
                        x: .value("Time", sample.timestamp),
                        y: .value(series.label, sample.value)
                    )
                    .foregroundStyle(by: .value("Series", series.label))
                }
            }
        }
        .chartXAxisLabel("Time (s)")
        .chartYAxisLabel("Value")
        .overlay(alignment: .center) {
            if series.allSatisfy({ $0.samples.isEmpty }) {
                VStack(spacing: 8) {
                    Image(systemName: "waveform.path.ecg")
                        .imageScale(.large)
                        .foregroundColor(.secondary)
                    Text("No data yet")
                        .font(.headline)
                    Text("Start the experiment to begin collecting data.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(uiColor: .systemBackground).opacity(0.9))
                )
            }
        }
    }
}

struct SensorChartView_Previews: PreviewProvider {
    static var previews: some View {
        SensorChartView(series: [SensorSeries(label: "Magnitude", samples: [
            SensorSample(timestamp: 0, value: 0.1),
            SensorSample(timestamp: 1, value: 0.4),
            SensorSample(timestamp: 2, value: 0.2)
        ])])
        .frame(height: 240)
        .padding()
    }
}

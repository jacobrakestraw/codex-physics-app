import Foundation

struct CSVExporter {
    enum ExportError: Error {
        case encodingFailure
        case writeFailure
    }

    func export(series: [SensorSeries], fileName: String = "ExperimentData") throws -> URL {
        let header = "time,value,label\n"
        var rows: [String] = [header]

        for series in series {
            for sample in series.samples {
                rows.append("\(sample.timestamp),\(sample.value),\(series.label)\n")
            }
        }

        let csvString = rows.joined()
        guard let data = csvString.data(using: .utf8) else {
            throw ExportError.encodingFailure
        }

        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent("\(fileName).csv")

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            throw ExportError.writeFailure
        }
    }
}

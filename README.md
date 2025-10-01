# Physics Lab (SwiftUI)

A starter SwiftUI project for building a physics experiment app inspired by phyphox. The project scaffolds a modular architecture for defining experiments, collecting sensor data over time, displaying live charts, and exporting results to CSV.

## Project layout

```
PhysicsLabApp/
├─ Models/
│  ├─ Experiment.swift             # Experiment protocol, catalog, and sample experiment
│  └─ SensorSample.swift           # Reusable data structures for samples and series
├─ Services/
│  ├─ CSVExporter.swift           # Utility for exporting collected data to CSV
│  ├─ DataCollector.swift         # Base data collector protocol + accelerometer collector
│  └─ SensorManager.swift         # Shared wrapper around Core Motion APIs
├─ ViewModels/
│  └─ ExperimentViewModel.swift   # Coordinates run/timer logic and exposes collected data
└─ Views/
   ├─ Components/
   │  └─ SensorChartView.swift    # Live line chart using the Charts framework
   ├─ Controls/
   │  └─ RunControlsView.swift    # Start/stop/reset controls with stopwatch & timer display
   ├─ ExperimentDetailView.swift  # Experiment detail page with run configuration
   └─ ExperimentListView.swift    # Home screen listing available experiments
```

`PhysicsLabApp.swift` wires everything together with an `ExperimentStore` and initial navigation.

## Requirements

* Xcode 14 or later (for SwiftUI + Charts)
* iOS 16 target for the Charts framework (`import Charts`)
* Physical device recommended for accessing Core Motion sensors

## Getting started

1. Open the project folder in Xcode and create a new iOS App project (SwiftUI lifecycle).
2. Replace the generated files with the contents from this repository or integrate them into the new project.
3. Add the `Charts` framework and ensure the target has motion usage descriptions in `Info.plist` (e.g., `NSMotionUsageDescription`).
4. Build and run on a physical device to test accelerometer-based experiments.

## Extending the app

* Implement additional `Experiment` conforming types that return custom `DataCollector` implementations.
* Expand `SensorManager` to expose more sensors (gyroscope, magnetometer, barometer, microphone, etc.).
* Add persistence for saved runs and experiment templates.
* Integrate share sheets or Files app export using the URL returned by `CSVExporter`.

This scaffold is intentionally lightweight and focuses on establishing a consistent pattern for future experiments, reusable services, and SwiftUI views.

import SwiftUI

struct ExperimentListView: View {
    @EnvironmentObject private var store: ExperimentStore

    private var experimentsByCategory: [(ExperimentCategory, [AnyExperiment])] {
        ExperimentCategory.allCases.map { category in
            let experiments = store.catalog.experiments.filter { $0.category == category }
            return (category, experiments)
        }.filter { !$0.1.isEmpty }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(experimentsByCategory, id: \.0.id) { category, experiments in
                    Section(category.rawValue) {
                        ForEach(experiments) { experiment in
                            NavigationLink(destination: ExperimentDetailView(experiment: experiment)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(experiment.title)
                                        .font(.headline)
                                    Text(experiment.summary)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Physics Lab")
        }
    }
}

struct ExperimentListView_Previews: PreviewProvider {
    static var previews: some View {
        ExperimentListView()
            .environmentObject(ExperimentStore())
    }
}

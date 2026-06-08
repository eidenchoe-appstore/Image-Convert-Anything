import SwiftUI

struct ContentView: View {
    @ObservedObject var store: ConversionStore

    var body: some View {
        NavigationSplitView {
            InputSidebarView(store: store)
                .navigationSplitViewColumnWidth(min: 250, ideal: 310, max: 420)
        } detail: {
            VStack(spacing: 0) {
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 0) {
                        ConversionToolbarView(store: store)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)

                        Divider()

                        ConversionProgressView(store: store)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                    }
                }
                .frame(maxHeight: 245)

                Divider()

                TabView {
                    JobListView(jobs: store.jobs)
                        .tabItem {
                            Label("Jobs", systemImage: "list.bullet.rectangle")
                        }

                    LogListView(logs: store.logs, clearAction: store.clearLogs)
                        .tabItem {
                            Label("Log", systemImage: "text.alignleft")
                        }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
    }
}

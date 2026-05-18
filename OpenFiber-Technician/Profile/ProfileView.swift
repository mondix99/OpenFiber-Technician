import SwiftUI

struct ProfileView: View {

    @State private var isAvailable = true
    
    @EnvironmentObject var appVM: AppViewModel
    @ObservedObject var jobsVM: JobsViewModel

    var body: some View {
        List {

            // MARK: - Team Info
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(appVM.currentTeam?.name ?? "No Team")
                            .font(.headline)

                        Text("Fiber Installation Team")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }

            // MARK: - Work Status
            Section("Work Status") {
                Toggle("Available for Jobs", isOn: $isAvailable)
            }

            // MARK: - Statistics
            Section("Statistics") {
                ProfileStatRow(
                    title: "Completed Jobs",
                    value: "128"
                )

                ProfileStatRow(
                    title: "Active Jobs",
                    value: "\(jobsVM.filteredJobs.count)"
                )

                ProfileStatRow(
                    title: "Rating",
                    value: "4.8"
                )
            }

            // MARK: - Settings
            Section("Settings") {
                Toggle("Dark Mode", isOn: $appVM.isDarkMode)

                Label("Sync Data", systemImage: "arrow.triangle.2.circlepath")
            }

            // MARK: - Logout
            Section {
                Button {
                    appVM.currentTeam = nil
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Profile")
    }
}

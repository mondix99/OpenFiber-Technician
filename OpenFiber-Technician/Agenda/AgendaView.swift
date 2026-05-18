import SwiftUI

struct AgendaView: View {

    @ObservedObject var viewModel: JobsViewModel
    @State private var selectedDate = Date()

    var filteredJobs: [Job] {
        viewModel.filteredJobs.filter {
            Calendar.current.isDate($0.appointmentTime, inSameDayAs: selectedDate)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {

                DatePicker(
                    "Select Day",
                    selection: $selectedDate,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .padding(.horizontal)

                if filteredJobs.isEmpty {
                    Spacer()
                    VStack(spacing: 10) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.largeTitle)
                        Text("No jobs this day")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                } else {
                    List(filteredJobs) { job in
                        NavigationLink {
                            JobDetailsView(jobId: job.id, viewModel: viewModel)
                        } label: {
                            AgendaJobRow(job: job)
                        }
                    }
                }
            }
            .navigationTitle("Agenda")
        }
    }
}

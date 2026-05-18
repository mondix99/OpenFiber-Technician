import SwiftUI

struct JobDetailsView: View {
    let jobId: UUID
    @ObservedObject var viewModel: JobsViewModel
    @State private var expandedSectionKeys: Set<String> = []
    private let requiredSectionTitles: [String] = [
        "Intervento",
        "OLO",
        "Dati riferimento",
        "Sede cliente",
        "Dati tecnici",
        "Servizi attivi",
        "Altri dati tecnici",
        "Apparati",
        "Servizi aggiuntivi",
        "Sezione dati fattibilità"
    ]

    var body: some View {
        Group {
            if let job = viewModel.job(withId: jobId) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        headerCard(for: job)
                        statusTimeline(for: job.status)
                        infoAccordion(sections: job.infoSections)
                        workflowCard(for: job)
                        startButton(for: job)
                    }
                    .padding(16)
                }
            } else {
                ContentUnavailableView("Job not found", systemImage: "tray")
            }
        }
        .navigationTitle("Job Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func headerCard(for job: Job) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(job.customerName)
                .font(.title3.weight(.semibold))
            Text(job.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                Text("ID: \(job.id.uuidString.prefix(8))")
                Spacer()
                Text(job.appointmentTime.formatted(date: .abbreviated, time: .shortened))
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statusTimeline(for status: JobStatus) -> some View {
        let states: [String] = ["Inoltrato", "Preso in carico", "Arrivo sul posto", "Completato"]
        let activeIndex = timelineIndex(for: status)

        return VStack(alignment: .leading, spacing: 12) {
            Text("Status Timeline")
                .font(.headline)

            HStack(spacing: 8) {
                ForEach(Array(states.enumerated()), id: \.offset) { idx, _ in
                    Circle()
                        .fill(idx == activeIndex ? Color.accentColor : Color.gray.opacity(0.25))
                        .frame(width: 12, height: 12)
                    if idx < states.count - 1 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.25))
                            .frame(height: 2)
                    }
                }
            }

            HStack(alignment: .top) {
                ForEach(states, id: \.self) { label in
                    Text(label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func infoAccordion(sections: [JobInfoSection]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Information")
                .font(.headline)

            ForEach(requiredSectionTitles, id: \.self) { title in
                let section = sections.first(where: { $0.title == title })
                let key = title
                VStack(alignment: .leading, spacing: 10) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            if expandedSectionKeys.contains(key) {
                                expandedSectionKeys.remove(key)
                            } else {
                                expandedSectionKeys.insert(key)
                            }
                        }
                    } label: {
                        HStack {
                            Text(title)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Image(systemName: expandedSectionKeys.contains(key) ? "chevron.up" : "chevron.down")
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if expandedSectionKeys.contains(key) {
                        VStack(alignment: .leading, spacing: 8) {
                            if let section {
                                ForEach(section.fields) { field in
                                    HStack(alignment: .top) {
                                        Text(field.title)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(.secondary)
                                            .frame(width: 140, alignment: .leading)
                                        Text(field.value)
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func workflowCard(for job: Job) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Workflow")
                .font(.headline)
            Picker("", selection: .constant(job.jobType)) {
                Text("Installation").tag(JobType.installation)
                Text("Repair").tag(JobType.repair)
            }
            .pickerStyle(.segmented)
            .disabled(true)
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func startButton(for job: Job) -> some View {
        NavigationLink {
            ExecutionView(jobId: job.id, viewModel: viewModel)
        } label: {
            Text(job.jobType == .installation ? "Start Installation" : "Start Repair")
                .font(.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private func timelineIndex(for status: JobStatus) -> Int {
        switch status {
        case .new:
            return 0
        case .accepted:
            return 1
        case .traveling, .working:
            return 2
        case .completed:
            return 3
        }
    }
}

import SwiftUI
import CoreLocation

struct ExecutionView: View {
    let jobId: UUID
    @ObservedObject var viewModel: JobsViewModel

    @State private var locationProvider = LocationProvider()

    private var job: Job? {
        viewModel.job(withId: jobId)
    }

    var body: some View {
        Group {
            if let job {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header(job: job)
                        quickAction(job: job)
                        sectionsWithSteps(job: job)

                        Button("Complete Job") {
                            viewModel.completeJob(jobId: jobId)
                        }
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .controlSize(.large)
                        .disabled(!viewModel.allStepsCompleted(jobId: jobId))
                    }
                    .padding(16)
                }
                .navigationTitle("Execution")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView("Job not found", systemImage: "tray")
            }
        }
    }

    private func header(job: Job) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(job.customerName)
                .font(.title3.weight(.semibold))
            Text(job.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(job.jobType == .installation ? "Installation" : "Repair")
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func quickAction(job: Job) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Button {
                locationProvider.requestCurrentLocation { coordinate in
                    viewModel.performCheckIn(jobId: jobId, coordinate: coordinate)
                }
            } label: {
                HStack {
                    Label("Check-in", systemImage: "location")
                    Spacer()
                    if job.isCheckedIn {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .buttonStyle(.bordered)
            .disabled(job.isCheckedIn)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func sectionsWithSteps(job: Job) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(job.sections) { section in
                ForEach(section.steps) { step in
                    if let binding = viewModel.stepBinding(jobId: job.id, sectionId: section.id, stepId: step.id) {
                        if step.title.lowercased() == "allegati" {
                            StepListRow(step: step, subtitleOverride: "\(job.attachments.count) files uploaded")
                        } else if step.title.lowercased() == "check-in" {
                            StepListRow(step: step, subtitleOverride: nil)
                        } else {
                            NavigationLink {
                                StepDetailView(step: binding, jobId: job.id, viewModel: viewModel)
                            } label: {
                                StepListRow(step: step, subtitleOverride: nil)
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        StepListRow(step: step, subtitleOverride: nil)
                    }
                }
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct StepListRow: View {
    let step: JobStep
    let subtitleOverride: String?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: step.status.iconName)
                .foregroundStyle(step.status.color)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 3) {
                Text(step.title)
                    .font(.subheadline.weight(.semibold))
                if let subtitleOverride {
                    Text(subtitleOverride)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if !step.subtitle.isEmpty {
                    Text(step.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

@MainActor
private final class LocationProvider: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    private var onCoordinate: ((CLLocationCoordinate2D) -> Void)?

    override init() {
        super.init()
        // test
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestCurrentLocation(onCoordinate: @escaping (CLLocationCoordinate2D) -> Void) {
        self.onCoordinate = onCoordinate
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else { return }
        onCoordinate?(coordinate)
        onCoordinate = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onCoordinate = nil
    }
}

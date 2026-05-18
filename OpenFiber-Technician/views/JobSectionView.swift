import SwiftUI

struct JobSectionView: View {

    let jobId: UUID
    let section: JobSection
    @ObservedObject var viewModel: JobsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                    viewModel.toggleSection(jobId: jobId, sectionId: section.id)
                }
            } label: {
                HStack {
                    Text(section.title)
                        .font(.headline)

                    Spacer()

                    Image(systemName: section.isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                        .font(.body.weight(.semibold))
                }
                .padding(16)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)

            if section.isExpanded {
                VStack(spacing: 12) {
                    ForEach(section.steps) { step in
                        if let stepBinding = viewModel.stepBinding(jobId: jobId, sectionId: section.id, stepId: step.id) {
                            NavigationLink {
                                StepDetailView(step: stepBinding, jobId: jobId, viewModel: viewModel)
                            } label: {
                                StepRowView(step: step)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

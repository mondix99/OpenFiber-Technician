import SwiftUI

struct StepRowView: View {

    var step: JobStep

    var body: some View {
        HStack(spacing: 16) {

            Image(systemName: step.type.icon)
                .foregroundStyle(.secondary)
                .frame(width: 28, alignment: .center)

            VStack(alignment: .leading, spacing: 4) {
                Text(step.title)
                    .font(.headline)

                if !step.subtitle.isEmpty {
                    Text(step.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Image(systemName: step.status.iconName)
                .foregroundStyle(step.status.color)
                .font(.title3)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

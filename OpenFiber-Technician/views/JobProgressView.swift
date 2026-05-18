import SwiftUI

struct JobProgressView: View {

    var status: JobStatus

    var body: some View {
        HStack {
            progressStep(title: "Assigned", active: true)
            progressLine()

            progressStep(title: "Traveling", active: status == .traveling || status == .working || status == .completed)
            progressLine()

            progressStep(title: "Working", active: status == .working || status == .completed)
            progressLine()

            progressStep(title: "Completed", active: status == .completed)
        }
        .padding(16)
    }

    private func progressStep(title: String, active: Bool) -> some View {
        VStack(spacing: 6) {
            Circle()
                .fill(active ? status.progressActiveColor : status.progressInactiveColor)
                .frame(width: 12, height: 12)

            Text(title)
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
    }

    private func progressLine() -> some View {
        Rectangle()
            .fill(status.progressInactiveColor)
            .frame(height: 2)
    }
}

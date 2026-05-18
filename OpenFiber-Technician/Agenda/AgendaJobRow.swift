import SwiftUI

struct AgendaJobRow: View {

    let job: Job

    var body: some View {
        HStack(spacing: 14) {

            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 4) {
                Text(job.customerName)
                    .font(.headline)

                Text(job.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(timeString)
                .font(.caption)
        }
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: job.appointmentTime)
    }

    var statusColor: Color {
        switch job.status {
        case .new: return .blue
        case .accepted: return .orange
        case .traveling: return .purple
        case .working: return .green
        case .completed: return .gray
        }
    }
}

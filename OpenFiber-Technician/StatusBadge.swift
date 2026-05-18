import SwiftUI

struct StatusBadge: View {

    var status: JobStatus

    var body: some View {
        Text(status.displayTitle)
            .font(.caption)
            .padding(6)
            .background(status.indicatorColor.opacity(0.2))
            .foregroundStyle(status.indicatorColor)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

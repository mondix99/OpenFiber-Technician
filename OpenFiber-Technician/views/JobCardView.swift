import SwiftUI

struct JobCardView: View {
    
    var job: Job
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Text(job.customerName)
                    .font(.headline)
                
                Spacer()
                
                StatusBadge(status: job.status)
            }
            
            Text(job.address)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Text(job.popZone)
                    .font(.caption)
                    .padding(6)
                    .background(job.status.indicatorColor.opacity(0.15))
                    .foregroundStyle(job.status.indicatorColor)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                
                Spacer()
                
                Text(job.jobType.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(job.appointmentTime.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

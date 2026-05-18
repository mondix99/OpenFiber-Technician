import Foundation
import CoreLocation
import SwiftUI

// MARK: - Job Status

enum JobStatus: String, Codable {
    case new
    case accepted
    case traveling
    case working
    case completed

    var displayTitle: String {
        rawValue.capitalized
    }

    var indicatorColor: Color {
        switch self {
        case .new: return .blue
        case .accepted: return .orange
        case .traveling: return .purple
        case .working: return .yellow
        case .completed: return .green
        }
    }

    var progressActiveColor: Color {
        switch self {
        case .new: return .gray
        case .accepted: return .blue
        case .traveling: return .purple
        case .working: return .orange
        case .completed: return .green
        }
    }

    var progressInactiveColor: Color {
        Color.gray.opacity(0.3)
    }
}

// MARK: - Job Type

enum JobType: String, Codable, Hashable {
    case installation
    case repair
}

// MARK: - Job

struct Job: Identifiable, Codable {

    let id: UUID
    var customerName: String
    var address: String
    var popZone: String
    var appointmentTime: Date

    var status: JobStatus
    var jobType: JobType

    var devices: [Device]
    var sections: [JobSection]
    var infoSections: [JobInfoSection]

    var attachments: [URL] = []
    var latitude: Double
    var longitude: Double
    var isCheckedIn: Bool = false
    var checkInLatitude: Double?
    var checkInLongitude: Double?

    var notes: String?
    var assignedTechnicianId: UUID?
    var assignedTeamId: String

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
}

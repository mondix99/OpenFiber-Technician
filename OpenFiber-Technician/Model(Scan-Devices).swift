import Foundation

enum DeviceType: String, Codable {
    case ont
    case router
    case fiberModem
}

struct Device: Identifiable, Codable {
    let id: UUID
    var name: String
    var serialNumber: String
    var type: DeviceType
    var isVerified: Bool
}

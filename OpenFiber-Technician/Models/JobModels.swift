import Foundation
import SwiftUI

// MARK: - Step Value (API-friendly tagged union)

enum StepValue: Equatable, Hashable {
    case none
    case string(String)
    case number(Double)
    case bool(Bool)
    case date(Date)
}

extension StepValue: Codable {
    private enum CodingKeys: String, CodingKey {
        case kind, stringValue, numberValue, boolValue, dateValue
    }

    private enum Kind: String, Codable {
        case none, string, number, bool, date
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try c.decode(Kind.self, forKey: .kind)
        switch kind {
        case .none:
            self = .none
        case .string:
            self = .string(try c.decode(String.self, forKey: .stringValue))
        case .number:
            self = .number(try c.decode(Double.self, forKey: .numberValue))
        case .bool:
            self = .bool(try c.decode(Bool.self, forKey: .boolValue))
        case .date:
            self = .date(try c.decode(Date.self, forKey: .dateValue))
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .none:
            try c.encode(Kind.none, forKey: .kind)
        case .string(let s):
            try c.encode(Kind.string, forKey: .kind)
            try c.encode(s, forKey: .stringValue)
        case .number(let n):
            try c.encode(Kind.number, forKey: .kind)
            try c.encode(n, forKey: .numberValue)
        case .bool(let b):
            try c.encode(Kind.bool, forKey: .kind)
            try c.encode(b, forKey: .boolValue)
        case .date(let d):
            try c.encode(Kind.date, forKey: .kind)
            try c.encode(d, forKey: .dateValue)
        }
    }

}

// MARK: - Step Status

enum StepStatus: String, Codable {
    case pending
    case inProgress
    case completed
    case failed

    var color: Color {
        switch self {
        case .pending: return .gray.opacity(0.4)
        case .inProgress: return .blue
        case .completed: return .green
        case .failed: return .red
        }
    }

    var iconName: String {
        switch self {
        case .pending: return "circle"
        case .inProgress: return "clock"
        case .completed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        }
    }
}

// MARK: - Step Type

enum StepType: String, Codable {
    case text, number, dropdown, boolean, image, scan, date, location

    var icon: String {
        switch self {
        case .text: return "textformat"
        case .number: return "number"
        case .dropdown: return "list.bullet"
        case .boolean: return "checkmark.square"
        case .image: return "photo"
        case .scan: return "qrcode.viewfinder"
        case .date: return "calendar"
        case .location: return "location"
        }
    }
}

// MARK: - Step

struct JobStep: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var subtitle: String
    var type: StepType
    var status: StepStatus
    var value: StepValue
    var options: [String]
    var scanCompareDeviceId: UUID?

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        type: StepType,
        status: StepStatus = .pending,
        value: StepValue = .none,
        options: [String] = [],
        scanCompareDeviceId: UUID? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.status = status
        self.value = value
        self.options = options
        self.scanCompareDeviceId = scanCompareDeviceId
    }
}

// MARK: - Section

struct JobSection: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var steps: [JobStep]
    var isExpanded: Bool

    init(
        id: UUID = UUID(),
        title: String,
        steps: [JobStep],
        isExpanded: Bool = false
    ) {
        self.id = id
        self.title = title
        self.steps = steps
        self.isExpanded = isExpanded
    }
}

// MARK: - Info Section

struct JobInfoSection: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var fields: [JobInfoField]

    init(id: UUID = UUID(), title: String, fields: [JobInfoField]) {
        self.id = id
        self.title = title
        self.fields = fields
    }
}

struct JobInfoField: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var value: String

    init(id: UUID = UUID(), title: String, value: String) {
        self.id = id
        self.title = title
        self.value = value
    }
}

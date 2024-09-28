import Foundation

public struct VisitOptions: Codable, JSONCodable {
    public let action: VisitAction

    public init(action: VisitAction = .push) {
        self.action = action
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.action = try container.decodeIfPresent(VisitAction.self, forKey: .action) ?? .push
    }
}

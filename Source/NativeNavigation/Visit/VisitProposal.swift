import Foundation

public struct VisitProposal {
    public let url: URL
    public let action: VisitAction
    public let options: VisitOptions
    public let properties: PathProperties
    public let parameters: [String: Any]?

    public init(url: URL, options: VisitOptions, properties: PathProperties = [:], parameters: [String: Any]? = nil) {
        self.url = url
        self.action = options.action
        self.options = options
        self.properties = properties
        self.parameters = parameters
    }
}

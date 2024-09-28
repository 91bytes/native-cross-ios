import WebKit

enum VisitState {
    case initialized
    case started
    case canceled
    case failed
    case completed
}

class Visit: NSObject {
    weak var delegate: VisitDelegate?
    let visitable: Visitable
    var restorationIdentifier: String?
    let options: VisitOptions
    let bridge: WebViewBridge
    var webView: WKWebView { bridge.webView }
    let location: URL

    var hasCachedSnapshot: Bool = false
    var isPageRefresh: Bool = false
    private(set) var state: VisitState

    init(visitable: Visitable, options: VisitOptions, bridge: WebViewBridge) {
        self.visitable = visitable
        self.location = visitable.visitableURL!
        self.options = options
        self.bridge = bridge
        self.state = .initialized
    }

    func start() {
        guard state == .initialized else { return }

        delegate?.visitWillStart(self)
        state = .started
        startVisit()
    }

    func complete() {
        guard state == .started else { return }

        state = .completed

        completeVisit()
        delegate?.visitDidComplete(self)
    }

    func fail(with error: Error) {
        guard state == .started else { return }

        state = .failed
        failVisit()
        delegate?.visitDidFail(self)
    }

    func startVisit() {}
    func completeVisit() {}
    func failVisit() {}
}

// CustomDebugStringConvertible
extension Visit {
    override var debugDescription: String {
        "<\(type(of: self)) state: \(state), location: \(location)>"
    }
}

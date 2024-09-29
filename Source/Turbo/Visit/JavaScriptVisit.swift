import Foundation

/// A `JavaScript` managed visit through the Hotwire library.
/// All visits are `JavaScriptVisits` except the initial `ColdBootVisit`
/// or if a `reload()` is issued.
final class JavaScriptVisit: Visit {
    init(visitable: Visitable, options: VisitOptions, bridge: WebViewBridge, restorationIdentifier: String?) {
        super.init(visitable: visitable, options: options, bridge: bridge)
        self.restorationIdentifier = restorationIdentifier
    }

    override var debugDescription: String {
        "<JavaScriptVisit state: \(state), location: \(location)>"
    }

    override func startVisit() {
        log("startVisit")
        bridge.visitDelegate = self
        bridge.visitLocation(location, options: options, restorationIdentifier: restorationIdentifier)
    }

    override func failVisit() {
        log("failVisit")
        finishRequest()
    }
}

extension JavaScriptVisit: WebViewVisitDelegate {
    func webView(didStartVisit webView: WebViewBridge) {
        log("didStartVisitWithIdentifier", ["isPageRefresh": isPageRefresh])
        self.hasCachedSnapshot = hasCachedSnapshot
        self.isPageRefresh = isPageRefresh
        
        delegate?.visitDidStart(self)
    }
    
    func webView(didFailVisit webView: WebViewBridge) {
        fail(with: TurboError.pageLoadFailure)
    }
    
    func webView(didCompleteVisit webView: WebViewBridge) {
        delegate?.visitDidRender(self)
    }
    
    private func log(_ name: String, _ arguments: [String: Any] = [:]) {
        logger.debug("[JavascriptVisit] \(name) \(self.location.absoluteString), \(arguments)")
    }
}

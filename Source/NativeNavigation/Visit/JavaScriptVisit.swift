import Foundation

/// A `JavaScript` managed visit through the NativeCross library.
/// All visits are `JavaScriptVisits` except the initial `ColdBootVisit`
/// or if a `reload()` is issued.
final class JavaScriptVisit: Visit {
    private var identifier = "(pending)"
    
    init(visitable: Visitable, options: VisitOptions, bridge: WebViewBridge, restorationIdentifier: String?) {
        super.init(visitable: visitable, options: options, bridge: bridge)
        self.restorationIdentifier = restorationIdentifier
    }

    override var debugDescription: String {
        "<JavaScriptVisit identifier: \(identifier), state: \(state), location: \(location)>"
    }

    override func startVisit() {
        log("startVisit")
        bridge.visitDelegate = self
        bridge.visitLocation(location, options: options)
    }

    override func failVisit() {
        log("failVisit")
    }
}

extension JavaScriptVisit: WebViewVisitDelegate {
    func webView(_ webView: WebViewBridge, didStartVisit isPageRefresh: Bool) {
        log("didStartVisitWithIdentifier", ["identifier": identifier, "hasCachedSnapshot": hasCachedSnapshot, "isPageRefresh": isPageRefresh])
        self.isPageRefresh = isPageRefresh
        
        delegate?.visitDidStart(self)
    }
    
    func webView(didFailVisit webView: WebViewBridge) {
        guard identifier == self.identifier else { return }
        
        log("didFailVisit")
        fail(with: TurboError.pageLoadFailure)
    }
    
    func webView(didCompleteVisit webView: WebViewBridge) {
        guard identifier == self.identifier else { return }
        
        log("didRenderForVisitWithIdentifier", ["identifier": identifier])
        delegate?.visitDidComplete(self)
    }
    
    private func log(_ name: String, _ arguments: [String: Any] = [:]) {
        logger.debug("[JavascriptVisit] \(name) \(self.location.absoluteString), \(arguments)")
    }
}

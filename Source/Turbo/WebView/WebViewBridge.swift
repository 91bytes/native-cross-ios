import WebKit

protocol WebViewDelegate: AnyObject {
    func webView(_ webView: WebViewBridge, didProposeVisitToLocation location: URL, options: VisitOptions)
    func webView(_ webView: WebViewBridge, didFailInitialPageLoadWithError: Error)
    func webView(_ webView: WebViewBridge, didFailJavaScriptEvaluationWithError error: Error)
}

protocol WebViewPageLoadDelegate: AnyObject {
    func webView(didLoadPage webView: WebViewBridge)
}

protocol WebViewVisitDelegate: AnyObject {
    func webView(didStartVisit webView: WebViewBridge)
    func webView(didFailVisit webView: WebViewBridge)
    func webView(didCompleteVisit webView: WebViewBridge)
}

/// The WebViewBridge is an internal class used for bi-directional communication
/// with the web view/JavaScript
final class WebViewBridge {
    private let messageHandlerName = "turbo"

    weak var delegate: WebViewDelegate?
    weak var pageLoadDelegate: WebViewPageLoadDelegate?
    weak var visitDelegate: WebViewVisitDelegate?

    let webView: WKWebView

    deinit {
        webView.configuration.userContentController.removeScriptMessageHandler(forName: messageHandlerName)
    }

    init(webView: WKWebView) {
        self.webView = webView
        setup()
    }

    private func setup() {
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.userContentController.add(ScriptMessageHandler(delegate: self), name: messageHandlerName)
    }

    private var userScript: WKUserScript {
        let url = Bundle.module.url(forResource: "turbo", withExtension: "js")!
        let source = try! String(contentsOf: url, encoding: .utf8)
        return WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
    }

    // MARK: - JS

    func visitLocation(_ location: URL, options: VisitOptions, restorationIdentifier: String?) {
        callJavaScript(function: "window.nativeNavigation.visitLocationWithOptions", arguments: [
            location.absoluteString,
            options.toJSON()
        ])
    }

    // MARK: JavaScript Evaluation

    private func callJavaScript(function: String, arguments: [Any?] = []) {
        let expression = JavaScriptExpression(function: function, arguments: arguments)

        guard let script = expression.wrappedString else {
            NSLog("Error formatting JavaScript expression `%@'", function)
            return
        }

        logger.debug("[Bridge] → \(function) \(arguments)")

        webView.evaluateJavaScript(script) { result, error in
            logger.debug("[Bridge] = \(function) evaluation complete")

            if let result = result as? [String: Any], let error = result["error"] as? String, let stack = result["stack"] as? String {
                NSLog("Error evaluating JavaScript function `%@': %@\n%@", function, error, stack)
            } else if let error {
                self.delegate?.webView(self, didFailJavaScriptEvaluationWithError: error)
            }
        }
    }
}

extension WebViewBridge: ScriptMessageHandlerDelegate {
    func scriptMessageHandlerDidReceiveMessage(_ scriptMessage: WKScriptMessage) {
        guard let message = ScriptMessage(message: scriptMessage) else { return }

        if message.name != .log {
            logger.debug("[Bridge] ← \(message.name.rawValue) \(message.data)")
        }

        switch message.name {
        case .pageLoaded:
            pageLoadDelegate?.webView(didLoadPage: self)
        case .visitProposed:
            delegate?.webView(self, didProposeVisitToLocation: message.location!, options: message.options!)
        case .visitStarted:
            visitDelegate?.webView(didStartVisit: self)
        case .visitFailed:
            visitDelegate?.webView(didFailVisit: self)
        case .visitCompleted:
            visitDelegate?.webView(didCompleteVisit: self)
        case .log:
            guard let msg = message.data["message"] as? String else { return }
            logger.debug("[Bridge] ← log: \(msg)")
        }
    }
}

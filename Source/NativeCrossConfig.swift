import UIKit
import WebKit

public struct NativeCrossConfig {
    public typealias WebViewBlock = (_ configuration: WKWebViewConfiguration) -> WKWebView

    /// Override to set a custom user agent.
    public var userAgent = "Native Cross iOS"

    /// When enabled, adds a `UIBarButtonItem` of type `.done` to the left
    /// navigation bar button item on screens presented modally.
    public var showDoneButtonOnModals = false

    /// Sets the back button display mode of `NativeCrossWebViewController`.
    public var backButtonDisplayMode = UINavigationItem.BackButtonDisplayMode.default

    /// Enable or disable debug logging for Turbo visits and bridge elements
    /// connecting, disconnecting, receiving/sending messages, and more.
    public var debugLoggingEnabled = false {
        didSet {
            NativeCrossLogger.debugLoggingEnabled = debugLoggingEnabled
        }
    }

    // MARK: Turbo

    /// Configure options for matching path rules.
    public var pathConfiguration = PathConfiguration()

    /// The view controller used in `Navigator` for web requests. Must be
    /// a `VisitableViewController` or subclass.
    public var defaultViewController: (URL) -> VisitableViewController = { url in
        NativeCrossWebViewController(url: url)
    }

    /// The navigation controller used in `Navigator` for the main and modal stacks.
    /// Must be a `UINavigationController` or subclass.
    public var defaultNavigationController: () -> UINavigationController = {
        UINavigationController()
    }

    /// Optionally customize the web views used by each Turbo Session.
    /// Ensure you return a new instance each time.
    public var makeCustomWebView: WebViewBlock = { (configuration: WKWebViewConfiguration) in
        WKWebView.debugInspectable(configuration: configuration)
    }

    // MARK: Bridge

    /// Set a custom JSON encoder when parsing bridge payloads.
    /// The custom encoder can be useful when you need to apply specific
    /// encoding strategies, like snake case vs. camel case
    public var jsonEncoder = JSONEncoder()

    /// Set a custom JSON decoder when parsing bridge payloads.
    /// The custom decoder can be useful when you need to apply specific
    /// decoding strategies, like snake case vs. camel case
    public var jsonDecoder = JSONDecoder()

    // MARK: - Internal

    public func makeWebView() -> WKWebView {
        makeCustomWebView(makeWebViewConfiguration())
    }

    // MARK: - Private

    private let sharedProcessPool = WKProcessPool()

    // A method (not a property) because we need a new instance for each web view.
    private func makeWebViewConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences?.preferredContentMode = .mobile
        configuration.applicationNameForUserAgent = userAgent
        configuration.processPool = sharedProcessPool
        return configuration
    }
}

public extension NativeCrossConfig {
    class PathConfiguration {
        /// Enable to include the query string (in addition to the path) when applying rules.
        /// Disable to only consider the path when applying rules.
        public var matchQueryStrings = true
    }
}

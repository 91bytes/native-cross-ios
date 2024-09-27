import WebKit

public enum NativeCross {
    /// Use this instance to configure NativeCross.
    public static var config = NativeCrossConfig()

    /// Registers your bridge components to use with `NativeCrossWebViewController`.
    ///
    /// Use `NativeCross.config.makeCustomWebView` to customize the web view or web view
    /// configuration further, making sure to call `Bridge.initialize()`.
    public static func registerBridgeComponents(_ componentTypes: [BridgeComponent.Type]) {
        NativeCross.config.userAgent += " \(UserAgent.userAgentSubstring(for: componentTypes))"
        bridgeComponentTypes = componentTypes

        NativeCross.config.makeCustomWebView = { configuration in
            let webView = WKWebView.debugInspectable(configuration: configuration)
            Bridge.initialize(webView)
            return webView
        }
    }

    static var bridgeComponentTypes = [BridgeComponent.Type]()
}

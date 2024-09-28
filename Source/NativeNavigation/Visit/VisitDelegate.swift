import Foundation

protocol VisitDelegate: AnyObject {
    func visitDidInitializeWebView(_ visit: Visit)
    
    func visitWillStart(_ visit: Visit)
    func visitDidStart(_ visit: Visit)
    func visitDidComplete(_ visit: Visit)
    func visitDidFail(_ visit: Visit)
    
    func visit(_ visit: Visit, didReceiveAuthenticationChallenge challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void)
}

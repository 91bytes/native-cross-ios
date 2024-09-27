import Foundation
import os.log

enum NativeCrossLogger {
    static var debugLoggingEnabled: Bool = false {
        didSet {
            logger = debugLoggingEnabled ? enabledLogger : disabledLogger
        }
    }

    static let enabledLogger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "NativeCross")
    static let disabledLogger = Logger(.disabled)
}

var logger = NativeCrossLogger.disabledLogger

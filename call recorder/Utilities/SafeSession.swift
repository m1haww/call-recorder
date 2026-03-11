import Foundation

func safeSession() -> URLSession {
    if #available(iOS 18.4, *) {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 300
        return URLSession(configuration: config)
    } else {
        return URLSession.shared
    }
}

//
//  NetworkSessionManager.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//

import Foundation

enum URLSessionType:Int {
    case standard
    
    var keyPath:ReferenceWritableKeyPath<NetworkSessionManager, CoreURLSession> {
        get {
            switch self {
            case .standard:
                return \.standardSession
            }
        }
    }
}

/**
 Used to get the right CoreURLSession for a given request.
 */

class NetworkSessionManager: SSLPinningHandler {
    
    //MARK: - Variables
    static let shared = NetworkSessionManager()
    var csrfToken:String? = nil
    
    fileprivate lazy var standardSession:CoreURLSession = {
        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.tlsMinimumSupportedProtocolVersion = .TLSv12
        sessionConfiguration.httpCookieStorage = HTTPCookieStorage.shared
        let session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    //MARK: - Initialization
    fileprivate override init() {}
    
    ///Get session by type
    func getSession(sessionType:URLSessionType) -> CoreURLSession {
        return self[keyPath:sessionType.keyPath]
    }
    
    ///Cancel all request for all sessions
    func cancelAllRequests(completion:@escaping() -> Void) {
        standardSession.cancelAllRequests(completion:{
            completion()
        })
    }
    
}

extension NetworkSessionManager: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        sslPinning(for: challenge, with: completionHandler)
    }
}

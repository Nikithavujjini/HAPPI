//
//  CoreAbstractRouter.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation

class CoreAbstractRouter:CoreRouterProtocol {
    
    var boundary: String?
    
    ///Relative path past the api part of the path. Defaults to empty string.
    var path: String {
        return ""
    }
    
    ///HTTP method. Defaults to GET.
    var httpMethod: HTTPMethod {
        return .get
    }
    
    var httpBody: Data? {
        return nil
    }
    
    ///HTTP headers. Defaults to empty array.
    var headers: HTTPHeaders {
        return [:]
    }
    
    ///This part of the url should just include the host.
    var hostUrl:URL? {
        guard let hostUrl = EnvironmentManager.shared.currentEnvironmentUrlWithSubscription else { return nil }
        return hostUrl
    }
    
    var hostWithPathUrl:URL? {
        guard let hostUrl = hostUrl else { return nil }
        return hostUrl.appendingPathComponent(path)
    }
    
    var hostUrlV1APIPathUrl:URL? {
        guard let hostUrl = hostUrl else { return nil }
        return hostUrl.appendingPathComponent("cm/v1")
    }
    
    
    var url: URL? {
        guard let hostWithPathUrl = hostWithPathUrl else { return nil }
        if queryParameters.count > 0 {
            var urlComponent = URLComponents(url: hostWithPathUrl, resolvingAgainstBaseURL: false)
            var queryItems = [URLQueryItem]()
            for queryParameter in queryParameters {
                queryItems.append(URLQueryItem(name: queryParameter.key, value: queryParameter.value))
            }
            urlComponent?.queryItems = queryItems
            return urlComponent?.url
        }
        return hostWithPathUrl
    }
    
    ///Array of query parameters. Default to empty array.
    var queryParameters: HTTPParameters {
        return [:]
    }
    
    ///Represents the content type of the request. Default to any `*/*`.
    var contentType: HTTPContentType {
        return .any
    }
    
    ///Represents the content type that the app expects in the response. Defaults to hal+json.
    var acceptContentType: HTTPContentType? {
        return .halJson
    }
    
    ///If a request needs the Authorization Bearer token then this needs to return true. Else the request will not include the Bearer token in the header.
    var needsAuthentication:Bool {
        return true
    }
    
    var urlSessionType:URLSessionType {
        return .standard
    }
    
    var receiveOnQueue:DispatchQueue {
        return DispatchQueue.main
    }
    
    var uploadFileData:Data? {
        return nil
    }
    
    func asURLRequest() -> URLRequest? {
        guard let url = url else { return nil }
        var urlRequest = URLRequest(url: url)
        for header in headers {
            urlRequest.addValue(header.value, forHTTPHeaderField: header.key)
        }
        addContentTypeHeader(urlRequest: &urlRequest)
        addAcceptContentTypeHeader(urlRequest: &urlRequest)
       
        urlRequest.httpMethod = httpMethod.rawValue
        if let httpBody = httpBody {
            urlRequest.httpBody = httpBody
        }
        return urlRequest
    }
    
    fileprivate func addAcceptContentTypeHeader(urlRequest:inout URLRequest){
        guard let acceptContentType = acceptContentType else { return }
        urlRequest.addValue(acceptContentType.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.acceptContentType.rawValue)
    }
    
    /**
     Private function used to add the  `Content Type` header.
     - parameters:
         - urlRequest: URLRequest that the header will be added to.
     */
    fileprivate func addContentTypeHeader(urlRequest:inout URLRequest){
        guard contentType != .any else { return }
        if contentType == .multipart {
            var value = contentType.rawValue
            if let boundary = boundary {
                value = value + "; boundary=\(boundary)"
            }
            urlRequest.addValue(value, forHTTPHeaderField: HTTPHeaderFieldName.contentType.rawValue)
        } else {
            urlRequest.addValue(contentType.rawValue, forHTTPHeaderField: HTTPHeaderFieldName.contentType.rawValue)
        }
        
    }
    
    /**
     Private function used to add the  `X-CCM-XSRF-TOKEN` header.
     - parameters:
         - urlRequest: URLRequest that the header will be added to.
     */
    fileprivate func addCSRFHeader(urlRequest:inout URLRequest){
        if let csrfToken = NetworkSessionManager.shared.csrfToken {
            urlRequest.addValue(csrfToken, forHTTPHeaderField: HTTPHeaderFieldName.csrfToken.rawValue)
        }
    }
}

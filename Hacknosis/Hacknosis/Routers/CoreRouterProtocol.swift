//
//  CoreRouterProtocol.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation

protocol CoreRouterProtocol:AnyObject {
    
    var path:String { get }
    
    var httpMethod:HTTPMethod { get }
    
    var httpBody:Data? { get }
    
    var headers:HTTPHeaders { get }
    
    var url:URL? { get }
    
    var hostUrl:URL? { get }
    
    var hostWithPathUrl:URL? { get }
    
    var queryParameters:HTTPParameters { get }
    
    var contentType:HTTPContentType { get }
    
    var needsAuthentication:Bool { get }
    
    var urlSessionType:URLSessionType { get }
    
    var receiveOnQueue:DispatchQueue { get }
        
    var boundary:String? { get set }
    
    func asURLRequest() -> URLRequest?
    
}


typealias HTTPHeaders = [String:String]
typealias HTTPParameters = [String:String?]

enum HTTPContentType:String {
    case halJson = "application/hal+json"
    case json = "application/json"
    case octetStream = "application/octet-stream"
    case urlEncoding = "application/x-www-form-urlencoded; charset=utf-8"
    case multipart = "multipart/form-data"
    case html = "text/html; charset=UTF-8"
    case plainText = "text/plain"
    case any = "*/*"
}

enum HTTPMethod: String {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
    case trace = "TRACE"
    case connect = "CONNECT"
    case patch = "PATCH"
}

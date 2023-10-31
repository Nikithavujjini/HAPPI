//
//  CoreUrlSession.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//

import Foundation
import Combine

/**
 Protocol for CoreURLSession which includes `URLSession` or any mock of URLSession
 */
protocol CoreURLSession:AnyObject {
    
    /**
    Return a publisher with output and error
     */
    func publisher(urlRequest:URLRequest, accessToken:String?) -> AnyPublisher<URLSession.DataTaskPublisher.Output, CoreError>
    
    /**
    Return a publisher with output and error
     */
    func downloadPublisher(urlRequest: URLRequest, accessToken: String?) -> AnyPublisher<URLSession.DownloadTaskPublisher.Output, CoreError>
    
    /**
    Return a publisher with output and error
     */
    func uploadPublisher(urlRequest request: URLRequest, accessToken: String?, fromFile fileUrl: URL?, taskDescription:String) -> AnyPublisher<URLSession.UploadTaskPublisher.Output, CoreError>
    
    /**
    Cancel all requests for the `CoreURLSession`
     */
    func cancelAllRequests(completion:@escaping() -> Void)
    
}

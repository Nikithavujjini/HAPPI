//
//  CoreUrlSession.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//

import Foundation
import Combine


protocol CoreURLSession:AnyObject {
    
   
    func publisher(urlRequest:URLRequest, accessToken:String?) -> AnyPublisher<URLSession.DataTaskPublisher.Output, CoreError>
    
   
    func downloadPublisher(urlRequest: URLRequest, accessToken: String?) -> AnyPublisher<URLSession.DownloadTaskPublisher.Output, CoreError>
    
   
    func uploadPublisher(urlRequest request: URLRequest, accessToken: String?, fromFile fileUrl: URL?, taskDescription:String) -> AnyPublisher<URLSession.UploadTaskPublisher.Output, CoreError>
  
    func cancelAllRequests(completion:@escaping() -> Void)
    
}

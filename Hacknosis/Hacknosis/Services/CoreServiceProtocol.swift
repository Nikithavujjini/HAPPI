//
//  CoreServiceProtocol.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation
import Combine

protocol CoreServiceProtocol:AnyObject {
    
    /**
     This function is used to return a publisher that uses a router that conforms to `CoreRouterProtocol` to make a data network request using combine.
     - parameters:
        - router: A router that conforms to the `CoreRouterProtocol`
     - returns: `AnyPublisher<URLSession.DataTaskPublisher.Output, CoreError>?`
     - Note: If the request needs authentication then the function will first get an access token publisher  which will get the acces token. If in getting the access token the error status code is a `401` then it will attempt to refresh the access token and with the new access token  create a new publisher with the same URLrequest to try the request again.
     */
    func callAPI(router:CoreRouterProtocol) -> AnyPublisher<URLSession.DataTaskPublisher.Output, CoreError>?
    
}

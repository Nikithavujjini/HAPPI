//
//  CoreServiceProtocol.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation
import Combine

protocol CoreServiceProtocol:AnyObject {
    
    
    func callAPI(router:CoreRouterProtocol) -> AnyPublisher<URLSession.DataTaskPublisher.Output, CoreError>?
    
}

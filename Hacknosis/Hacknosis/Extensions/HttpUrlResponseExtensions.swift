//
//  HttpUrlResponseExtensions.swift
//  Core Content
//
//  Created by Jamie Klapwyk on 2021-08-06.
//

import Foundation

extension HTTPURLResponse {
    
     /**
     Checks if the response status code is in the `200`s
     */
     func isResponseOK() -> Bool {
        return (200...299).contains(self.statusCode)
     }
    
    func isUnAuthorized() -> Bool {
        return statusCode == 401
    }
    
    func isAuthenticationFailed() -> Bool {
        return statusCode == 400
    }
}

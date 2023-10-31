//
//  CoreError.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation

/**
 Error types used to easily pass errors thatcan be checked
 */
enum CoreErrorType:String {
    case general
    case loginRequired
    case loginRequiredForPrivateLink
    case authenticationFailed
    case authenticationCancelled
    case requestCancelled
    case subscriptionNotFound
    case privateSharedLinkExpired
}

/**
 The common error type for the app. Can be used to help display errors to the UI as well as pass errors throughout the application.
 - Note: Various initializers help create this object.
 */
class CoreError: Error {
    //MARK: - Variables
    var status:Int? = nil
    var code : String?
    var title: String = "ERROR"
    var message: String = "ERROR_UNKNOWN_ERROR"
    var nserror:NSError? = nil
    var type:CoreErrorType = .general
    
    //MARK: - Initialization
    /**
        Init by title `String` message, `String` used to simply present an error to the UI. The title defaults to "Error"
     */
    init(title:String? = nil, message:String){
        if let title = title {
            self.title = title
        }
        self.message = message
    }
    
    /**
        Init by `CoreErrorType` used to help easily communicate to other pieces of the app in case of an error. Defaults to `.general`
     */
    init(type:CoreErrorType){
        self.type = type
    }
    
    /**
        Init with `NSError` used by generic errors
     */
    init(nserror: NSError?) {
        if let nserror = nserror {
            self.message = nserror.localizedDescription
        }
        self.nserror = nserror
    }
    
    /**
        Init with `HTTPURLResponse`. generally used as a result of a network request that does not have a body in the response.
     */
    init(httpResponse:HTTPURLResponse?){
        if let httpResponse = httpResponse {
            self.status = httpResponse.statusCode
            self.message = HTTPURLResponse.localizedString(forStatusCode: httpResponse.statusCode)
        }
    }
    
    /**
        Init with error model is generally used to help populate the error field based on the `ErrorModel` which is usually from the network response.
     */
    init(errorModel:ErrorModel, statusCode:Int? = nil){
        status = errorModel.status ?? statusCode
        if let title = errorModel.title {
            self.title = title
        }
        if let details = errorModel.details {
            message = details
        } else if let error = errorModel.error {
            message = error
        } else if let errorDescription = errorModel.errorDescription {
            message = errorDescription
        } else if let message = errorModel.message {
            self.message = message
        }
    }
}


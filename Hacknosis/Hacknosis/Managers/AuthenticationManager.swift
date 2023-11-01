//
//  AuthenticationManager.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation
import Combine


class AuthenticationManager {
    
    static let shared:AuthenticationManager = AuthenticationManager()
    
    var request:AnyCancellable?
    var BIOMETRICS_DISABLED:String = "biometricsDisabled"

    ///The access queue makes sure that changes to properties in the Download class, from multiple threads, happen synchronously not asynchronously.
    fileprivate var accessQueue:DispatchQueue = DispatchQueue(label: AppBundleIdentifier+".authentication.accessQueue", qos: .utility, target:DispatchQueue.global(qos:.utility))
    
    //MARK: - Token Getters and Setters
    var accessToken: String? {
        get{
            let returnToken = KeychainHelper.fetch(.accessToken)
            return returnToken
        }
        set {
            KeychainHelper.store(.accessToken, token: newValue!)
          //  NotificationCenter.default.post(name:.accessTokenRefreshed, object:nil)
        }
    }
    var refreshToken: String? {
        get{
            let returnToken = KeychainHelper.fetch(.refreshToken)
            return returnToken
        }
        set {
            KeychainHelper.store(.refreshToken, token: newValue!)
        }
    }
    
    var isDoctorSignedIn: Bool {
        get {
            return UserHelper.getCurrentUserFromRealm() != nil
        }
    }
    
    public var isSignedIn:Bool {
        get {
            return UserHelper.getCurrentUserFromRealm() != nil
        }
    }
    
    fileprivate var _isAccessTokenValid:Bool = true
    var isAccessTokenValid:Bool {
        set {
            accessQueue.sync {
                _isAccessTokenValid = newValue
            }
        }
        get {
            accessQueue.sync {
                return _isAccessTokenValid
            }
        }
    }



    var refreshTokenPublisher:AnyPublisher<String, CoreError>?
    
   
    func getAccessTokenPublisher(forceRefresh:Bool = false) -> AnyPublisher<String, CoreError> {
        
        return accessQueue.sync {
            
            //if publisher already exists simply share the existing one.
            if let publisher = refreshTokenPublisher {
                return publisher
            }
            
            if let refreshToken = refreshToken, forceRefresh {
                refreshTokenPublisher = AuthenticationService().refreshAccessTokenPublisher(refreshToken: refreshToken)
                if let refreshTokenPublisher = refreshTokenPublisher {
                    return refreshTokenPublisher
                }
            }
            
            //If Access token exists and the token is valid simply return the token
            if let accessToken = accessToken {
                return Just(accessToken)
                    .setFailureType(to: CoreError.self)
                    .eraseToAnyPublisher()
            }
            
            return Fail(error: CoreError(type:.loginRequired))
                .eraseToAnyPublisher()
        }
        
    }
    
    ///Access Token request as described [here](https://tools.ietf.org/html/rfc6749#section-4.1.3)
    func getAccessAndRefreshToken(code:String, codeVerifier:String, redirectUri:String, clientId:String, completion: @escaping( _ error: CoreError? ) -> Void){
        let authenticationService = AuthenticationService()
        request = authenticationService.getAccessRefreshToken( code: code, redirectUri:redirectUri, codeVerifierKey:codeVerifier) { (authenticationModel, error) in
            if let authenticationModel = authenticationModel {
                self.storeAccessRefreshTokens( authenticationModel: authenticationModel)
                completion(nil)
                return
            } else {
                completion(error)
            }
        }
    }
    
    ///set the access and refresh tokens from an authentication model.
    func storeAccessRefreshTokens( authenticationModel:AuthenticationModel){
        
            self.accessToken = authenticationModel.accessToken
            self.refreshToken = authenticationModel.refreshToken
            isAccessTokenValid = true
        
        
    }
    
    ///Clear the refresh token publisher.
    func clearRefreshTokenPublisher(){
        refreshTokenPublisher = nil
    }
    
    //MARK: - Delete Tokens
    func deleteTokens(){
        clearTokensInKeyChain()
    }
    
    fileprivate func clearTokensInKeyChain(){
        KeychainHelper.deleteKeyChainItem(.accessToken)
        KeychainHelper.deleteKeyChainItem(.refreshToken)
    }
    
}


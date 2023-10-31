//
//  AuthenticationManager.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation
import Combine

/**
 The authentication manager provides access to the access and refresh tokens as well as handles the refreshing of the access token.
 - Note:
    Retrieving and/or refreshing of the accesstoken occurs in a synchronous queue so that if a refreshing of the access is needed all other threads that need the access token will need to wait until either the refreshing of the access token succeeds or fails.
 */

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
    
//    ///Simple check used to determine if the user is signed in or not.
//    public var isSignedIn:Bool {
//        get {
//            return UserHelper.getCurrentUserFromRealm() != nil
//        }
//    }
//
//    public var offlinePin:String {
//        get{
//            if let uniqueKey = userSubscriptionUniqueKey, let pincode = KeychainHelper.fetchWithString(uniqueKey) {
//                return pincode
//            }
//            return ""
//        }
//        set {
//            KeychainHelper.storeWithString(userSubscriptionUniqueKey ?? "", token: newValue)
//        }
//    }
//
//    public var isOfflineAuthenticationEnabled: Bool {
//        return (offlinePin.count > 0 || isTouchIdEnabled)
//    }
    
//    public var isTouchIdEnabled:Bool {
//        set {
//            UserDefaults.appGroup?.set(newValue, forKey: userSubscriptionUniqueKey ?? "")
//        }
//        get {
//            if let uniqueKey = userSubscriptionUniqueKey,let appgroup = UserDefaults.appGroup {
//                return appgroup.bool(forKey: uniqueKey)
//            }
//            return false
//        }
//    }
    
    public var isBiometricDisabled:Bool {
        set {
            UserDefaults.appGroup?.set(newValue, forKey: BIOMETRICS_DISABLED )
        }
        get {
            if let appgroup = UserDefaults.appGroup {
                return appgroup.bool(forKey: BIOMETRICS_DISABLED)
            }
            return false
        }
    }

    var refreshTokenPublisher:AnyPublisher<String, CoreError>?
    
    /**
     Get access token publisher.
     - Note: Since the function is performed in the accessQueue syncronously if refreshTokenPublisher already exists simply return it. Since this publisher is shared once access token is either taken from the keychain or from a refresh access tokens all subsequent publishers will get the same access token.
            
     */
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
    ///Remove all tokens from the keychain.
    func deleteTokens(){
        clearTokensInKeyChain()
    }
    
    fileprivate func clearTokensInKeyChain(){
        KeychainHelper.deleteKeyChainItem(.accessToken)
        KeychainHelper.deleteKeyChainItem(.refreshToken)
    }
    
//    var userSubscriptionUniqueKey:String? {
//        if let userModel = UserHelper.getCurrentUserFromRealm() {
//            var key = userModel.id
//            key.append(EnvironmentManager.shared.tenantId)
//            return key
//        }
//        return nil
//    }
}


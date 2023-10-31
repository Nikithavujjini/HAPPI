//
//  AuthenticationRouter.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation

class AuthenticationRouter:CoreAbstractRouter {
   
    
    enum RouterType {
        /// get the access and refesh token based on the authentication code
        case getAccessRefreshToken(code:String, redirectUri:String, codeVerifierKey:String)
        
        /// refresh the access token with a refresh token
        case refreshAccessToken(refreshToken:String)
    }
    
    var routerType:RouterType
    
    override var hostWithPathUrl: URL? {
        switch routerType {
        case .getAccessRefreshToken(_, _, _), .refreshAccessToken(_):
            
            guard let urlString = EnvironmentManager.shared.currentEnvironment?.tokenUrl, let url = URL(string: urlString) else { return nil }
            return url
        }
    }
    
    override var queryParameters: HTTPParameters {
        switch routerType {
        case .getAccessRefreshToken(let code, let redirectUri, let codeVerifierKey):
            return ["grant_type" : "authorization_code",
                    "code" : code,
                    "redirect_uri" : redirectUri,
                    "code_verifier" : codeVerifierKey,
                    "client_id" : OAUTH2_CLIENT_ID]
        case .refreshAccessToken(let refreshToken):
            var params = ["grant_type" : "refresh_token",
                    "refresh_token" : refreshToken,
                    "client_id" : OAUTH2_CLIENT_ID]
            return params
        }
    }
    
    override var needsAuthentication: Bool {
        switch routerType {
        case .getAccessRefreshToken(_, _, _), .refreshAccessToken(_):
            return false
        }
    }
    
    override var httpMethod: HTTPMethod {
        switch routerType {
        case .getAccessRefreshToken(_, _, _), .refreshAccessToken(_):
            return .post
        }
    }
    
    override var acceptContentType: HTTPContentType? {
        switch routerType {
        case .getAccessRefreshToken(_, _, _), .refreshAccessToken(_):
            return nil
        }
    }
    
    override var contentType: HTTPContentType {
        switch routerType {
        case .getAccessRefreshToken(_, _, _), .refreshAccessToken(_):
            return .urlEncoding
        }
    }
    
    init(routerType:RouterType){
        self.routerType = routerType
     
    }
    
}



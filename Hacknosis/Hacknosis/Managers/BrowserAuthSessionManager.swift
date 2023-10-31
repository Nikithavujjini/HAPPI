//
//  BrowserAuthSessionManager.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation
import AuthenticationServices
class BrowserAuthSessionManager:NSObject {
    
    
    //MARK: - Variables
    static let shared:BrowserAuthSessionManager = BrowserAuthSessionManager()
    fileprivate var authenticationSession: ASWebAuthenticationSession?
    fileprivate var completionHandler:((CoreError?) -> Void)?
    fileprivate var state: String?
    fileprivate var codeVerifierKey: String?
    fileprivate var oauthRedirectURL: String
    
    fileprivate let APP_SCHEME:String = "com.opentext.sha" //Recommended scheme based on https://tools.ietf.org/html/rfc7595#section-3.8
    fileprivate let OAUTH2_REDIRECT_URL_PATH:String = "oauth2redirect" //recommended uri based on https://tools.ietf.org/html/rfc8252#section-7.1
    fileprivate let OAUTH2_PKCE_CODE_CHALLENGE_METHOD:String = "S256" //Recommended method based on https://tools.ietf.org/html/rfc7636#section-4.2
    fileprivate let OAUTH_CLIENT_DATA:String = "subName="
    let SCOPES:[String] = ["readwrite", "otds:groups", "search"]
    
    //MARK: - Initialization
    fileprivate override init(){
        oauthRedirectURL = APP_SCHEME + ":/" + OAUTH2_REDIRECT_URL_PATH
        super.init()
    }
    
    func startBrowserAuthSession(completion: @escaping(_ error:CoreError? ) -> Void){
        guard let currentEnvironment = EnvironmentManager.shared.currentEnvironment else {
            completion(CoreError(message: "ERROR_ENVIRONMENT_NOT_FOUND"))
            return
        }
        var authenticationURL: URL?
        var scopeData = EnvironmentManager.shared.subscriptionName
        var tenantID:String? = nil
        
            tenantID = EnvironmentManager.shared.tenantId
            authenticationURL = URL(string: currentEnvironment.authenticationUrl)
       
        
        guard let authenticationURL, var authenticationURLComponents = URLComponents(url: authenticationURL, resolvingAgainstBaseURL: false) else { completion(CoreError(message: "ERROR_ENVIRONMENT_NOT_FOUND")); return }
        completionHandler = completion
        
        //Use state to protect against CSRF as described in https://tools.ietf.org/html/rfc6749#section-10.12 and https://tools.ietf.org/html/rfc8252#section-8.9
        state = CryptoHelper.randomURLSafeStringWithSize(size: 32)! //random number that conforms with https://tools.ietf.org/html/rfc6749#section-10.10
        //This is to implement the Proof Key for Code Exchange (PKCE) as described in https://tools.ietf.org/html/rfc7636
        codeVerifierKey = CryptoHelper.randomURLSafeStringWithSize(size: 32)! //random number that conforms with https://tools.ietf.org/html/rfc6749#section-10.10
        let codeChallenge = generateCodeChallenge(codeVerifierKey: codeVerifierKey!)

        //Setup query parameters as described in https://tools.ietf.org/html/rfc6749#section-4.1.1
        var authenticationURLQueryItems:[URLQueryItem] = [
            URLQueryItem(name: "client_id", value: OAUTH2_CLIENT_ID), //as described in https://tools.ietf.org/html/rfc6749#section-2.2
            URLQueryItem(name: "response_type", value: "code"), //must send response type "code" for the authorization flow as described in https://tools.ietf.org/html/rfc6749#section-3.1.1
            URLQueryItem(name: "state", value: state!), //send state as described in https://tools.ietf.org/html/rfc8252#section-8.9
            URLQueryItem(name: "redirect_uri", value: oauthRedirectURL), //as described in https://tools.ietf.org/html/rfc6749#section-3.1.2
            URLQueryItem(name: "code_challenge", value: codeChallenge), //send code challenge as described in https://tools.ietf.org/html/rfc7636#section-4.3
            URLQueryItem(name: "code_challenge_method", value: OAUTH2_PKCE_CODE_CHALLENGE_METHOD), //send code challenge method as described in https://tools.ietf.org/html/rfc7636#section-4.3
        ]
        
        if let tenantID {
            authenticationURLQueryItems.append(URLQueryItem(name: "client_data", value: OAUTH_CLIENT_DATA + tenantID))
        }
        
   
            authenticationURLQueryItems.append(generateScopeQueryItem(subscriptionName: scopeData))
        
        authenticationURLComponents.queryItems = authenticationURLQueryItems
        guard let authenticationFinalURL = authenticationURLComponents.url else { completion(CoreError(message: "ERROR_ENVIRONMENT_NOT_FOUND")); return }
        var delay = 0.0
        if authenticationSession != nil {
            authenticationSession?.cancel()
            delay = 0.5
        }
        
        //this delay is to close the existing browser popup
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.authenticationSession = ASWebAuthenticationSession(url: authenticationFinalURL, callbackURLScheme: self.APP_SCHEME ) { [weak self] (url, error) in
                guard let self = self else { return }
                self.authenticationSessionCompletion(url:url, error:error)
            }
            //Ephemeral means that the session cookies will not be saved. This makes it easier to logout and login as a different user as the session won't autologin as the same user.
            self.authenticationSession?.prefersEphemeralWebBrowserSession = true
            self.authenticationSession?.presentationContextProvider = self
            self.authenticationSession?.start()
        }
        
    }
    
    fileprivate func generateScopeQueryItem(subscriptionName:String) -> URLQueryItem {
        var scopeValue = "subscription:" + subscriptionName
//        for scope in SCOPES {
//            scopeValue = scopeValue + " " + scope
//        }
        return URLQueryItem(name: "scope", value: scopeValue)
    }
    
    fileprivate func authenticationSessionCompletion( url:URL?, error:Error?){
        if let url = url, error == nil {
            resumeBrowserAuthSession(url:url)
        } else {
            let nsError = error as NSError?
            if nsError?.domain == "com.apple.AuthenticationServices.WebAuthenticationSession" && nsError?.code == 1/*Means the Login process was cancelled by the user*/ {
               
                callCompletionHandler(error: CoreError(type: .authenticationCancelled))
            } else {
                callCompletionHandler(error: CoreError(nserror: nsError))
            }
        }
        authenticationSession = nil
    }
    
    fileprivate func callCompletionHandler(error:CoreError?){
        completionHandler?(error)
       // resetAuthenticationVariables()
    }
    
    fileprivate func generateCodeChallenge( codeVerifierKey:String ) -> String {
        let sha256Verifier = CryptoHelper.sha256(string: codeVerifierKey)
        return CryptoHelper.encodeBase64urlNoPadding(data: sha256Verifier)
    }
    
    @discardableResult
    fileprivate func resumeBrowserAuthSession(url:URL ) -> Bool {
        //check if valid url
        guard let responseURLComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), let responseUrlScheme = responseURLComponents.scheme else { callCompletionHandler(error:CoreError(message: "ERROR_LOGIN_GENERIC")); return true }
        //check if url matches the OAuth redirect url as described in https://tools.ietf.org/html/rfc8252#section-8.10
        let responseUrlPath = responseURLComponents.path
        let urlHost = responseUrlScheme + ":" + responseUrlPath
        guard urlHost == oauthRedirectURL else { callCompletionHandler(error:CoreError(message: "ERROR_LOGIN_GENERIC")); return true }
        //check the state to make sure that it's the same state that was sent originally as described RFC-6749 Section 10.12 - https://tools.ietf.org/html/rfc6749#section-10.12
        guard url.getQueryString(parameter: "state") == state else { callCompletionHandler(error:CoreError(message: "ERROR_LOGIN_GENERIC")); return true }
        //check if "code" was in the response
        if let errorDescription = url.getQueryString(parameter: "error_description") {
            if errorDescription.contains("Missing+partition+for+subscription") {
                callCompletionHandler(error: CoreError(type:.subscriptionNotFound))
            } else {
                callCompletionHandler(error: CoreError(message: errorDescription))
            }
        } else if let code = url.getQueryString(parameter: "code") {
            AuthenticationManager.shared.getAccessAndRefreshToken( code: code, codeVerifier: codeVerifierKey!, redirectUri:oauthRedirectURL, clientId:OAUTH2_CLIENT_ID, completion: { [weak self] (_ error) in
                guard let self = self else { return }
                self.callCompletionHandler(error: error != nil ? CoreError(message: "ERROR_LOGIN_GENERIC") : nil)
            })
        } else {
            callCompletionHandler(error:CoreError(message: "ERROR_LOGIN_GENERIC"))
        }
        return true
    }
    
}

extension BrowserAuthSessionManager:ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }
}


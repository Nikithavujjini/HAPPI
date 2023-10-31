//
//  AuthenticationService.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation
import Combine

class AuthenticationService:CoreAbstractService {

    /**
    Get access and refresh token using the authentication code
     - parameters:
        - code: authentication code
        - redirectUri: Oauth redirect uri initially used to get the authentication code for this app.
        - codeVerifierKey: Used for PKCE
        - completion: a closure that is called once the request is made.
        - authentication: If the reques is successful the authentication should be populated with the authentication object with the access andf refresh tokens
        - error: If there's an error the error paramter will be populated.
     */
    @discardableResult
    func getAccessRefreshToken(code:String, redirectUri:String, codeVerifierKey:String, completion:@escaping(_ authentication:AuthenticationModel?, _ error:CoreError?) -> Void) -> AnyCancellable? {
        let router = AuthenticationRouter(routerType: .getAccessRefreshToken(code: code, redirectUri:redirectUri, codeVerifierKey:codeVerifierKey))
        guard let publisher = callAPI(router: router) else { return nil }
        let cancellable = publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: AuthenticationModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completionHandler in
                self.handleCompletionHandler(completionHandler: completionHandler, completion:completion)
            }, receiveValue: { (authenticationModel) in
                completion(authenticationModel, nil)
            })

        return cancellable
    }


    func refreshAccessTokenPublisher(refreshToken:String) -> AnyPublisher<String, CoreError>? {
        guard let publisher = callAPI(router: AuthenticationRouter(routerType: .refreshAccessToken(refreshToken: refreshToken))) else { return nil }
        return publisher
            .share()
            .tryMap { response in
                if let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode == 400 {
                    if let errorModel = try? JSONDecoder().decode(ErrorModel.self, from: response.data), errorModel.error == "ERROR_INVALID_GRANT" {
                        
                         //   LogoutHelper.logout()
                            throw CoreError(type: .loginRequired)
                        
                    }
                }
                return response.data
            }
            .decode(type: AuthenticationModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { authentication  in
                AuthenticationManager.shared.storeAccessRefreshTokens(authenticationModel: authentication)
            }, receiveCompletion: { error in
                AuthenticationManager.shared.clearRefreshTokenPublisher()
            })
            .mapError({ error in
                if let error = error as? CoreError {
                    return error
                }
                return CoreError(message: error.localizedDescription)
            })
            .map({ anthenticationModel -> String in
                anthenticationModel.accessToken
            })
            .eraseToAnyPublisher()
    }


}


//
//  CoreAbstractService.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation
import Combine

class CoreAbstractService: CoreServiceProtocol {
    
    func handleCompletionHandler<T:Any>(completionHandler:((Subscribers.Completion<Error>)), completion:@escaping(_ object:T?, _ error:CoreError?) -> Void){
        switch completionHandler {
        case .failure(let error as CoreError):
            guard error.type != .loginRequired else { return }
            completion(nil, error)
            break
        case .failure(let error):
            completion(nil, CoreError(nserror: error as NSError))
            break
        case .finished:
            break
        }
    }
    
    func callAPI(router: CoreRouterProtocol) -> AnyPublisher<URLSession.DataTaskPublisher.Output, CoreError>? {
        guard NetworkReachability.shared.isConnected, let urlRequest = router.asURLRequest() else { return nil }
        
        var dataTaskPublisher:AnyPublisher<URLSession.DataTaskPublisher.Output, CoreError>?
        let session = NetworkSessionManager.shared.getSession(sessionType: router.urlSessionType)
        
        if router.needsAuthentication {
            var accessTokenPublisher: AnyPublisher<String, CoreError>
            
            
            accessTokenPublisher = AuthenticationManager.shared.getAccessTokenPublisher()
            
            
            dataTaskPublisher = accessTokenPublisher
            
                .flatMap({ (accessToken) in
                    return session.publisher(urlRequest: urlRequest, accessToken:accessToken)
                })
            
                .tryMap({ response in
                    guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode != 401 else { throw CoreError(type: .authenticationFailed) }
                    return response
                })
            
                .mapError({ error in
                    return error as! CoreError
                })
            
                .catch({ error -> AnyPublisher<URLSession.DataTaskPublisher.Output, CoreError> in
                    if error.type == .authenticationFailed {
                        
                        return AuthenticationManager.shared.getAccessTokenPublisher(forceRefresh:true)
                            .flatMap({ accessToken in
                                return session.publisher(urlRequest: urlRequest, accessToken: accessToken)
                            })
                            .eraseToAnyPublisher()                        
                    } else {
                        return Fail(error: error).eraseToAnyPublisher()
                    }
                })
                    .eraseToAnyPublisher()
        } else {
            dataTaskPublisher = session
                .publisher(urlRequest: urlRequest, accessToken: nil)
                .eraseToAnyPublisher()
        }
        
        return dataTaskPublisher?
            .receive(on: router.receiveOnQueue)
            .eraseToAnyPublisher()
    }
    
    
    func callUploadDocumentAPI(router: CoreRouterProtocol, fileURL:URL, session:CoreURLSession, taskDescription:String) -> AnyPublisher<URLSession.UploadTaskPublisher.Output, CoreError>? {
        
        guard let urlRequest = router.asURLRequest() else { return nil }
        
        var uploadTaskPublisher:AnyPublisher<URLSession.UploadTaskPublisher.Output, CoreError>?
        
        if router.needsAuthentication {
            //            uploadTaskPublisher = AuthenticationManager.shared.getAccessTokenPublisher()
            var accessTokenPublisher: AnyPublisher<String, CoreError>
            
            //            if let sharedLink {
            //                accessTokenPublisher = sharedLink.getAccessTokenPublisher()
            //            } else {
            accessTokenPublisher = AuthenticationManager.shared.getAccessTokenPublisher()
            // }
            uploadTaskPublisher = accessTokenPublisher
            
                .flatMap({ (accessToken) in
                    return session.uploadPublisher(urlRequest: urlRequest, accessToken:accessToken, fromFile: fileURL, taskDescription: taskDescription)
                })
            
                .tryMap({ response in
                    guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode != 401 else { throw CoreError(type: .authenticationFailed) }
                    return response
                })
            
                .mapError({ error in
                    return error as! CoreError
                })
            
                .catch({ error -> AnyPublisher<URLSession.UploadTaskPublisher.Output, CoreError> in
                    if error.type == .authenticationFailed {
                        
                        return AuthenticationManager.shared.getAccessTokenPublisher(forceRefresh:true)
                            .flatMap({ accessToken in
                                return session.uploadPublisher(urlRequest: urlRequest, accessToken:accessToken, fromFile: fileURL, taskDescription: taskDescription)
                            })
                            .eraseToAnyPublisher()
                        
                    } else {
                        return Fail(error: error).eraseToAnyPublisher()
                    }
                })
                    .eraseToAnyPublisher()
                        
        } else {
            
            uploadTaskPublisher = session
                .uploadPublisher(urlRequest: urlRequest, accessToken: nil, fromFile: fileURL, taskDescription: taskDescription)
                .eraseToAnyPublisher()
        }
        
        return uploadTaskPublisher?
            .receive(on: router.receiveOnQueue)
            .eraseToAnyPublisher()
    }
    
    
    func callDownloadDocumentAPI(router: CoreRouterProtocol, session:CoreURLSession) -> AnyPublisher<URLSession.DownloadTaskPublisher.Output, CoreError>? {
        
        guard let urlRequest = router.asURLRequest() else { return nil }
        
        var downloadTaskPublisher:AnyPublisher<URLSession.DownloadTaskPublisher.Output, CoreError>?
        
        if router.needsAuthentication {
            var accessTokenPublisher: AnyPublisher<String, CoreError>
            
            //            downloadTaskPublisher = AuthenticationManager.shared.getAccessTokenPublisher()
            
            accessTokenPublisher = AuthenticationManager.shared.getAccessTokenPublisher()
            
            downloadTaskPublisher = accessTokenPublisher
                .flatMap({ (accessToken) in
                    return session.downloadPublisher(urlRequest: urlRequest, accessToken:accessToken)
                })
            
                .tryMap({ response in
                    guard let httpURLResponse = response.response as? HTTPURLResponse, httpURLResponse.statusCode != 401 else { throw CoreError(type: .authenticationFailed) }
                    return response
                })
            
                .mapError({ error in
                    return error as! CoreError
                })
            
                .catch({ error -> AnyPublisher<URLSession.DownloadTaskPublisher.Output, CoreError> in
                    if error.type == .authenticationFailed {
//                        if let sharedLink = self.sharedLink {
//                            return sharedLink.getAccessTokenPublisher(forceRefresh: true)
//                                .flatMap({ accessToken in
//                                    return session.downloadPublisher(urlRequest: urlRequest, accessToken: accessToken)
//                                })
//                                .eraseToAnyPublisher()
//                        } else {
                            return AuthenticationManager.shared.getAccessTokenPublisher(forceRefresh:true)
                                .flatMap({ accessToken in
                                    return session.downloadPublisher(urlRequest: urlRequest, accessToken: accessToken)
                                })
                                .eraseToAnyPublisher()
                        
                    } else {
//                        if CoreDownloadManager.shared.sslErrorOccured {
//                            return Fail(error: CoreError.init(title: SSL_TITLE_ERROR,message: SSL_ERROR)).eraseToAnyPublisher()
//                        }
                        return Fail(error: error).eraseToAnyPublisher()
                    }
                })
                    .eraseToAnyPublisher()
                        
        } else {
            downloadTaskPublisher = session
                .downloadPublisher(urlRequest: urlRequest, accessToken: nil)
                .eraseToAnyPublisher()
        }
        
        return downloadTaskPublisher?
            .receive(on: router.receiveOnQueue)
            .eraseToAnyPublisher()
    }
    
    
    
    func checkOutput(output:URLSession.DataTaskPublisher.Output) throws -> JSONDecoder.Input {
        guard let response = output.response as? HTTPURLResponse else {
            throw CoreError(message: "ERROR_UNKNOWN_ERROR")
        }
        
        //  collectCSRFToken(from: response)
        
        /*do {
         let json = try JSONSerialization.jsonObject(with: output.data, options: [])
         print(json)
         } catch let error {
         print(error.localizedDescription)
         print(String(data: output.data, encoding: .utf8) ?? "")
         }*/
        
        guard response.isResponseOK() else {
            if let errorModel = try? JSONDecoder().decode(ErrorModel.self, from: output.data) {
                throw CoreError(errorModel: errorModel, statusCode: response.statusCode)
            } else {
                throw CoreError(httpResponse: response)
            }
        }
        return output.data
    }
    
    func checkUploadDocumentOutput(output:URLSession.UploadTaskPublisher.Output) throws -> (data:Data?, progress:Double?) {
        
        if let progress = output.progress {
            return (nil, progress)
        }
        
        guard let response = output.response as? HTTPURLResponse else {
            throw CoreError(message: "ERROR_UNKNOWN_ERROR")
        }
        
        collectCSRFToken(from: response)
        
        guard response.isResponseOK() else {
            let error = CoreError(httpResponse: response)
            error.status = response.statusCode
            
            if response.statusCode == 404 {
                error.message =  "FILE_DONT_EXIST"
            }
            throw error
        }
        return (output.data, nil)
    }
    
    func checkDownloadDocumentOutput(output:URLSession.DownloadTaskPublisher.Output) throws -> (url:URL?, progress:Double?) {
        
        if let progress = output.progress {
            return (nil, progress)
        }
        
        guard let response = output.response as? HTTPURLResponse else {
            throw CoreError(message: "ERROR_UNKNOWN_ERROR")
        }
        
        collectCSRFToken(from: response)
        
        guard response.isResponseOK() else {
            let error = CoreError(httpResponse: response)
            error.status = response.statusCode

            if response.statusCode == 404 {
                error.message =  "FILE_DONT_EXIST"
            }
            throw error
        }
        return (output.url, nil)
    }
    
    func collectCSRFToken(from response:HTTPURLResponse) {
        if let cookies = HTTPCookieStorage.shared.cookies(for: response.url!) , cookies.count > 0 {
            for cookie in cookies {
                if cookie.name == CSRF_COOKIE {
                    NetworkSessionManager.shared.csrfToken = cookie.value
                }
            }
        }
    }
    
    func handleDownloadCompletionHandler<T:Any>(completionHandler:((Subscribers.Completion<Error>)), completion:@escaping(_ object:T?, _ progress:Double?, _ error:CoreError?) -> Void){
        switch completionHandler {
        case .failure(let error as CoreError):
            guard error.type != .loginRequired else { return }
            completion(nil, nil, error)
            break
        case .failure(let error):
            completion(nil, nil, CoreError(nserror: error as NSError))
            break
        case .finished:
            break
        }
    }
}

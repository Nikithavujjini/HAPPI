//
//  UserService.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//

import Foundation
import Combine

class UserService:CoreAbstractService {
    func publisher(for type: UserRouter.RouterType)-> AnyPublisher<URLSession.DataTaskPublisher.Output, CoreError>? {
        var router: UserRouter
//        if let sharedLink {
//            router = UserRouter(routerType: type, sharedLink: sharedLink)
//        } else {
            router = UserRouter(routerType: type)
//        }
        return callAPI(router: router)
    }
    
    
    @discardableResult
    func getCurrentUser(completion:@escaping(_ user:UserModel?, _ error:CoreError?) -> Void) -> AnyCancellable? {
        guard let publisher = publisher(for: .getCurrentUser) else { return nil }

        //guard let publisher = callAPI(router: UserRouter(routerType: .getCurrentUser)) else { return nil }
        let cancellable = publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: UserModel.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completionHandler in
                self.handleCompletionHandler(completionHandler: completionHandler, completion:completion)
            }, receiveValue: { (userModel) in
                completion(userModel, nil)
            })
        
        return cancellable
    }
    
    /**
     Get the user with user id.
     - parameters:
        - userId: id of the requesting user
        - completion:once the request is complete the completion closure will be called.
        - user:If successful then the user object will be populated.
        - error: if there's an error the error parameter will be populated.
     */
    @discardableResult
    func getUser(userId:String?) -> AnyPublisher<UserModel, Error>? {
        guard let userId = userId, !userId.isEmpty else { return nil }
        guard let publisher = publisher(for: .getUser(userId: userId)) else { return nil }
        return publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: UserModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    /**
     Get the current user perspective object.
     - parameters:
        - completion:once the request is complete the completion closure will be called.
        - userPerspective:If successful then the userPerspective object will be populated.
        - error: if there's an error the error parameter will be populated.
     */
  
    
    
    
}

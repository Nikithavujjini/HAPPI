//
//  UserRouter.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//
import Foundation

/**
 Used for user routes
 */
class UserRouter:CoreAbstractRouter {

    enum RouterType {
        ///Get current user
        case getCurrentUser
        //Get user with id
        case getUser(userId:String)
        ///Get current user perspective
        case getCurrentUserPerspective
    }
    
    var routerType:RouterType
    
    ///This part of the url should just include the host.
    override var hostUrl:URL? {
//        if let sharedLink {
//            return sharedLink.currentEnvironmentUrl
//        }
        guard let hostUrl = EnvironmentManager.shared.cmsUrl else { return nil }
        return hostUrl
    }
    
    override var hostWithPathUrl: URL? {
        guard var apiUrl = hostUrl else { return nil }
        switch routerType {
        case .getCurrentUser:
            apiUrl.appendPathComponent("current-user")
            return apiUrl
            
        case .getUser(let userId):
            apiUrl.appendPathComponent("user")
            apiUrl.appendPathComponent(userId)
            return apiUrl
            
        case .getCurrentUserPerspective:
            apiUrl.appendPathComponent("currentuser/perspective")
            return apiUrl
        }
    }
    
    init(routerType:RouterType){
       // self.sharedLink = sharedLink
        self.routerType = routerType
        super.init()
    }
    
}


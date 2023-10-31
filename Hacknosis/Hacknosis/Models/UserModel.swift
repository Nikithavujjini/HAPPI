//
//  UserModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//

import Foundation
import RealmSwift
/**
 Used to store the user information
 */
final class UserModel:Object, Decodable, Identifiable {
    
    //MARK: - Persisted variables
    @Persisted var firstName:String?
    @Persisted var lastName:String?

    @Persisted var email:String?
    @Persisted var isCurrentUser:Bool = false
    @Persisted var isDoctor:Bool = false
    @Persisted var tenantUserId:String?
    @Persisted var subscriptionUserId:String
    
    enum CodingKeys: String, CodingKey {
       // case id
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case tenantUserId = "tenant_user_id"
        case subscriptionUserId = "subscription_user_id"
    }
}

final class UserModelForGroup:Object, Decodable, Identifiable {
    
    //MARK: - Persisted variables

    @Persisted var email:String?
    @Persisted var isCurrentUser:Bool = false
   
    @Persisted var subscriptionUserStatus: Bool?
    
    enum CodingKeys: String, CodingKey {

        case email
        case subscriptionUserStatus = "subscription_user_status"
    }
}

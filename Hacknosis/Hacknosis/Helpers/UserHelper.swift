//
//  UserHelper.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//

import Foundation
import RealmSwift

class UserHelper {
    
    /**
     Setup the current user in the Realm database
     - parameters:
        - user: user model
     */
    static func setupCurrentUser(user:UserModel, isDoctor: Bool){
        let realm = try? Realm()
        user.isCurrentUser = true
        user.isDoctor = isDoctor
        try? realm?.safeWrite {
           
            realm?.add(user)
        }
    }
    
    /**
     Get current user from Realm
     */
    static func getCurrentUserFromRealm() -> UserModel? {
        guard let realm = try? Realm() else { return nil }
        return realm.objects(UserModel.self).filter("isCurrentUser == true").first
    }
    
    static func isCurrentUserADoctor() -> Bool {
        guard let realm = try? Realm() else { return false }
         let user = realm.objects(UserModel.self).filter("isDoctor == true").first
        if user != nil {
            NotificationCenter.default.post(name: .userSuccess, object: nil)
        }
        return user != nil
    }
    
    static func getCurrentUserTenantId() -> String? {
        if let user = getCurrentUserFromRealm() {
            return user.tenantUserId
        }
        return nil
    }
    

    static func clearCurrentUserFromRealm() {
        guard let realm = try? Realm() else { return }
        if let user = realm.objects(UserModel.self).filter("isCurrentUser == true").first {
            try? realm.safeWrite {
                realm.delete(user)
            }
        }
    }
}


//
//  ProfileViewModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 25/10/23.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var user: UserModel? = nil
    @Published var isShowingToast = false
//    init(user: UserModel) {
//        self.user = user
//    }
    
    func onViewAppear() {
        fetchUserDetails()
    }
    func fetchUserDetails() {
        if let user =  UserHelper.getCurrentUserFromRealm() {
            self.user = user
        }
    }
}

//
//  LoginViewModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 11/10/23.
//

import Foundation
import Combine
import UIKit

class LoginViewModel: ObservableObject {
    
    @Published var environments:[EnvironmentModel] = EnvironmentManager.shared.environments
    @Published var environmentTitle:String = "select environment"
    @Published var isShowingEnvironmentMenu:Bool = false
    var request:AnyCancellable?
    @Published var isDoctoreSignedIn: Bool = false
    @Published var isLoading: Bool = false
    var usersFromGroup: [UserIdentity] = []
    var requests:Set<AnyCancellable> = Set<AnyCancellable>()
    
    //@Published var isLoading:Bool = false
    
    @Published var subscriptionError:Bool = false
    @Published var shouldShowAlert = false
    @Published var alertTitle:String = "EMPTY_STRING"
    @Published var alertMessage:String = "EMPTY_STRING"
    @Published var selectedEnvironmentIndex = 0
    @Published var isShowingAuthenticationScreen = false
    @Published var isLoadingSharedNode = false
    @Published var isSharedNodeError: Bool = false
    @Published var isShowingViewer:Bool = false
    //@Published var selectedNode:NodeModel? = nil
    @Published var isShortcutSelected:Bool = false
    @Published var subscriptionNameInput:String = "" {
        didSet {
            if oldValue != subscriptionNameInput {
                subscriptionError = false
                shouldShowAlert = false
            }
        }
    }
    
    func updateCurrentEnvironment(environmentKey:String){
        EnvironmentManager.shared.updateCurrentEnvironment(environmentKey: environmentKey)
        updateEnvironmentTitle()
        
    }
    
    func showEnvironmentMenu(){
        isShowingEnvironmentMenu = true
    }
    
    func updateEnvironmentTitle(){
        guard let environmentNameLocalizedKey = EnvironmentManager.shared.currentEnvironment?.nameLocalizedKey,  EnvironmentManager.shared.currentEnvironment?.isHidden == false else { return }
       environmentTitle = environmentNameLocalizedKey
   }
    
    func removeInputFocus() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
    
    func showBrowserAuthentication(){
        shouldShowAlert = false
        subscriptionError = false
        isShowingAuthenticationScreen = true
        EnvironmentManager.shared.subscriptionName = subscriptionNameInput.trimmingCharacters(in: .whitespacesAndNewlines)

        BrowserAuthSessionManager.shared.startBrowserAuthSession( completion: { [weak self] error in
            if let error = error {
                if error.type != .authenticationCancelled {
                    self?.showError(error: error)
                }
            } else {
                self?.getCurrentUser()
            }
            self?.isShowingAuthenticationScreen = false
        })
    }
    
//    func getCurrentUser(){
//       isLoading = true
////       let userService = UserService()
////       request = userService.getCurrentUser { [weak self] user, error in
////           DispatchQueue.main.async {
////               print("\(user)user here error \(error?.message)")
////               guard let user = user else { self?.showError(error: CoreError(message: "ERROcs/R_UNKNOWN_ERROR")); return }
////               guard error == nil else { self?.showError(error: error!); return }
////               UserHelper.setupCurrentUser(user: user)
//               NotificationCenter.default.post(name: .showHome, object: nil)
//
////           }
////       }
//   }
    
    func getCurrentUser(){
       isLoading = true
       let userService = UserService()
       request = userService.getCurrentUser { [weak self] user, error in
           DispatchQueue.main.async {
               guard let user = user else { self?.showError(error: CoreError(message: "ERROR_UNKNOWN_ERROR")); return }
             //  UserHelper.setupCurrentUser(user: user, isDoctor: false)
               guard error == nil else { self?.showError(error: error!); return }
               self?.fetchUsersInGroup(user: user,onCompletion: { usersInGroup, isDoctor in
                   if usersInGroup.count > 0 {
                       UserHelper.setupCurrentUser(user: user, isDoctor: isDoctor)
                       UserHelper.isCurrentUserADoctor()
                   }
               })
               
               NotificationCenter.default.post(name: .showHome, object: nil)
           }
       }
   }
    
    
    
    func fetchUsersInGroup(user: UserModel, onCompletion: @escaping(_ usersInGroup: [UserIdentity], _ isDoctor: Bool) -> Void) {
        isLoading = true
        let fileService = FilesService()
        
        let request =  fileService.getMembersInGroup(groupId: "b5a057cc-ab41-496b-b404-003d96ccbced") { userCollection, error in
            if let userCollection = userCollection, (userCollection.page ?? 0) > 0 {
                for user in userCollection._embedded.collection {
                    if let userIdentity = user.user_identity {
                        self.usersFromGroup.append(userIdentity)
                    }
                }
                
                self.isLoading = false
                let user =  self.usersFromGroup.filter({$0.email == user.email}).last
                if user != nil {
                    self.isDoctoreSignedIn = true
                }
                onCompletion(self.usersFromGroup, self.isDoctoreSignedIn)
            } else {
                onCompletion([], false)
            }
            
        }
        
        if let request {
            requests.insert(request)
        }
    }
    
    
    
    
    func showError(error:CoreError){
        isLoading = false
        guard error.type != .requestCancelled && error.type != .authenticationCancelled else { return }
        alertTitle = error.title
        if error.type == .subscriptionNotFound {
            alertMessage = "ERROR_SUBSCRIPTION_NOT_FOUND"
            subscriptionError = true
        } else {
            alertMessage = error.message
        }
        shouldShowAlert = true
    }
}

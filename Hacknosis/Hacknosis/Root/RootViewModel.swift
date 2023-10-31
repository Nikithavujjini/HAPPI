//
//  RootViewModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//

import SwiftUI
import Foundation

class RootViewModel:ObservableObject {
    
    @Published var isShowingHome:Bool = false
    @Published var skipShortcuts:Bool = false
    @Published var isDeviceRotated:Bool = false
    @Published var isShowingSignatureWeb:Bool = false
    @Published var isDoctorLoggedIn:Bool = false
    
    var usersFromGroup: [UserModel] = []

    
    init() {
        
        isShowingHome = AuthenticationManager.shared.isSignedIn
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleShowHome(_:)),
                                               name: .showHome,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleShowLogin(_:)),
                                               name: .returnToLogin,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: View Life Cycle methods

    func onViewAppear() {

            isShowingHome = AuthenticationManager.shared.isSignedIn

    }
    
    //MARK: Notification Observers
    
    @objc func handleShowLogin(_ notification:Notification){
        DispatchQueue.main.async {
            withAnimation(.linear) {
                self.isShowingHome = false
            }
        }
    }

    @objc func handleShowHome(_ notification:Notification) {
        self.showHome()
    }

    
    fileprivate func showHome() {
        DispatchQueue.main.async {
            withAnimation(.linear) {
                self.isShowingHome = true
            }
        }
    }
    
   

}



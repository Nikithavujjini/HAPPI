//
//  HomeViewModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 17/10/23.
//

import Foundation
class HomeViewModel:AbstractViewModel, ObservableObject {
    var fileService: FilesService?
  //  var nodes: [NodeModel] = []
    @Published var isShowingFilesScreenView: Bool = false
    @Published var isShowingUploadScreenView: Bool = false
    @Published var isShowingProfileScreen: Bool = false
    @Published var isDoctoreSignedIn = false
   // @Published var isLoading: Bool = false
    var usersFromGroup: [UserModelForGroup] = []
    
    override init() {
        super.init()
        self.fileService = FilesService()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleUserSuccess(_:)),
                                               name: .userSuccess,
                                               object: nil)
    }


@objc func handleUserSuccess(_ notification:Notification) {
    DispatchQueue.main.async {
        self.isDoctoreSignedIn = true
        self.objectWillChange.send()
    }
}
    func onViewAppear() {
        Task { [weak self] in
            await self?.getReports()
           // print(self?.nodes)
        }
    }
    
    func getReportsFiltered(type: ScreenType) -> [NodeModel]{
       
        
        if type == .unreviewed {
            return self.nodes.filter({ $0.properties?.reviewed == false })
        } else if type == .reviewed {
            return self.nodes.filter({ $0.properties?.reviewed == true })
        } else if type == .view {
                return nodes
        }
        return []
        
    }
    
    func getUsername() -> String {
        var username = ""
        if let user =  UserHelper.getCurrentUserFromRealm() {
            if let firstName = user.firstName, let lastname = user.lastName {
                username = firstName + " " + lastname
            }
        }
        return username
    }
    
    
   
}

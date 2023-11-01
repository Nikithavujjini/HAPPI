//
//  AbstractViewModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import Foundation
@MainActor
class AbstractViewModel  {
    @Published var isShowingSheet: Bool = false
    @Published var isLoading: Bool = false
    @Published var showUploadView = false
    @Published var uploadType:UploadType = .gallery
    @Published var selectedNode:NodeModel?
    
    @Published var isShowingEmptyList:Bool = false
    
    @Published var nodes:[NodeModel] = []
    @Published var unreviewedNodes:[NodeModel] = []
    @Published var reviewedNodes:[NodeModel] = []
//    @Published var uploadingNodes:[NodeModel] = [NodeModel]()
    
    func getReports() async {
        // guard let nodeId = nodeId else { return }
        let fileService = FilesService()
        DispatchQueue.main.async {
            if self.nodes.count == 0 {
                self.isLoading = true
            }
        }
        Task {
            do {
                let nodeCollection = try await fileService.getReports(rootId: rootFolderid)?.async()
                self.isLoading = false
                if let nodeCollection = nodeCollection, (nodeCollection.page ?? 0) > 0 {
                    if let embedded = nodeCollection.embedded, embedded.collection.count > 0 {
                      //  DispatchQueue.main.async {
                            
//                                var nodes = self.nodes
//                                nodes.append(contentsOf: embedded.collection)
                                self.nodes = embedded.collection.removeDuplicates()
                            
                            if self.nodes.isEmpty {
                                self.isShowingEmptyList = true
                            }
                        //}
                    }
                    else {
                        self.isShowingEmptyList = true
                    }
                }
            }
            catch let error as CoreError {
                print(error.message)
                
                self.isLoading = false
            }
        }
        
    }
    
}

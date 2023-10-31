//
//  FilesViewModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import UIKit
import Combine
import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

class FilesViewModel:AbstractViewModel, ObservableObject  {
    
    var selectedNodeForUpload: NodeModel? = nil
    @ObservedObject var selectedMediaItems = PickedMediaItems()
    @Published var isShowingFilesScreenView: Bool = false
    @Published var isShowingViewer:Bool = false
    @Published var isShowingCommentView:Bool = false
    @Published var isShowingHistoryView:Bool = false
    @Published var sharedLink:String = ""
    @Published var historyCollection: [HistoryModel] = []
    
    //@Published var nodes:[NodeModel] = []
    @Published var uploadingNodes:[NodeModel] = [NodeModel]()

    var taskRequests:Set<Task> = Set<Task<Void, Never>>()
    var nodeToViewer:NodeModel? = nil
    
    @Published var totalNodesCount:Int = 0
    @Published var ongoingUploads: [String : CoreUploadObject] = [:]
    @Published var parentNode:NodeModel? = nil
    @Published var isUploadingFile: Bool = false
    @Published var isShowingToast: Bool = false
    @Published var history: [History] = []
    var requests:Set<AnyCancellable> = Set<AnyCancellable>()
    var fileService: FilesService
    override init() {
        self.fileService = FilesService()
        super.init()
       
        
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(handleUploadSuccess(_:)),
                                                   name: .uploadSuccess,
                                                   object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleUploadSuccess(_:)),
                                               name: .refreshUI,
                                               object: nil)
        }
    
    
    @objc func handleUploadSuccess(_ notification:Notification) {
        DispatchQueue.main.async {
            self.isUploadingFile = false
            self.isShowingToast = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
              
                self.isShowingFilesScreenView = true
            }
        }
    }
    
    @objc func handleRefreshUI(_ notification:Notification) {
        self.objectWillChange.send()
    }
    
    func onViewAppear() {
        Task { [weak self] in
            await self?.getReports()
           // print(self?.nodes.filter({$0.properties!.reviewed == true}))
            self?.objectWillChange.send()
        }
    }
    
 
    
    func uploadSelectedFiles(_ fileAttributes:[UploadFileAttributesModel] = [])  {
        isUploadingFile = true
        //update selected files with the properties
        if fileAttributes.count > 0 {
            for (index, item) in selectedMediaItems.items.enumerated() {
                if index < fileAttributes.count {
                    var fileItem =  item
                    fileItem.updateFileAttributes(fileAttributes[index])
                    selectedMediaItems.items[index] = fileItem
                }
            }
        }
        
        for item in selectedMediaItems.items {
            if let mediaUrl = item.url {
                let mimeType = mediaUrl.mimeType()
                let mediaName = mediaUrl.lastPathComponent
                
                let nodeModel = NodeModel()
                nodeModel.name = item.fileAttributes?.fileName ?? mediaName
                nodeModel.mimeType = mimeType
                let parentId = rootFolderid
                
               // var fileAttribute = item.fileAttributes
                
                if !uploadingNodes.contains(where: {$0.fileUniqueKey == nodeModel.fileUniqueKey}) {
                    uploadingNodes.insert(nodeModel, at: 0)
                }

                self.isShowingEmptyList = false
                
                let img = UIImage(contentsOfFile: item.url?.absoluteString ?? "")

                if let imageData = NSData(contentsOf: item.url ?? NSURL(string: "")! as URL) {
                    //upload original image to css
                    CoreUploadManager.shared.uploadImageToCss(image: imageData as Data, fileName: item.fileAttributes?.fileName ?? mediaName, contentType: mimeType)
                    let image = UIImage(data: imageData as Data) // Here you can attach image to UIImageView
                    let base64 = image?.base64
                    
                    //call google api to get redacted image
                    if let base64 {
                        CoreUploadManager.shared.uploadFileToGcp(bytesData: base64, fileName: item.fileAttributes?.fileName ?? mediaName,contentType: mimeType)
                    }
                    let fileKey =  parentId + mediaName
                    
                   
                }
                
            }
        }
       
    }
    
    
    private func insert(node: NodeModel,at index:Int) {
        self.nodes[index] = node
    }
    
    func showViewer(node:NodeModel) {
        nodeToViewer = node
        isShowingViewer = true
    }
    
    func getShareLink(nodeId: String, onCompletion: @escaping(_ sharedLink: String) -> Void) {
        Task {
            do {
                let shareLinkResponse = try await fileService.getShareLink(nodeId: nodeId)?.async()
                if let shareLinkResponse, let linkUri = shareLinkResponse.link_uri {
                    self.sharedLink = linkUri
                    await getReports()
                    onCompletion(sharedLink)
                }
            } catch let error  {
                if let error = error as? CoreError {
                    print(error.message)
                }
                onCompletion("")
            }
        }
    }
    
    func getReportsHistory(nodeId: String) {
        Task {
            do {
                let history = try await fileService.getReportsHistory(nodeId: nodeId)?.async()
                self.isLoading = false
                if let collection = history?.embedded?.collection {
                    let modifiedCollection = collection.filter({ $0.action_name == "REVIEWED" || ($0.action_name == "create")})
                    self.historyCollection.append(contentsOf: modifiedCollection)
                    self.history = getFormattedHistory(historyCollection: self.historyCollection)
                }
              //  print(history?.embedded?.collection)
            } catch {
                self.isLoading = false
            }
        }
    }
    
    func updateReports(nodeId: String) {
        Task {
            do {
                let response  = try await fileService.updateReports(nodeId: nodeId)?.async()
               // print("update reports response \(response) ")
            } catch {
                
            }
        }
    }
    
    func getFormattedHistory(historyCollection: [HistoryModel]) -> [History] {
        var finalHistory: [History] = []
        for history in self.historyCollection {
            finalHistory.append(History(action: history.action_name, date: getFormattedTime(createTime: history.create_time), email: history.action_name == "create" ? UserHelper.getCurrentUserFromRealm()?.email ?? "" : history.event_user))
        }
        return finalHistory
    }
    
    func getFormattedTime(createTime: String) -> String {
        var formattedTime = ""
        let formatter = DateHelper.ISO8601DateFormatter
        guard let date = formatter.date(from: createTime) else { return EMPTY_STRING }
        formattedTime = DateHelper.shortDateFormatter.string(from: date)
         return formattedTime
    }
}

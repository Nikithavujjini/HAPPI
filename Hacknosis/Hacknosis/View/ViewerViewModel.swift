//
//  ViewerViewModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import Foundation

enum DocumentScreenType {
    case documentSaver
    case documentViewer
}

class ViewerViewModel:ObservableObject {
    var documentType: DocumentScreenType = .documentViewer
    @Published var isLoading: Bool = false
    @Published var downloadPercentage: Float = 0
    @Published var showErrorMessage: Bool = false
    @Published var showFileNotFoundError: Bool = false
    @Published var documentDownloadedUrl: URL?
    @Published var showDocumentSave:Bool = false
    @Published var redactedFileUrl:String = ""
    var fileItemData:NodeModel?
    var fileStoragePath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    var updatedTime:String = EMPTY_STRING
    var fileService: FilesService
    init(fileItemData:NodeModel?) {
        self.fileItemData = fileItemData
        self.fileService = FilesService()
      //  self.updatedTime = updatedTime
    }
    
    func onViewAppear() {
        fetchDocumentDetails()
    }
    func showFileDoesNotExistError() {
        showErrorMessage = true
    }
    
    func fetchDocumentDetails() {

        //show error if file don't exist
        guard let fileItemData = fileItemData,
              let documentLink = fileItemData.originalFileUrl
        else {
            showFileDoesNotExistError()
            return
        }

        let nodeId = fileItemData.id
        let fileName = fileItemData.name

        isLoading = true
       
        let fileUrl = getFileUrlPath(nodeId: nodeId, updatedTime: updatedTime, fileName: fileName)
        //show already downloaded file if already exist
        if FileManager.default.fileExists(atPath: fileUrl.path) {
            self.documentDownloadedUrl = fileUrl
            showDocumentSave = documentType == .documentSaver
            return
        }

        //if doctor signed in do content api and show the redacted file
        //var redactedFileUrl = ""
        if UserHelper.isCurrentUserADoctor() {
            
            Task { [weak self] in
                do {
                    let collection = try await self?.fileService.getMaskedContent(nodeId: fileItemData.id)?.async()
                    if let collection {
                        var finalValue = ""
                        let cmsLinks = collection._embedded.collection.filter({ $0.rendition_type == "secondary"}).first?._links
                        if let value = cmsLinks?.links.filter({$0.key == "urn:eim:linkrel:download-media"}).last?.value {
                            //return value.href?.replacingCharacters(in: "https://contentservice-c4sapqe.qe.bp-paas.otxlab.net", with: "cs")
                            
                            if let value = value.href {
                                finalValue = value.replacingOccurrences(of: "https://contentservice-c4sapqe.qe.bp-paas.otxlab.net", with: "/cs")
                                self?.redactedFileUrl = finalValue
                                self?.downloadFile(redactedFileUrl: self?.redactedFileUrl , fileStoragePath: fileStoragePath, fileData: fileItemData, fileUrl: fileUrl)
                            }
                            
                        }
                        //return value.href?.replacingCharacters(in: "https://contentservice-c4sapqe.qe.bp-paas.otxlab.net", with: "cs")
                    }
                } catch {
                    if let error = error as? CoreError {
                        debugPrint(error.message)
                    }
                }
            }
        } else {
            downloadFile(fileStoragePath: fileStoragePath, fileData: fileItemData, fileUrl: fileUrl)
        }
       
    }

    func downloadFile(redactedFileUrl:  String? = "", fileStoragePath: URL, fileData: NodeModel, fileUrl: URL) {
        CoreDownloadManager.shared.downloadFile(fileData: fileData,redactedFileUrl: self.redactedFileUrl, isViewer: true,nodeService: FilesService(),  onProgress: { progress, fileKey in
            self.downloadPercentage = min(Float(progress), 1)
        }) { [weak self] downloadedUrl, fileKey, error in
            if error != nil {
                self?.showErrorMessage = true
            } else {
                do {
                    if let downloadedUrl {

                        //create a directory with node node name if it doesn't exist
                        try? FileManager.default.createDirectory(at: fileStoragePath, withIntermediateDirectories: false, attributes: nil)

                        //first remove the file if already exist
                        if FileManager.default.fileExists(atPath: fileUrl.path) {
                            try FileManager.default.removeItem(at: fileUrl)
                        }
                     //   downloadedUrl.append(".png")
                        //move the item to destination path
                        try FileManager.default.moveItem(atPath: downloadedUrl, toPath: fileUrl.path)
                                                
                        self?.showDocument(fileUrl:fileUrl)
                        DispatchQueue.main.async {
                            self?.isLoading = false
                        }
                    } else {
                        self?.showErrorMessage = true
                    }
                }
                catch {
                    DispatchQueue.main.async {
                        self?.showErrorMessage = true
                        print(error.localizedDescription)
                        self?.isLoading = false
                    }
                }
            }
        }
    }
    
    func getFileUrlPath(nodeId: String, updatedTime: String, fileName: String) -> URL {
        fileStoragePath = fileStoragePath.appendingPathComponent("\(nodeId)__\(updatedTime)")
        var fileUrl = getFileStoragePathURL(nodeId: "\(nodeId)__\(updatedTime)", fileName: "\(fileName)", updateTime: updatedTime)
        if UserHelper.isCurrentUserADoctor() {
            fileUrl = getFileStoragePathURL(nodeId: "\(nodeId)__\(updatedTime)", fileName: "\(fileName)-redacted", updateTime: updatedTime)
        }
        return fileUrl
    }
    
    func getFileStoragePathURL(nodeId:String, fileName:String, updateTime:String) -> URL {
        var fileStoragePath = cacheDirectoryUrl()
        fileStoragePath = fileStoragePath.appendingPathComponent(nodeId)
        return fileStoragePath.appendingPathComponent(fileName)
    }
    
    func cacheDirectoryUrl() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    func showDocument(fileUrl:URL){
        DispatchQueue.main.async {
            self.documentDownloadedUrl = fileUrl
            self.isLoading = false
            self.showDocumentSave = self.documentType == .documentSaver
        }
    }
}

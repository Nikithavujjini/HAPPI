//
//  CoreDownloadManager.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 24/10/23.
//

import SwiftUI
import UserNotifications
import Combine

final public class CoreDownloadManager: NSObject {
    
    public typealias DownloadCompletionBlock = (_ fileUrl:String?, _ fileKey:String, _ error : Error?) -> Void

    public typealias DownloadProgressBlock = (_ progress : Double, _ fileKey:String) -> Void
    public typealias DownloadStartBlock = (_ fileKey:String) -> Void

    public typealias BackgroundDownloadCompletionHandler = () -> Void
    public var backgroundCompletionHandler: BackgroundDownloadCompletionHandler?
    private var backgroundSession: URLSession!
    private var subscribers: Set<AnyCancellable> = .init()

    // MARK :- Properties
    public static let shared: CoreDownloadManager = { return CoreDownloadManager() }()
    
    private var ongoingDownloads: [String : CoreDownloadObject] = [:]

    
    
    //MARK:- Private methods
    
    private  override init() {
       
        super.init()
        //background session
        let configuration = URLSessionConfiguration.background(withIdentifier: DOWNLOAD_BACKGROUND_SESSION_IDENTIFIER)
        configuration.sharedContainerIdentifier = AppGroup
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        configuration.networkServiceType = .background
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        self.backgroundSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
//
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleDismissMessageOverlay(_:)),
//                                               name: .dismissMessageOverlay,
//                                               object: nil)
    }
    
    //MARK:- Public methods
    func downloadFile(fileData: NodeModel,
                      redactedFileUrl: String? = "",
                      isViewer:Bool = false,
                      nodeService:FilesService,
                      onStart startBlock:DownloadStartBlock? = nil,
                      onProgress progressBlock:DownloadProgressBlock? = nil,
                      onCompletion completionBlock:@escaping DownloadCompletionBlock) {
        
        //show error if file don't exist
        guard let fileKey = redactedFileUrl!.count > 0 ? redactedFileUrl : fileData.originalFileUrl else {
            return
        }
       

        //check if the file download is already in progress
        //then capture completion and progress block
        //to make sure it will get callbacks everywhere
        if let ongoingDownload = ongoingDownloads[fileKey] {
            ongoingDownload.completionBlocks.append(completionBlock)
            if let progressBlock = progressBlock {
                ongoingDownload.progressBlocks?.append(progressBlock)
                progressBlock(ongoingDownload.progress ?? 0, fileKey)
            }
            startBlock?(fileKey)
            return
        }
        
        let router = FilesRouter(routerType: .getDocumentDownloadUrl(uri: fileKey))

        let downloadTask = nodeService.downloadDocument(withRouter: router, session: backgroundSession) { _,_,_ in
            //it will not be called for background downloads
        }
        
        if let downloadTask = downloadTask {
            let download = CoreDownloadObject(downloadTask: downloadTask,
                                              isViewer: isViewer,
                                              progressBlock: (progressBlock != nil) ? [progressBlock!] : [],
                                              completionBlock: [completionBlock],
                                              fileData: fileData,
                                              service: nodeService
            )
            self.ongoingDownloads[fileKey] = download
            startBlock?(fileKey)
        }

    }
    
    public func getDownloadKey(withUrl url: URL?) -> String {
        return url?.absoluteString ?? ""
    }
    
    func currentDownloads() -> [String : CoreDownloadObject] {
        return self.ongoingDownloads.filter({$0.value.isViewer == false})
    }
    
    public func cancelAllDownloads() {
        for (_, download) in self.ongoingDownloads {
            let downloadTask = download.downloadTask
            downloadTask.cancel()
        }
        self.ongoingDownloads.removeAll()
    }
//
//    public func cancelThumnailRequests() {
//        for request in thumnailRequests {
//            request.cancel()
//        }
//    }
    
    public func cancelDownload(forUniqueKey key:String) {
        let downloadStatus = self.isDownloadInProgress(forUniqueKey: key)
        let presence = downloadStatus.0
        if presence {
            if let download = downloadStatus.1 {
                download.downloadTask.cancel()
                let downloadingObject = self.ongoingDownloads[key]
                self.ongoingDownloads.removeValue(forKey: key)
                for block in downloadingObject?.completionBlocks ?? [] {
                    block(nil, key, nil)
                }
               // self.showBannerMessage()
            }
        }
    }
        
    func isDownloadInProgress(forUniqueKey key:String?) -> (Bool, CoreDownloadObject?) {
        guard let key = key else { return (false, nil) }
        for (uniqueKey, download) in self.ongoingDownloads {
            if key == uniqueKey {
                return (true, download)
            }
        }
        return (false, nil)
    }
    

   
    
  
    
    private func key(for url:URL?) -> String {
        guard let url = url else {
            return ""
        }
        var key = ""
        var components = url.pathComponents.compactMap({$0})
        
        if !components.isEmpty {
            if components.contains("shared") && components.contains("private") {
                components = components.count > 5 ? Array(components.dropFirst(4)) : components
            } else {
                components = components.count > 4 ? Array(components.dropFirst(3)) : components
            }
            for eachComponent in components {
                key.append("/")
                key.append(eachComponent)
            }
        }
        
        if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true), let queryItems = urlComponents.queryItems {
            key.append("?")

            for item in queryItems {
                key.append(item.name)
                key.append("=")
                key.append(item.value ?? "")
            }
        }
        
        return key
    }
    
}


extension CoreDownloadManager : URLSessionDelegate, URLSessionDownloadDelegate, URLSessionDataDelegate {
    
    // MARK:- Delegates

    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {

        let key = key(for: downloadTask.originalRequest?.url)
        
        if let download = self.ongoingDownloads[key]  {
            
            let completionBlocks = download.completionBlocks
            guard let response = downloadTask.response as? HTTPURLResponse else {
                OperationQueue.main.addOperation({
                    self.ongoingDownloads.removeValue(forKey:key)
                    for block in completionBlocks {
                        block(nil, key, CoreError(message: "ERROR_UNKNOWN_ERROR"))
                    }
                })
                return
            }
            
            if response.isUnAuthorized() {
                var publisher : AnyPublisher<String, CoreError>
//                if let shared = download.service.sharedLink {
//                    publisher = shared.getAccessTokenPublisher(forceRefresh: true)
//                } else {
                    publisher = AuthenticationManager.shared.getAccessTokenPublisher(forceRefresh: true)
              //  }
                publisher
                    .sink { completion in
                        self.ongoingDownloads.removeValue(forKey:key)
                        
                        self.downloadFile(fileData: download.fileData,
                                          isViewer: download.isViewer,
                                          nodeService: download.service,
                                          onProgress: download.progressBlocks?.last,
                                          onCompletion: download.completionBlocks.last!)
                    } receiveValue: { token in
                        
                    }.store(in: &self.subscribers)
                return
            }
            
//            if response.isAuthenticationFailed() {
//                if download.service.sharedLink == nil {
//                    LogoutHelper.logout()
//                }
//                return
//            }
            
                guard response.isResponseOK() else {
                    let error = CoreError(httpResponse: response)
                    error.status = response.statusCode
                    if response.statusCode == 404 {
                        error.message =  "FILE_DELETED"
                    }
                    
                    OperationQueue.main.addOperation({
                        self.ongoingDownloads.removeValue(forKey:key)
                        for block in completionBlocks {
                            block(nil, key, error)
                        }
                    })
                    return
                }
            
            
            do {
                let cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
                let url = cacheDir.appendingPathComponent((UUID().uuidString))
                
                try FileManager.default.moveItem(atPath: location.path, toPath: url.path)
                
                if download.isViewer {
                    for block in completionBlocks {
                        block(url.path, key, nil)
                    }
                    self.ongoingDownloads.removeValue(forKey:key)
                    return
                }
                
                let fileUrl = CoreFileUtils.getFileStoragePathURL(nodeId: download.fileData.fileId, fileName: download.fileData.name)

                //first remove the file if already exist
                if FileManager.default.fileExists(atPath: fileUrl.path) {
                    try? FileManager.default.removeItem(at: fileUrl)
                }
                
                //move the item to destination path
                try? FileManager.default.moveItem(atPath: url.path, toPath: fileUrl.path)
                try? (fileUrl as NSURL).setResourceValue(URLFileProtection.complete, forKey: .fileProtectionKey)
                
            }
            
            catch let error {
                OperationQueue.main.addOperation({
                    for block in download.completionBlocks {
                        block(nil, key, error)
                    }
                })
            }
        }
    }
    
    public func urlSession(_ session: URLSession,
                             task: URLSessionTask,
                             didCompleteWithError error: Error?) {
        
        if let error = error {
            
            let downloadTask = task as! URLSessionDownloadTask
            let key = key(for: downloadTask.originalRequest?.url)
            if let download = self.ongoingDownloads[key] {
                OperationQueue.main.addOperation({
                    let completionBlocks = download.completionBlocks
                    self.ongoingDownloads.removeValue(forKey:key)
                    for block in completionBlocks {
                        block(nil, key, error)
                    }
                })
            }
            self.ongoingDownloads.removeValue(forKey:key)
        }
    }

    public func urlSession(_ session: URLSession,
                                 downloadTask: URLSessionDownloadTask,
                                 didWriteData bytesWritten: Int64,
                                 totalBytesWritten: Int64,
                           totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else {
            return;
        }
        
        let key = key(for: downloadTask.originalRequest?.url)

        if let download = self.ongoingDownloads[key],
           let progressBlocks = download.progressBlocks {
            for block in progressBlocks {
                let progress : CGFloat = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
                self.ongoingDownloads[key]?.progress = progress
                OperationQueue.main.addOperation({
                    block(progress, key)
                })
            }
        }
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            if downloadTasks.count == 0 {
                OperationQueue.main.addOperation({
                    if let completion = self.backgroundCompletionHandler {
                        completion()
                    }
                    self.backgroundCompletionHandler = nil
                })
            }
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
        completionHandler(nil)
    }
    
}

class CoreDownloadObject: NSObject {
    var completionBlocks: [CoreDownloadManager.DownloadCompletionBlock]
    var progressBlocks: [CoreDownloadManager.DownloadProgressBlock]?
    let downloadTask: AnyCancellable
    let fileData: NodeModel
    var progress:Double?
    let service: FilesService
    let isViewer:Bool
    
    init(downloadTask: AnyCancellable,
         isViewer:Bool,
         progressBlock: [CoreDownloadManager.DownloadProgressBlock]?,
         completionBlock: [CoreDownloadManager.DownloadCompletionBlock],
         fileData: NodeModel,
         service: FilesService,
         progress:Double? = 0) {
        
        self.downloadTask = downloadTask
        self.isViewer = isViewer
        self.completionBlocks = completionBlock
        self.progressBlocks = progressBlock
        self.fileData = fileData
        self.progress = progress
        self.service = service
    }
}


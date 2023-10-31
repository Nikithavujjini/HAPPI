

import Foundation
import Combine
import UIKit
enum FileUploadType:Int {
    case newUpload, addVersion
}

enum UploadFailType {
    case none, content, metadata
}

struct UploadDocumentDetails {
    var name:String
    var mimeType:String
    var parentId:String
    var fileKey:String
    var fileUrl:URL
    var fileSize:Int
    var mimeTypeImageName:String
    var caseNodeId:String?
    var uploadFileAttributes:UploadFileAttributesModel?
    var uploadType:FileUploadType = .newUpload
    var ownerID: String? = nil
    var fileID:String? = nil
    var versionName: String? = nil
    var boundary: String
    var type: String
    
    func computedVersionName() -> String {
        if let ext = name.components(separatedBy: ["."]).last, let name =  versionName?.components(separatedBy: ["."]).first {
            return name + "." + ext
        }
        return name
    }
}

extension UploadDocumentDetails {
    init(object: CoreUploadObject) {
        name = object.fileData.name
        parentId = object.fileData.parentId
        fileKey = object.fileData.fileKey
        fileUrl = object.fileData.fileUrl
        mimeType = object.fileData.mimeType
        mimeTypeImageName = object.fileData.mimeTypeImageName
        uploadFileAttributes = object.fileData.uploadFileAttributes
        uploadType = object.fileData.uploadType
        caseNodeId = object.fileData.caseNodeId
        ownerID = object.fileData.ownerID
        fileID = object.fileData.fileID
        fileSize = object.fileData.fileSize
        versionName = object.fileData.versionName
        boundary = object.fileData.boundary
        type = object.fileData.type
    }
}

final public class CoreUploadManager: SSLPinningHandler {
    
    typealias UploadCompletionBlock = (_ node:NodeModel?, _ fileKey:String, _ error : CoreError?) -> Void
    typealias UploadProgressBlock = (_ progress : Double, _ fileKey:String) -> Void
    typealias UploadStartBlock = (_ fileKey:String) -> Void
    private var backgroundSession: URLSession!
    public typealias BackgroundUploadCompletionHandler = () -> Void
    public var backgroundCompletionHandler: BackgroundUploadCompletionHandler?
    private var subscribers: Set<AnyCancellable> = .init()
    var taskRequests:Set<Task> = Set<Task<Void, Never>>()
    
    // MARK :- Properties
    public static let shared: CoreUploadManager = { return CoreUploadManager() }()
    
    private var ongoingUploads: [String : CoreUploadObject] = [:]
//    private var nodeService: Uploadable & VersionAddable & UnLockable = NodeService()
    
    private var completedUploads = [CoreUploadObject]()
    private var documentDetail: UploadDocumentDetails!
    var requests:Set<AnyCancellable> = Set<AnyCancellable>()
    private var blobIdInitial: String = ""
    //MARK:- Private methods
    private override init() {
        super.init()
        
        //background session
//        let configuration = URLSessionConfiguration.default
//        self.backgroundSession = URLSession(configuration: configuration)
        let configuration = URLSessionConfiguration.background(withIdentifier: UPLOAD_BACKGROUND_SESSION_IDENTIFIER)
        configuration.sharedContainerIdentifier = AppGroup
        configuration.tlsMinimumSupportedProtocolVersion = .TLSv12
        configuration.networkServiceType = .background
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        self.backgroundSession = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue())
    }
    
    func unitTestInject(session:URLSession) {
        self.backgroundSession = session
    }
    
    //MARK:- Public methods
    func uploadFile(fileData: UploadDocumentDetails,
                    service: FilesService,
                      onStart startBlock:UploadStartBlock? = nil,
                      onProgress progressBlock:UploadProgressBlock? = nil,
                      onCompletion completionBlock:@escaping UploadCompletionBlock) {
        
        //check if the file exists at the source location
        guard FileManager.default.fileExists(atPath: fileData.fileUrl.path) else {
            return
        }
        
        documentDetail = fileData
        let fileKey = fileData.fileKey

        //check if the file Upload is already in progress
        if let ongoingUpload = ongoingUploads[fileKey], ongoingUpload.fileData.parentId == fileData.parentId {
            ongoingUpload.completionBlocks.append(completionBlock)
            if let progressBlock = progressBlock {
                ongoingUpload.progressBlocks?.append(progressBlock)
                progressBlock(ongoingUpload.progress ?? 0, fileKey)
            }
            startBlock?(fileKey)
            return
        }
        
        let uploadTask: AnyCancellable?

        let router = FilesRouter(routerType: .uploadFileToCss(name: fileData.name, mimeType: fileData.mimeType))

        router.boundary = fileData.boundary
        uploadTask = service.uploadDocument(withRouter: router, fileUrl: fileData.fileUrl, session: backgroundSession, taskDescription: fileKey) { uploadResponseModel, _, _  in
            //do nothing
        }
        
//        if let uploadTask {
//            requests.insert(uploadTask)
//        }
        
        if let uploadTask = uploadTask {
            let upload = CoreUploadObject(uploadTask: uploadTask,
                                          taskDescription: fileKey,
                                          progressBlocks: [progressBlock],
                                          completionBlocks: [completionBlock],
                                          fileData: fileData,
                                          service: service)
            self.ongoingUploads[fileKey] = upload
            startBlock?(fileKey)
            if fileData.fileSize == 0 {
                upload.progress = 1
                upload.errorMessage = "ZERO_FILE_SIZE_UPLOAD"
                for block in upload.progressBlocks ?? [] {
                    block?(1, fileKey)
                }
                updateError(for: fileKey, message: "ZERO_FILE_SIZE_UPLOAD")
            }
        }
    }
    
    public func updateError(for taskDescription: String, message: String) {
        if let upload = self.ongoingUploads[taskDescription]  {
            OperationQueue.main.addOperation({
                for block in upload.completionBlocks {
                    block(nil, taskDescription, CoreError(message: message))
                }
                self.addItemToCompletedUploads(upload)
                if upload.fileData.uploadType == .addVersion  {
                    self.removeFromUploads(forUniqueKey:taskDescription)
//                    NotificationCenter.default.post(name: .showBannerMessage, object: nil, userInfo: [BANNER_MESSAGE_TYPE : BannerMessageType.errorMessage, BANNER_MESSAGE : String.localizedStringWithFormat(VERSION_FAILED_TOAST_MESSAGE,self.documentDetail.name )])
                }
//                else {
//                    CoreUploadManager.shared.showBannerMessage()
//                }
            })
        }
    }
    
    public func getUploadKey(withUrl url: URL) -> String {
        return url.absoluteString
    }
    
    func currentUploads() -> [String : CoreUploadObject] {
        return self.ongoingUploads
    }
    
    public func cancelAllUploads() {
        for (_, upload) in self.ongoingUploads {
            let uploadTask = upload.uploadTask
            //remove temarary multipart file
            CoreFileUtils.removeFile(at: upload.fileData.fileUrl)
            uploadTask.cancel()
        }
        self.ongoingUploads.removeAll()
    }
    
    public func cancelUpload(forUniqueKey key:String) {
        let uploadStatus = self.isUploadInProgress(forUniqueKey: key)
        let presence = uploadStatus.0
        if presence {
            if let upload = uploadStatus.1 {
                upload.uploadTask.cancel()
                let uploadingObject = self.ongoingUploads[key]
                //remove temarary multipart file
                CoreFileUtils.removeFile(at: upload.fileData.fileUrl)
//                upload.errorMessage = BANNER_LIST_COULD_NOT_BE_UPLOADED
//                upload.failType = .content
//                upload.isEligibleForRetry = true
//                upload.progress = 0
//                upload.isPermanentError = false
                addItemToCompletedUploads(upload)
                self.removeFromUploads(forUniqueKey: key)
                completedUploads.removeAll(where: { node in
                    key == node.fileData.fileKey
                })
                for block in uploadingObject?.completionBlocks ?? [] {
                    block(nil, key, nil)
                }
              //  CoreUploadManager.shared.showBannerMessage()
            }
        }
    }
        
    public func removeFromUploads(forUniqueKey key:String) {
        self.ongoingUploads.removeValue(forKey: key)
    }
    
    public func isUploadInProgress(forKey key:String?) -> Bool {
        let uploadStatus = self.isUploadInProgress(forUniqueKey: key)
        return uploadStatus.0
    }
    
    func isUploadInProgress(forUniqueKey key:String?) -> (Bool, CoreUploadObject?) {
        guard let key = key else { return (false, nil) }
        for (uniqueKey, upload) in self.ongoingUploads {
            if key == uniqueKey {
                return (true, upload)
            }
        }
        return (false, nil)
    }
    
    func getUploadingFilesFor(parentId:String?) -> [String : CoreUploadObject]? {
        if let parentId = parentId {
            return self.ongoingUploads.filter({$0.value.fileData.parentId == parentId})
        }
        return nil
    }
    
    func allCompletedUploads() -> [CoreUploadObject] {
        var completed = [CoreUploadObject]()
        //first collect failed downloads
        completed.append(contentsOf: completedUploads.filter( {$0.errorMessage != nil && $0.fileData.uploadType == .newUpload }))
        //then collect successful downloads
        completed.append(contentsOf: completedUploads.filter( {$0.errorMessage == nil && $0.fileData.uploadType == .newUpload }))
        return completed
    }
    
    func completedUploadsCount() -> Int {
        return completedUploads.filter({$0.fileData.uploadType == .newUpload}).count
    }
    
    func addItemToCompletedUploads(_ uploadObject:CoreUploadObject) {
        if let node = completedUploads.filter({ $0.taskDescription == uploadObject.taskDescription}).last {
            if let index = completedUploads.firstIndex(of: node) {
                if uploadObject.errorMessage != nil {
                    completedUploads.remove(at: index)
                    completedUploads.append(uploadObject)
                } else {
                    completedUploads[index] = uploadObject
                }
                return
            }
        }
        completedUploads.append(uploadObject)
    }
    
    func removeAllCompletedUploads() {
        for upload in completedUploads {
            CoreFileUtils.removeFile(at: upload.fileData.fileUrl)
        }
        completedUploads.removeAll()
    }
    
    func removeUploadItem(uploadItem:CoreUploadObject) {
        completedUploads.removeAll(where: { node in
            uploadItem.taskDescription == node.taskDescription
        })
    }
    
    func failedUploadsCount() -> Int {
        return completedUploads.filter({ $0.fileData.uploadType == .newUpload && $0.errorMessage != nil }).count
    }
    
    @objc func handleDismissMessageOverlay(_ notification:Notification?) {
        self.removeAllCompletedUploads()
    }
    
    @objc func handleRemoveFailedUploads(_ notification:Notification?) {
        DispatchQueue.main.async {
            self.ongoingUploads.removeAll()
        }
    }
    
//    func retryMetadaUpload(_ upload:CoreUploadObject) {
//        upload.errorMessage = nil
//        upload.progress = 0.98
//        self.ongoingUploads[upload.taskDescription] = upload
//
//        if upload.fileData.uploadType == .addVersion {
//            addVersionToFile(upload, upload.taskDescription)
//        } else if upload.fileData.uploadType == .newUpload {
//            createFile(upload, upload.taskDescription)
//        }
//    }
        
//    func showBannerMessage() {
//        if let banner = self.generateBannerMessage() {
//            NotificationCenter.default.post(name: .showBannerMessage, object: nil, userInfo: [BANNER_MESSAGE_TYPE : banner.type, BANNER_MESSAGE: banner.message, BANNER_LIST_ITEMS: banner.items as Any])
//        }
//    }
    
//    private func generateBannerMessage() -> BannerMessage? {
//        let currentUploads = currentUploads()
//        var bannerMessage:BannerMessage? = nil
//
//        if currentUploads.filter({$0.value.fileData.uploadType == .newUpload && $0.value.errorMessage == nil }).count == 0 {
//
//            let completedUploads = allCompletedUploads()
//            let failedUploadsCount = failedUploadsCount()
//
//            if failedUploadsCount > 0 {
//                var message = String.localizedStringWithFormat(MULTIPLE_UPLOADS_FAIL, "\(failedUploadsCount)")
//                //change message if there is only one upload
//                if failedUploadsCount == 1 {
//                    message = String.localizedStringWithFormat(MULTIPLE_UPLOADS_SINGLE_FAIL, "\(failedUploadsCount)")
//                }
//                bannerMessage = BannerMessage(message: message, type: .errorMessage, items: completedUploads)
//                self.handleRemoveFailedUploads(nil)
//            } else {
//                if completedUploads.count > 0 {
//                    var message = String.localizedStringWithFormat(MULTIPLE_UPLOADS_SUCCESS, "\(completedUploads.count)")
//                    //change message if there is only one upload
//                    if completedUploads.count == 1 {
//                        message = String.localizedStringWithFormat(SINGLE_UPLOAD_SUCCESS, "\"\(completedUploads.last?.fileData.name ?? "")\"")
//                    }
//                    bannerMessage = BannerMessage(message: message, type: .successMessage)
//                }
//            }
//
//            NotificationCenter.default.post(name: .removeFailedUploadFiles, object: nil)
//            if completedUploads.count == 0 && failedUploadsCount == 0 {
//                NotificationCenter.default.post(name: .dismissMessageOverlay, object: nil)
//            }
//        }
//        return bannerMessage
//    }
    
    // API Methods
    
    fileprivate func createFile( _ upload: CoreUploadObject, _ taskDescription: String) {
        guard let uploadModel = upload.uploadResponse else {
            return
        }
        
        //create a file with properties and blobId
        let uploadPropertiesModel = UploadFileWithPropertiesModel(uploadModel: uploadModel, coreModel: upload)
        let request = upload.service.getUploadedNodeDetails(uploadModel: uploadPropertiesModel) { node, error in
            OperationQueue.main.addOperation({
                //show 100% progress
                self.ongoingUploads[taskDescription]?.progress = 1
                for block in upload.progressBlocks ?? [] {
                    block?(1, taskDescription)
                }
                
                //this delay is to show 100% progress for some time
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if let error {
                        self.ongoingUploads[taskDescription]?.errorMessage = error.message
                        self.ongoingUploads[taskDescription]?.progress = 1

                        upload.errorMessage = error.message
                        upload.failType = .metadata
                        upload.progress = 1
                        
                        if let status = error.status, status >= 500 && status <= 599 {
                            upload.errorMessage = error.message
                            upload.isEligibleForRetry = true
                        } else {
                            upload.isEligibleForRetry = true
                        }
                        for block in upload.completionBlocks {
                            block(node, taskDescription, error)
                        }
                    } else if node != nil {
                        //remove temarary multipart file
                        CoreFileUtils.removeFile(at: upload.fileData.fileUrl)
                        self.ongoingUploads[taskDescription]?.errorMessage = nil
                        self.ongoingUploads[taskDescription]?.progress = 1
                        upload.progress = 1
                        upload.isEligibleForRetry = false
                        upload.errorMessage = nil
                        for block in upload.completionBlocks {
                            block(node, taskDescription, error)
                        }
                        self.removeFromUploads(forUniqueKey:taskDescription)
                    }
                    
                    self.addItemToCompletedUploads(upload)
                    //CoreUploadManager.shared.showBannerMessage()
                }
            })
        }
        
        if let request = request {
            upload.uploadTask = request
            subscribers.insert(request)
        }
    }
    
}

extension CoreUploadManager : URLSessionDelegate, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    // MARK:- Delegates

    public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        
        if let taskDescription = task.taskDescription {
            if let upload = self.ongoingUploads[taskDescription] {
                var uploadProgress:Double = Double(totalBytesSent) / Double(totalBytesExpectedToSend)
                if uploadProgress > 0 {
                    OperationQueue.main.addOperation({
                        if uploadProgress > 0 {
                            //stop at 98%, so that user will wait till it is finalized
                            uploadProgress = max(0, uploadProgress - 0.02)
                        }
                        for block in upload.progressBlocks ?? [] {
                            block?(uploadProgress, taskDescription)
                        }
                        self.ongoingUploads[taskDescription]?.progress = uploadProgress
                    })
                    return
                }
            }
        }
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        guard let taskDescription = dataTask.taskDescription else {
            return
        }
        
        if let upload = self.ongoingUploads[taskDescription] {
            //check response
            guard let response = dataTask.response as? HTTPURLResponse else {
                OperationQueue.main.addOperation({
                    self.removeFromUploads(forUniqueKey:taskDescription)
                    for block in self.ongoingUploads[taskDescription]?.completionBlocks ?? [] {
                        block(nil, taskDescription, CoreError(message: "ERROR_UNKNOWN_ERROR"))
                    }
                })
                return
            }
            //check if authorized
            if response.isUnAuthorized() {
                var publisher : AnyPublisher<String, CoreError>
               // if let shared = upload.service.sharedLink {
                   // publisher = shared.getAccessTokenPublisher(forceRefresh: true)
               // } else {
                    publisher = AuthenticationManager.shared.getAccessTokenPublisher(forceRefresh: true)
                //}
                
                publisher
                    .sink { completion in
                        self.removeFromUploads(forUniqueKey:taskDescription)
                        self.uploadFile(fileData: upload.fileData, service: upload.service, onProgress: upload.progressBlocks?.last!, onCompletion: upload.completionBlocks.last!)
                    } receiveValue: { token in
                    }.store(in: &self.subscribers)
                return
            }
            
            //remove temarary multipart file
            //CoreFileUtils.removeFile(at: upload.fileData.fileUrl)

//            if response.isAuthenticationFailed() {
//                if upload.service.sharedLink == nil {
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
                    upload.errorMessage = "BANNER_LIST_COULD_NOT_BE_UPLOADED"//error.message
                    upload.failType = .content
                    upload.progress = 1
                    upload.isEligibleForRetry = true
                    self.addItemToCompletedUploads(upload)
                    for block in upload.completionBlocks {
                        block(nil, taskDescription, error)
                    }
                    if upload.fileData.uploadType == .addVersion  {
                        self.removeFromUploads(forUniqueKey: taskDescription)
//                        NotificationCenter.default.post(name: .showBannerMessage, object: nil, userInfo: [BANNER_MESSAGE_TYPE : BannerMessageType.errorMessage, BANNER_MESSAGE : String.localizedStringWithFormat(VERSION_FAILED_TOAST_MESSAGE,self.documentDetail.name )])
                    }
//                    else {
//                        CoreUploadManager.shared.showBannerMessage()
//                    }
                    //remove temarary multipart file
                    //CoreFileUtils.removeFile(at: upload.fileData.fileUrl)
                })
                return
            }
            
            do {
                // Decode data to object
                let jsonDecoder = JSONDecoder()
                let uploadModel = try jsonDecoder.decode(UploadResponseModel.self, from: data)
                upload.uploadResponse = uploadModel
                //send this value to make cms api call for storage
                
                if let uploadModelEntries = uploadModel.entries {
                    print(uploadModelEntries[0].blobId)
                    if let blobId = uploadModelEntries[0].blobId {
                        blobIdInitial = blobId
                    }
                    print("hellothere")
                }
                if upload.fileData.uploadType == .newUpload {
                    createFile(upload, taskDescription)
                  
                }
               
            }
            catch let error {
                if let error = error as? CoreError {
                    upload.errorMessage = error.localizedDescription
                    upload.failType = .metadata
                    if let status = error.status, status >= 500 && status <= 599 {
                        upload.progress = 0
                        upload.isEligibleForRetry = true
                    } else {
                        upload.isEligibleForRetry = false
                    }
                    self.updateError(for: taskDescription, message: error.localizedDescription)
                }
            }
            return
        }
        
    }
    
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let taskDescription = task.taskDescription {
            if let upload = self.ongoingUploads[taskDescription] {
                if let error = error {
                    upload.errorMessage = "BANNER_LIST_COULD_NOT_BE_UPLOADED"
                    upload.failType = .content
                    upload.progress = 0
                    OperationQueue.main.addOperation({
                        for block in upload.completionBlocks {
                            block(nil, taskDescription, CoreError(message: error.localizedDescription))
                        }
                        self.addItemToCompletedUploads(upload)
                        self.removeFromUploads(forUniqueKey:taskDescription)
                    })
                }
            }
        }
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            if uploadTasks.count == 0 {
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
    
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        sslPinning(for: challenge, with: completionHandler)
    }
     
    
    func uploadFileToGcp(bytesData: String, fileName: String, contentType: String) {

        // Define the URL
        let baseUrl = "https://dlp.googleapis.com/v2/projects/secure-health-app-402315/image:redact"
        let queryParameters = [
            "key": "AIzaSyDE6Y5sWlN-8a6fdE0SaBxO2ewI49um7T0",
            
        ]
        var urlComponents = URLComponents(string: baseUrl)
        urlComponents?.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }

        if let url = urlComponents?.url {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            
            // Define the HTTP headers
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("x-ios-bundle-identifier", forHTTPHeaderField: "com.hacknosis")
            //request.addValue("Bearer AIzaSyDE6Y5sWlN-8a6fdE0SaBxO2ewI49um7T0", forHTTPHeaderField: "Authorization")
            // Add more headers as needed
           // let parameters = ["key" : EnvironmentManager.shared.gcpApiKey]
            let jsonObject: [String: Any] = [
                    "ruleSet": [
                        [
                            "infoTypes": [
                                ["name": "TIME"] as [String : Any],
                                ["name": "DATE"]
                            ],
                            "rules": [
                                [
                                    "exclusionRule": [
                                        "excludeInfoTypes": [
                                            "infoTypes": [
                                                ["name": "TIME"],
                                                ["name": "DATE"]
                                            ]
                                        ],
                                        "matchingType": "MATCHING_TYPE_PARTIAL_MATCH"
                                    ] as [String : Any]
                                ]
                            ]
                        ]
                    ]
                ]
            let json1: [String: Any] = ["inspectConfig" : jsonObject, "byteItem" : ["data" : bytesData,"type": "IMAGE"]]
            
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: json1)
            } catch {
                print("Error encoding request parameters: \(error)")
            }
            
            // Create a URLSession task
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    // Handle the response data here
                    if let responseString = String(data: data, encoding: .utf8) {
                        //print("Response data: \(responseString)")
                        
                        do {
                            let jsonDecoder = JSONDecoder()
                            let redactedResponseModel = try jsonDecoder.decode(RedactedResponseModel.self, from: data)
                            let base64EncodedString = redactedResponseModel.redactedImage
                            let image = base64EncodedString.imageFromBase64
                            if let image = image {
                                if let imageData = image.jpegData(compressionQuality: 0.8) {
                                    self.uploadRedactedImageToCss(redactedImage: imageData, fileName: fileName, contentType: contentType)
                                }
                            }
                        } catch {
                            print("couldn't convert gcp error")
                        }
                        
                    }
                }
            }
            
            // Start the task
            task.resume()
        }
    }
    
    func uploadRedactedImageToCss(redactedImage: Data,fileName: String, contentType: String) {
       
        let baseUrl = "https://contentservice-c4sapqe.qe.bp-paas.otxlab.net/v2/content"

        let urlComponents = URLComponents(string: baseUrl)

        _ = urlComponents?.url // Replace with your server URL

        if let url = urlComponents?.url {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let boundary = "Boundary-\(UUID().uuidString)"
            
            // Set the content type to multipart/form-data with the specified boundary
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            if let accessToken = AuthenticationManager.shared.accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
           
            
            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//
//            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append(MultipartFormDataUploadHelper().buildMultipartHeader(fileName: fileName, contentType: contentType))
            body.append(redactedImage)
           // body.append(MultipartFormDataUploadHelper().buildMultipartFooter())
            body.append("\r\n".data(using: .utf8)!)

            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
            
            // Create a URLSession task
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    // Process the response data
                    let responseString = String(data: data, encoding: .utf8)
                    print("redacted image uploaded to css")
                    do {
                        let jsonDecoder = JSONDecoder()
                        let uploadResponseModel = try jsonDecoder.decode(UploadResponseModel.self, from: data)
                        
                        if let uploadModelEntries = uploadResponseModel.entries {
                            print("redacted blob id \(uploadModelEntries[0].blobId)")
                            if let blobId = uploadModelEntries[0].blobId {
                                self.uploadFilesToCms(blobIdRedacted: blobId)
                            }
                        }
                        
                        
                        // Decode the Base64 content
                       
                    } catch {
                        print("couldn't upload redacted image to cms")
                    }
                }
            }
            
            // Start the URLSession task
            task.resume()
        }

    }
    
  
    
    func uploadImageToCss(image: Data, fileName: String, contentType: String) {
       
        let baseUrl = "https://contentservice-c4sapqe.qe.bp-paas.otxlab.net/v2/content"

        let urlComponents = URLComponents(string: baseUrl)

        _ = urlComponents?.url // Replace with your server URL

        // Create a URLRequest
        if let url = urlComponents?.url {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            // Create a boundary string that separates the multipart form data
            let boundary = "Boundary-\(UUID().uuidString)"
            
            // Set the content type to multipart/form-data with the specified boundary
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            if let accessToken = AuthenticationManager.shared.accessToken {
                request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            }
           
            var body = Data()
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//
//            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
//            body.append("Content-Type: application/json\r\n\r\n".data(using: .utf8)!)
            body.append(MultipartFormDataUploadHelper().buildMultipartHeader(fileName: fileName, contentType: contentType))
            body.append(image)
           // body.append(MultipartFormDataUploadHelper().buildMultipartFooter())
            body.append("\r\n".data(using: .utf8)!)

            body.append("--\(boundary)--\r\n".data(using: .utf8)!)
            request.httpBody = body
            
            // Create a URLSession task
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error != nil {
                } else if let data = data {
                    // Process the response data
                    do {
                        let jsonDecoder = JSONDecoder()
                        let uploadResponseModel = try jsonDecoder.decode(UploadResponseModel.self, from: data)
                        
                        if let uploadModelEntries = uploadResponseModel.entries {
                            print("blob id Initial\(uploadModelEntries[0].blobId)")
                            if let blobId = uploadModelEntries[0].blobId {
                                self.blobIdInitial = blobId
                            }
                        }
                    } catch {
                        print("couldn't upload initial image to css")
                    }
                }
            }
            
            // Start the URLSession task
            task.resume()
        }

    }

    func uploadFilesToCms(blobIdRedacted: String) {
        let currentDateTime = Date().formatted()
        let fileService = FilesService()
        let fileName = "Reports-\(currentDateTime)".replacingOccurrences(of: "/", with: "-")
        
        let task = Task {
            do {
                let response = try await fileService.uploadFilesToCms(fileName: fileName, rootFolderId: rootFolderid, blobIdInitial: self.blobIdInitial, blobIdMasked: blobIdRedacted)?.async()
                print("uploaded files to cms blobId initial \(blobIdInitial) blob id redacted \(blobIdRedacted) ")
                NotificationCenter.default.post(name: .uploadSuccess, object: nil)
            } catch let error  {
                if let error = error as? CoreError {
                    print(error.message)
                }
                //return nil
            }
        }
        self.taskRequests.insert(task)
        
    }
}

class CoreUploadObject: NSObject {
    var completionBlocks: [CoreUploadManager.UploadCompletionBlock]
    var progressBlocks: [CoreUploadManager.UploadProgressBlock?]?
    var uploadTask: AnyCancellable
    let fileData:UploadDocumentDetails
    var progress:Double?
    let taskDescription:String
    var errorMessage:String? = nil
    var failType:UploadFailType = .none
    var isEligibleForRetry = false
    var uploadResponse:UploadResponseModel? = nil
    var isPermanentError:Bool = true
    var service: FilesService
    
    init(uploadTask: AnyCancellable,
         taskDescription:String,
         progressBlocks: [CoreUploadManager.UploadProgressBlock?]?,
         completionBlocks: [CoreUploadManager.UploadCompletionBlock],
         fileData: UploadDocumentDetails,
         service:FilesService,
         progress:Double? = 0) {
        
        self.uploadTask = uploadTask
        self.taskDescription = taskDescription
        self.completionBlocks = completionBlocks
        self.progressBlocks = progressBlocks
        self.fileData = fileData
        self.service = service
        self.progress = progress
    }
    
//    func showMessage(with error: CoreError?) {
//        if let error = error {
//            NotificationCenter.default.post(name: .showBannerMessage, object: nil, userInfo: [BANNER_MESSAGE_TYPE : BannerMessageType.errorMessage, BANNER_MESSAGE : String.localizedStringWithFormat(VERSION_FAILED_TOAST_MESSAGE,fileData.name)])
//            errorMessage = error.message
//        } else {
//            NotificationCenter.default.post(name: .showBannerMessage, object: nil, userInfo: [BANNER_MESSAGE_TYPE : BannerMessageType.successMessage, BANNER_MESSAGE : String.localizedStringWithFormat(VERSION_ADDED_TOAST_MESSAGE,fileData.versionName ?? "File")])
//        }
//    }
}

//extension CoreUploadObject: BannerListItem {
//    var bannerProgress: Double {
//        return progress ?? 0
//    }
//
//    var bannerFileName: String {
//        fileData.name
//    }
//
//    var bannerAccessibilityLabel:String {
//        return bannerErrorMessage == nil ? String.localizedStringWithFormat(SINGLE_UPLOAD_SUCCESS, bannerFileName) : "\(bannerFileName)"
//    }
//
//    var bannerImageName: String {
//        fileData.mimeTypeImageName
//    }
//
//    var bannerErrorMessage: String? {
//        return errorMessage
//    }
//
//    var bannerFileUrl: String? {
//        return nil
//    }
//
//    func updateProgress(_ progress: Double) {
//        self.progress = progress
//    }
//
//    func updateError(_ error: String?) {
//        self.errorMessage = error
//    }
//
//    func cancelOperation() {
//        CoreUploadManager.shared.cancelUpload(forUniqueKey: fileData.fileKey)
//    }
//
//    func retryOperation(taskProgress:@escaping((Double)->Void)) {
//        updateError(nil)
//        if failType == .metadata {
//            progress = 0.98
//
//        } else if failType == .content {
//            progress = 0
//            updateError(ERROR_UNKNOWN_ERROR)
//        }
//
//        taskProgress(bannerProgress)
////        NotificationCenter.default.post(name: .retryUpload, object: self)
//
//        if failType == .content {
//            CoreUploadManager.shared.uploadFile(fileData: fileData, service: self.service, onProgress: { progress, fileKey in
//                if progress < 1 {
//                    taskProgress(progress)
//                }
//                self.updateProgress(progress)
//            }, onCompletion: { node, fileKey, error in
//                taskProgress(1)
//                self.updateProgress(1)
//                self.updateError(error?.message)
//            })
//        }
//    }
//
//}


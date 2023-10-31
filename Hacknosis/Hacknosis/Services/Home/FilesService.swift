//
//  FilesService.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 17/10/23.
//

import Foundation
import Combine

class FilesService:CoreAbstractService {
    
    func publisher(for type: NodeRouterType)-> AnyPublisher<URLSession.DataTaskPublisher.Output, CoreError>? {
        var router: FilesRouter
        
//        if let sharedLink {
//            router = NodeRouter(routerType: type, sharedLink: sharedLink)
//        } else {
            router = FilesRouter(routerType: type)
      //  }
        return callAPI(router: router)
    }
    
    /**
     Get a node object based on node id
     - parameters:
     - nodeId: the id of the node
     */
    func getReports(rootId:String) -> AnyPublisher<NodeCollectionModel, Error>? {
        guard let publisher = publisher(for: .getReportsList(rootId: rootId)) else { return nil }
        let pub = publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: NodeCollectionModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        return pub
    }
    
//    func uploadFileToCss(filePath:URL) -> AnyPublisher<CssUploadResponseModel, Error>? {
//        guard let publisher = publisher(for: .uploadFileToCss(filePath: filePath)) else { return nil }
//        let pub = publisher
//            .tryMap { output in
//                return try self.checkOutput(output: output)
//            }
//            .decode(type: CssUploadResponseModel.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//        return pub
//    }
    
    func uploadDocument(withRouter router:CoreRouterProtocol, fileUrl:URL, session:CoreURLSession, taskDescription:String, completion:@escaping(_ node:UploadResponseModel?, _ progress:Double?, _ error:CoreError?) -> Void)  -> AnyCancellable? {
        
        guard let publisher = callUploadDocumentAPI(router: router, fileURL: fileUrl, session: session, taskDescription: taskDescription) else { return nil }
        let cancellable = publisher
            .tryMap({ output in
                return try self.checkUploadDocumentOutput(output: output)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionHandler in
                self.handleDownloadCompletionHandler(completionHandler: completionHandler, completion:completion)
            }) { object in
                if let data = object.data {
                    let decoder = JSONDecoder()
                    let node = try? decoder.decode(UploadResponseModel.self, from: data)
                    completion(node, nil, nil)
                } else {
                    completion(nil, object.progress, nil)
                }
            }
        return cancellable
    }
    
    
    func getUploadedNodeDetails(uploadModel: UploadFileWithPropertiesModel, completion:@escaping(_ node:NodeModel?, _ error:CoreError?) -> Void) -> AnyCancellable? {

        guard let publisher = publisher(for: .getNodeDetailsWithBlobId(uploadModel: uploadModel)) else { return nil }
        let cancellable = publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: NodeModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionHandler in
                self.handleCompletionHandler(completionHandler: completionHandler, completion:completion)
            }, receiveValue: { (nodeCollection) in
                completion(nodeCollection, nil)
            })
        
        return cancellable
    }
    
    func getMaskedFileFromGcp(bytesData: String) -> AnyPublisher<RedactedResponseModel, Error>? {

        guard let publisher = publisher(for: .getMaskedFileFromGCP(bytesData: bytesData)) else { return nil }
        let pub = publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: RedactedResponseModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return pub
    }
    
    func uploadFilesToCms(fileName: String, rootFolderId: String, blobIdInitial: String, blobIdMasked: String) -> AnyPublisher<NodeModel, Error>? {
        guard let publisher = publisher(for: .uploadFileToCms(fileName: fileName, rootFolderId: rootFolderId, blobIdInitial: blobIdInitial, blodIdMasked: blobIdMasked)) else { return nil }
        let pub = publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: NodeModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return pub
    }
    
    func downloadDocument(withRouter router:CoreRouterProtocol, session:CoreURLSession, completion:@escaping(_ fileUrl:URL?, _ progress:Double?, _ error:CoreError?) -> Void)  -> AnyCancellable? {
        
        guard let publisher = callDownloadDocumentAPI(router: router, session: session) else { return nil }
        let cancellable = publisher
            .tryMap({ output in
                return try self.checkDownloadDocumentOutput(output: output)
            })
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionHandler in
                self.handleDownloadCompletionHandler(completionHandler: completionHandler, completion:completion)
            }) { object in
                completion(object.url, object.progress, nil)
            }
        return cancellable
    }
    
    func getShareLink(nodeId: String) -> AnyPublisher<ShareResponseModel, Error>? {
        guard let publisher = publisher(for: .getShareLink(nodeId: nodeId)) else { return nil }
        let pub = publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: ShareResponseModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
        return pub
    }
    
    func addComment(nodeId:String, comment:String, completion:@escaping(_ node:NodeModel?, _ error:CoreError?) -> Void) -> AnyCancellable? {

        guard let publisher = publisher(for: .addComment(nodeId: nodeId, comment: comment)) else { return nil }
        let cancellable = publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: NodeModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionHandler in
                self.handleCompletionHandler(completionHandler: completionHandler, completion:completion)
            }, receiveValue: { (nodeCollection) in
                completion(nodeCollection, nil)
            })
        
        return cancellable
    }
    
//    func getMembersInGroup(groupId: String) -> AnyPublisher<MembersCollectionModel, Error>? {
//        guard let publisher = publisher(for: .getMembersInGroup(groupId: groupId)) else { return nil }
//        let pub = publisher
//            .tryMap { output in
//                return try self.checkOutput(output: output)
//            }
//            .decode(type: MembersCollectionModel.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//
//        return pub
//    }
    
    func getMembersInGroup(groupId: String, completion:@escaping(_ node:MembersCollectionModel?, _ error:CoreError?) -> Void) -> AnyCancellable? {

        guard let publisher = publisher(for: .getMembersInGroup(groupId: groupId)) else { return nil }
        let cancellable = publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: MembersCollectionModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completionHandler in
                self.handleCompletionHandler(completionHandler: completionHandler, completion:completion)
            }, receiveValue: { (membersCollectionModel) in
                completion(membersCollectionModel, nil)
            })
        
        return cancellable
    }

    
//    func getMaskedContent(nodeId: String, completion:@escaping(_ node:NodeCollectionModel?, _ error:CoreError?) -> Void) -> AnyCancellable? {
//
//        guard let publisher = publisher(for: .getMaskedConent(nodeId: nodeId)) else { return nil }
//        let cancellable = publisher
//            .tryMap { output in
//                return try self.checkOutput(output: output)
//            }
//            .decode(type: NodeCollectionModel.self, decoder: JSONDecoder())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completionHandler in
//                self.handleCompletionHandler(completionHandler: completionHandler, completion:completion)
//            }, receiveValue: { (nodeCollectionModel) in
//                completion(nodeCollectionModel, nil)
//            })
//
//        return cancellable
//    }

        func getMaskedContent(nodeId: String) -> AnyPublisher<ResponseModelNode, Error>? {
            guard let publisher = publisher(for: .getMaskedConent(nodeId: nodeId)) else { return nil }
            let pub = publisher
                .tryMap { output in
                    return try self.checkOutput(output: output)
                }
                .decode(type: ResponseModelNode.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
    
            return pub
        }
    
    func getReportsHistory(nodeId: String) -> AnyPublisher<ReportsHistoryModel, Error>? {
        guard let publisher = publisher(for: .getReportsHistory(nodeId: nodeId)) else { return nil }
        let pub = publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: ReportsHistoryModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return pub
    }
    
    func updateReports(nodeId: String) -> AnyPublisher<ReportsHistoryModel, Error>? {
        guard let publisher = publisher(for: .updateReports(nodeId: nodeId)) else { return nil }
        let pub = publisher
            .tryMap { output in
                return try self.checkOutput(output: output)
            }
            .decode(type: ReportsHistoryModel.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        return pub
    }
}

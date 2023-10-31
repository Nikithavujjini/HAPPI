//
//  FilesRouter.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 17/10/23.
//

import Foundation

enum NodeRouterType {
    ///Get node based on node id
    case getReportsList(rootId:String)
    case uploadFileToCss(name:String, mimeType:String)
    case getNodeDetailsWithBlobId(uploadModel: UploadFileWithPropertiesModel)
    case getMaskedFileFromGCP(bytesData: String)
    case uploadFileToCms(fileName: String, rootFolderId: String,blobIdInitial: String,blodIdMasked: String)
    case getDocumentDownloadUrl(uri: String)
    case getShareLink(nodeId: String)
    case addComment(nodeId: String, comment: String)
    case getMembersInGroup(groupId: String)
    case getMaskedConent(nodeId: String)
    case getReportsHistory(nodeId: String)
    case updateReports(nodeId: String)
}

/**
 Used for node routes.
 */
class FilesRouter:CoreAbstractRouter {
    var routerType:NodeRouterType
  //  private var sharedLink: LinkShareModel?

    ///This part of the url should just include the host.
    override var hostUrl:URL? {
        guard let hostUrl = EnvironmentManager.shared.cmsUrl else { return nil }
        return hostUrl
    }
    
    var cssHostUrl: URL? {
        guard let hostUrl = EnvironmentManager.shared.cssUrl else { return nil }
        return hostUrl
    }
    
    var gcpHostUrl: URL? {
        guard let hostUrl = EnvironmentManager.shared.gcpUrl else { return nil }
        return hostUrl
    }
    
    override var hostWithPathUrl: URL? {
        guard var apiUrl = hostUrl else { return nil }
        switch routerType {
        case .getReportsList(let rootId):
            apiUrl.appendPathComponent("instances/folder/cms_folder")
            apiUrl.appendPathComponent(rootId)
            apiUrl.appendPathComponent("items")
            return apiUrl
            
            case .uploadFileToCss:
            guard var  apiUrl1 = cssHostUrl else { return nil }
                apiUrl1.appendPathComponent("v2/content")
                return apiUrl1
        case .getNodeDetailsWithBlobId(_):
            apiUrl.appendPathComponent("node")
            return apiUrl

        case .getMaskedFileFromGCP(_):
            guard var apiUrl1 = gcpHostUrl else { return nil }
            apiUrl1.appendPathComponent("v2/projects")
            apiUrl1.appendPathComponent(gcpProjectName)
            apiUrl1.appendPathComponent("image:redact")
            return apiUrl1
        case .uploadFileToCms:
            apiUrl.appendPathComponent("instances/file/def_patient_doc_type")
            return apiUrl
        case .getDocumentDownloadUrl(let uri):
            var hostString = EnvironmentManager.shared.currentEnvironmentUrlWithSubscription?.absoluteString ?? ""
            hostString += uri
            return URL(string: hostString)
        case .getShareLink(_):
            apiUrl.appendPathComponent("shared-links")
            return apiUrl
        case .addComment(let nodeId, _):
            apiUrl.appendPathComponent("instances/file/def_patient_doc_type")
            apiUrl.appendPathComponent(nodeId)
            return apiUrl
        case .getMembersInGroup(let groupId):
            apiUrl.appendPathComponent("groups")
            apiUrl.appendPathComponent(groupId)
            apiUrl.appendPathComponent("members")
            return apiUrl
        case .getMaskedConent(let nodeId):
            apiUrl.appendPathComponent("instances/file/def_patient_doc_type")
            apiUrl.appendPathComponent(nodeId)
            apiUrl.appendPathComponent("contents")
            return apiUrl
        case .getReportsHistory(let nodeId):
            apiUrl.appendPathComponent("instances/file/def_patient_doc_type")
            apiUrl.appendPathComponent(nodeId)
            apiUrl.appendPathComponent("history")
            return apiUrl
        case .updateReports(let nodeId):
            apiUrl.appendPathComponent("instances/any/cms_any")
           // apiUrl.appendPathComponent("def_patient_doc_type")
            apiUrl.appendPathComponent(nodeId)
            apiUrl.appendPathComponent("history")
            return apiUrl
        }
    }
    
    override var contentType: HTTPContentType {
        switch routerType {

        case .uploadFileToCss:
            return .multipart
        case .getNodeDetailsWithBlobId, .getMaskedFileFromGCP, .uploadFileToCms, .getShareLink, .addComment(_, _), .updateReports:
            return .json
        default: return .any
        }
    }
    
    override var httpMethod: HTTPMethod {
        switch routerType {
        case .getReportsList(_):
            return .get
        case .uploadFileToCss, .getNodeDetailsWithBlobId, .getMaskedFileFromGCP, .uploadFileToCms, .getShareLink, .updateReports:
            return .post
        case .addComment(_, _):
            return .patch
        default:
            return .get
        }
    }
    

    
    override var httpBody: Data? {
        switch routerType {
            
        case .getReportsList(_), .uploadFileToCss :
            return nil
        case .getNodeDetailsWithBlobId(let uploadModel):
            var json: [String: Any] = ["crude_op" : "create"]
           // json["cms_category"] = uploadModel.cmsCategory
            json["cms_type"] = uploadModel.cmsType
            json["description"] = uploadModel.description
            json["blob_id"] = uploadModel.blobId
            json["content_size"] = uploadModel.contentSize
            json["mime_type"] = uploadModel.mimeType
            json["name"] = uploadModel.name
            json["parent_id"] = uploadModel.parentId
            json["traits"] = uploadModel.traits
            json["properties"] = uploadModel.properties
            json["version_label"] = uploadModel.versionLabel
            
            if let caseNodeId = uploadModel.caseNodeId {
                json["case_node_id"] = caseNodeId
            }
            
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            return jsonData
        case .getMaskedFileFromGCP(let bytesData):
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
            
            var json1: [String: Any] = ["inspectConfig": jsonObject, "byteItem" : ["data" : bytesData,"type": "IMAGE"]]
            let jsonData = try? JSONSerialization.data(withJSONObject: json1)
            return jsonData
        case .uploadFileToCms(let fileName,let rootFolderId,let blobIdInitial,let blodIdMasked):
            var json: [String: Any] = ["name": fileName]
            json["parent_folder_id"] = rootFolderId
            json["acl_id"] = "943fd345-0616-4184-96ba-bc3a31ecbe2a"
            json["renditions"] = [["blob_id": blobIdInitial,"name":"original_doc","rendition_type":"PRIMARY"], ["blob_id":blodIdMasked,"name":"pii_masked_doc","rendition_type":"secondary"]]
            json["properties"] = ["reviewed" : false]
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            return jsonData

        case .getShareLink(let nodeId):
            let requestBodyDict: [String: Any] = [
                "item_id": nodeId,
                "expiration_time": "2023-11-28T00:42:07.544Z",
                "link_uri": "com.opentext.sha/shared/docs/\(nodeId)",
                "public": true,
                "properties": [
                    "password": "Password@123"
                ],
                "permissions": [
                    [
                        "identity": "application_admin",
                        "identity_type": "role",
                        "permissions": [
                            "browse",
                            "read_content"
                        ]
                    ] as [String : Any]
                ]
            ]
            let jsonData = try? JSONSerialization.data(withJSONObject: requestBodyDict)
            return jsonData
        case .addComment(_, let comment):
            var json: [String: Any] = [:]
            var propertiesDict : [String: Any] = [:]
            propertiesDict["reviewed"] = true
            propertiesDict["doctors_comments"] = comment
            json["properties"] = propertiesDict
            let jsonData = try? JSONSerialization.data(withJSONObject: json)
            return jsonData
        case .updateReports(let nodeId):
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let date = dateFormatter.date(from: Date().description)
            
            let requestBodyDict: [String: Any] = [
                "action_name": "REVIEWED",
                "event_source": "DOCTOR",
                "event_user": UserHelper.getCurrentUserFromRealm()?.email ?? "",  //doctor's mail address
                "event_status": "SUCCESS",
                "object_category": "file",
                "object_type": "cms_file",
                "subscription_id": UserHelper.getCurrentUserFromRealm()?.subscriptionUserId ?? "", // current subscription id
                "object_id": nodeId,
                "object_name": nodeId,
                "chronicle_id": nodeId,
                "create_time": date ?? "", // mobile should find and send this time
                "update_time": date ?? "" // mobile should find and send this time
            ]
            let jsonData = try? JSONSerialization.data(withJSONObject: requestBodyDict)
            return jsonData
        default:
            return nil
        }
    }
    
    override var queryParameters: HTTPParameters {
        switch routerType {
        
        case .getReportsList(_):
           
               return ["include-children-total" : "false", "fetch-latest" : "true", "fetch-shared" : "true", "fetch-custom-attrs" : "true"]
           //}
        case .getMaskedFileFromGCP(_):
            return ["key" : EnvironmentManager.shared.gcpApiKey]
//        case .getMembersInGroup(_):
//            return ["items-per-page" : 100]
        default:
            return [:]
        }
    }
    
    
    init(routerType:NodeRouterType){
        self.routerType = routerType
        super.init()
    }
    
    override var acceptContentType: HTTPContentType? {
        switch routerType {
        case .getReportsList(_), .uploadFileToCss(_, _), .getNodeDetailsWithBlobId(_) :
            return .halJson
        default :
            return .any
        }
    }
        
}



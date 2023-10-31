//
//  CssUploadResponseModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import Foundation


struct UploadResponseModel:Decodable {
    var entries:[EntriesModel]?
    
    struct EntriesModel:Decodable {
        var mimeType:String?
        var fileName:String?
        var id:String?
        var blobId:String?
        var size:Int?
    }
}


struct UploadFileWithPropertiesModel {
    var blobId:String?
    var caseNodeId:String?
    var fileID:String? = nil
    var cmsType:String = "cms_file"
    var contentSize:Int?
    var crudeOp:String = "create"
    var description:String = ""
    var mimeType:String?
    var name:String?
    var parentId:String?
    var properties:[String:Any]?
    var traits:[String:Any]?
    var ownerID: String? = nil
    var versionLabel:[String] = ["INITIAL"]
    var type:String = "cms_file"
    
    init(uploadModel: UploadResponseModel, coreModel: CoreUploadObject, isVersionType: Bool = false) {
        blobId = uploadModel.entries?.last?.id
        caseNodeId = coreModel.fileData.caseNodeId
        cmsType =  coreModel.fileData.uploadFileAttributes?.cmsType ?? "cms_file"
        contentSize = uploadModel.entries?.last?.size
        mimeType = coreModel.fileData.mimeType
        name = coreModel.fileData.name
        parentId = coreModel.fileData.parentId
        type = coreModel.fileData.type

        if isVersionType {
            versionLabel = ["New primary"]
            ownerID = coreModel.fileData.ownerID
            fileID = coreModel.fileData.fileID
            name = coreModel.fileData.computedVersionName()
        }
    }
}


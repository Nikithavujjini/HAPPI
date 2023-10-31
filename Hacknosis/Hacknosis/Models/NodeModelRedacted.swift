//
//  NodeModelRedacted.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 26/10/23.
//

import Foundation
import Combine
import RealmSwift

class NodeModelRedacted:Object, Decodable, Identifiable {
    //MARK: - Persisted Variables
    @Persisted var id:String
    @Persisted var name:String
    @Persisted var mimeType:String?
    
    @Persisted var blobId: String
    @Persisted var renditionType: String
    
    
    
    
    
    var formattedTime:String? = nil
    var imageName: String {
        return ASSET_IMAGE_FILE_TYPE_IMAGE
    }
    
    
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case mimeType = "mime_type"
        
        case blobId = "blob_id"
        case renditionType = "rendition_type"
        
    }
    
    //MARK: - initialization
    override init() {
        id = EMPTY_STRING
        name = EMPTY_STRING
        super.init()
    }
    
    init(name:String, contentSize:Int) {
        id = UUID().uuidString
        //   self.contentSize = contentSize
        self.name = name
    }
    
    init(id: String, name: String, mimeType:String, contentSize: Int, errorMessage: String? = nil) {
        self.id = id
        self.name = name
        self.mimeType = mimeType
        //        self.contentSize = contentSize
        //        self.updateTime = EMPTY_STRING
        //        self.versionNo = 1
        // self.errorMessage = errorMessage
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        name = try values.decode(String.self, forKey: .name)
        
        
        if let mimeType = try values.decodeIfPresent(String.self, forKey: .mimeType) {
            self.mimeType = mimeType
        } else {
            self.mimeType = nil
        }
        
        
        
    }
    
    
    
    
    
    var fileId: String {
        return id
    }
    
    
    var fileMimeType: String? {
        return mimeType
    }
}

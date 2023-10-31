//
//  NodeCollectionModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 17/10/23.
//

import Foundation

struct NodeCollectionModel:Decodable {
    
    //MARK: - Inner objects
    struct Page:Decodable {
        var sort:String
        var size:Int
        var totalElements:Int
        var totalPages:Int
        var number:Int
    }
    
    struct Embedded:Decodable {
        var collection:[NodeModel]
    }
    
    //MARK: - Variables
    var embedded:Embedded?
    var page:Int?
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
        case page = "page"
    }
    
}



struct CreatedBy: Decodable {
    let id: String?
    let identity_type: String?
    let first_name: String?
    let last_name: String?
    let service_account: Bool?
    let email: String?
    let subscription_user_status: String?
    let otds_uuid: String?
    let user_profile_id: String?
    let user_profile_status: String?
}

struct UpdatedBy: Decodable {
    let id: String?
    let identity_type: String?
    let first_name: String?
    let last_name: String?
    let service_account: Bool?
    let email: String?
    let subscription_user_status: String?
    let otds_uuid: String?
    let user_profile_id: String?
    let user_profile_status: String?
}

struct Owner: Decodable {
    let id: String?
    let identity_type: String?
    let first_name: String?
    let last_name: String?
    let service_account: Bool?
    let email: String?
    let subscription_user_status: String?
    let otds_uuid: String?
    let user_profile_id: String?
    let user_profile_status: String?
}

struct LinkNodes: Decodable {
    let parent: Href?
    let downloadMedia: Href?
    let selfLink: Href?
    let edit: Href?
    let delete: Href?
    
    enum CodingKeys: String, CodingKey {
        case parent
        case downloadMedia = "urn:eim:linkrel:download-media"
        case selfLink = "self"
        case edit
        case delete = "urn:eim:linkrel:delete"
    }
}

struct CollectionItemNode: Decodable {
    let id: String?
    let create_time: String?
    let update_time: String?
    let created_by: CreatedBy?
    let updated_by: UpdatedBy?
    let etag: Int?
    let owner: Owner?
    let name: String?
    let mime_type: String?
    let content_size: Int?
    let blob_id: String?
    let rendition_type: String?
    let owner_id: String?
    let _links: CmsLinks?
}

struct EmbeddedNode: Decodable {
    let collection: [CollectionItemNode]
}

struct ResponseModelNode: Decodable {
    let _embedded: EmbeddedNode
    let _links: LinkNodes
    let page: Int
    let itemsPerPage: Int
}


struct UserIdentity: Decodable {
    let id: String?
    let first_name: String?
    let last_name: String?
    let service_account: Bool?
    let email: String?
    let subscription_user_status: String?
    let otds_uuid: String?
    let user_profile_id: String?
    let user_profile_status: String?
    let identity_type: String?
}

struct Links: Decodable {
    let parent: Href?
    let selfLink: Href?

    enum CodingKeys: String, CodingKey {
        case parent
        case selfLink = "self"
    }
}

struct Href: Decodable {
    let href: String?
}

struct CollectionItem: Decodable {
    let user_identity: UserIdentity?
    let links: Links?
}

struct Embedded: Decodable {
    let collection: [CollectionItem]
}

struct MembersCollectionModel: Decodable {
    let _embedded: Embedded
    let _links: Links
    let page: Int
    let itemsPerPage: Int
}

//
//  NodeModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 17/10/23.
//

import Foundation
import RealmSwift

final class CmsLink: Object {
    @Persisted var key = ""
    @Persisted var value : LinkRef?
}

final class User:Object, Decodable {
    
    //MARK: - Persisted variables
    @Persisted var id:String
    @Persisted var firstName:String?
    @Persisted var lastName:String?
    @Persisted var name:String?
    @Persisted var initials:String?
    @Persisted var role:String?
    @Persisted var email:String?
    @Persisted var tenantId:String?
    @Persisted var subscriptionNamespacePrefix:String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case initials
        case role = "role_name"
        case email
        case tenantId = "tenant_id"
        case subscriptionNamespacePrefix
        case firstName = "first_name"
        case lastName = "last_name"
    }
    override init() {
        super.init()
    }
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(String.self, forKey: .id)
        
        if let name = try values.decodeIfPresent(String.self, forKey: .name) {
            self.name = name
        } else {
            self.name = nil
        }
        if let firstName = try values.decodeIfPresent(String.self, forKey: .firstName) {
            self.firstName = firstName
        } else {
            self.firstName = nil
        }
        if let lastName = try values.decodeIfPresent(String.self, forKey: .lastName) {
            self.lastName = lastName
        } else {
            self.lastName = nil
        }
        
        if let initials = try values.decodeIfPresent(String.self, forKey: .initials) {
            self.initials = initials
        } else {
            self.initials = nil
        }
        if let role = try values.decodeIfPresent(String.self, forKey: .role) {
            self.role = role
        } else {
            self.role = nil
        }
        if let email = try values.decodeIfPresent(String.self, forKey: .email) {
            self.email = email
        } else {
            self.email = nil
        }
        if let tenantId = try values.decodeIfPresent(String.self, forKey: .tenantId) {
            self.tenantId = tenantId
        } else {
            self.tenantId = nil
        }
        if let subscriptionNamespacePrefix = try values.decodeIfPresent(String.self, forKey: .subscriptionNamespacePrefix) {
            self.subscriptionNamespacePrefix = subscriptionNamespacePrefix
        } else {
            self.subscriptionNamespacePrefix = nil
        }
    }
}

class PropertiesModel: Object, Decodable {
    @Persisted var doctors_comments: String?
    @Persisted var reviewed: Bool
}
class LinkRef: Object, Decodable {
    @Persisted var href: String?
}

final class CmsLinks:Object, Decodable {
    @Persisted var links = List<CmsLink>()
       
    
    //MARK: - initialization
    override init() {
        links = List<CmsLink>()
        super.init()
    }
    
    init(links:List<CmsLink>) {
        self.links = links
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CustomCodingKeys.self)
        for key in container.allKeys {
            if let value = try? container.decodeIfPresent(LinkRef.self, forKey: CustomCodingKeys(stringValue: key.stringValue)!) {
                let cmsLink = CmsLink()
                cmsLink.key = key.stringValue
                cmsLink.value = value
                links.append(cmsLink)
            }
        }
    }
}

struct CustomCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    init?(intValue: Int) {
        return nil
    }
}

class NodeModel:Object, Decodable, Identifiable {
    //MARK: - Persisted Variables
    @Persisted var id:String
    @Persisted var name:String
    @Persisted var mimeType:String?
    @Persisted var type:String
    @Persisted var parentId:String?
    @Persisted var contentSize:Int?
    @Persisted var updateTime:String
    @Persisted var cmsLinks:CmsLinks?
    @Persisted var versionNo:Int = 1

    @Persisted var owner:User?
    @Persisted var shared: Bool
    @Persisted var properties: PropertiesModel?

    
    

    var formattedTime:String? = nil
    var imageName: String {
                return ASSET_IMAGE_FILE_TYPE_IMAGE
            }
            
            
        
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case mimeType = "mime_type"
        case type
        case contentSize = "content_size"
        case updateTime = "update_time"
        case cmsLinks = "_links"
        case parentId = "parent_id"
        case versionNo = "version_no"
        case owner
        case shared
        case properties

    }
    
    //MARK: - initialization
    override init() {
        id = EMPTY_STRING
        name = EMPTY_STRING
        super.init()
    }
    
    init(name:String, contentSize:Int) {
        id = UUID().uuidString
        self.contentSize = contentSize
        self.name = name
    }
    
    init(id: String, name: String, mimeType:String, contentSize: Int, errorMessage: String? = nil) {
        self.id = id
        self.name = name
        self.mimeType = mimeType
        self.contentSize = contentSize
        self.updateTime = EMPTY_STRING
        self.versionNo = 1
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
        
        type = try values.decode(String.self, forKey: .type)

        if let contentSize = try values.decodeIfPresent(Int.self, forKey: .contentSize) {
            self.contentSize = contentSize
        } else {
            self.contentSize = nil
        }
        
        updateTime = try values.decode(String.self, forKey: .updateTime)

        if let cmsLinks = try values.decodeIfPresent(CmsLinks.self, forKey: .cmsLinks) {
            self.cmsLinks = cmsLinks
        } else {
            self.cmsLinks = nil
        }
        
        if let properties = try values.decodeIfPresent(PropertiesModel.self, forKey: .properties) {
            self.properties = properties
        }
        

        if let parentId = try values.decodeIfPresent(String.self, forKey: .parentId) {
            self.parentId = parentId
        } else {
            self.parentId = nil
        }
        
        if let versionNo = try values.decodeIfPresent(Int.self, forKey: .versionNo) {
            self.versionNo = versionNo
        }
        

        //use this
        if let user = try? values.decodeIfPresent(User.self, forKey: .owner) {
            self.owner = user
        }
//
        if let shared = try? values.decodeIfPresent(Bool.self, forKey: .shared) {
            self.shared = shared
        }
     
    
    }
    
    
    
   
    func ownerID() -> String? {
        return owner?.id
    }
       
    var fileId: String {
        return id
    }
    

    var fileType: String {
        return type
    }
    
    var fileUniqueKey:String {
        return (parentId ?? "") + name
    }
    
    var fileMimeType: String? {
        return mimeType
    }
    

    var originalFileUrl:String? {
        if let value = self.cmsLinks?.links.filter({$0.key == "urn:eim:linkrel:download-media"}).last?.value {
            //return value.href?.replacingCharacters(in: "https://contentservice-c4sapqe.qe.bp-paas.otxlab.net", with: "cs")
            var finalValue = ""
            if let value = value.href {
                finalValue = value.replacingOccurrences(of: "https://contentservice-c4sapqe.qe.bp-paas.otxlab.net", with: "/cs")
            }
            return finalValue
        }
        return ""
    }
    


    func getUpdatedTime(in dateFromat: DateFormatter) -> String {
        let formatter = DateHelper.ISO8601DateFormatter
        guard let date = formatter.date(from: updateTime) else { return EMPTY_STRING }
        return dateFromat.string(from: date)
    }
    
}

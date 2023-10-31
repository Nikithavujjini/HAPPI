//
//  UploadFileAttributeModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import Foundation


class UploadFileAttributesModel {
    var fileIndex:Int = 0
    var fileUrl:URL?

    var fileCmsType:String? = nil
    var name:String? = nil
    
    init(name:String?) {
        self.name = name
    }
    
    init(index:Int, fileUrl:URL?) {
        self.fileIndex = index
        self.fileUrl = fileUrl
 
    }
    
    var fileName:String {
        if let name = name {
            return name
        }
        return EMPTY_STRING
      //  return generalDataAttributeModels.first?.valueToDisplay ?? EMPTY_STRING
    }
    
//    var description:String {
//        if generalDataAttributeModels.count > 1 {
//            return generalDataAttributeModels.last?.valueToDisplay ?? EMPTY_STRING
//        }
//        return EMPTY_STRING
//    }
//
    var cmsType:String? {
        if let fileCmsType = fileCmsType {
            return fileCmsType
        }
        return nil
       // return documentTypeAttributeModels.last?.typeSystemName ?? nil
    }
    
//    var properties:[String:Any] {
//        //for add version
//        if let fileproperties = fileproperties {
//            var properties = [String:Any]()
//            for (key, value) in fileproperties.fields {
//                if key.last?.isNumber == true {
//                    if let value = value as? UserAttribute {
//                        properties[key] = value.asDictionary()
//                    } else if let value = value as? [UserAttribute] {
//                        var users = [[String: Any]]()
//                        for user in value {
//                            users.append(user.asDictionary())
//                        }
//                        properties[key] = users
//                    } else {
//                        properties[key] = value
//                    }
//                }
//            }
//            return properties
//        }
//
//        //for file upload
//        var properties = [String:Any]()
//        for attribute in documentTypeAttributeModels {
//            properties.updateValue(attribute.serverSupportedValues as Any, forKey: attribute.attributeName)
//        }
//        return properties
//    }
    
//    var traits:[String:Any] {
//        //for add version
//        if let fileTraits = fileTraits {
//            return fileTraits.asDictionary()
//        }
//
//        //for file upload
//        var finalProperties = [String:Any]()
//        for attributes in categoryAttributeModels {
//            var properties = [String:Any]()
//            let systemName = attributes.last?.typeSystemName ?? EMPTY_STRING
//            var catProperties = [String:Any]()
//            for attribute in attributes {
//                catProperties.updateValue(attribute.serverSupportedValues as Any, forKey: attribute.attributeName)
//            }
//            properties.updateValue(catProperties, forKey: systemName)
//            finalProperties.updateValue(properties, forKey: systemName)
//        }
//        return finalProperties
//    }
}

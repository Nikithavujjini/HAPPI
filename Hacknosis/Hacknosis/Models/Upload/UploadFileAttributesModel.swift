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
    
    var cmsType:String? {
        if let fileCmsType = fileCmsType {
            return fileCmsType
        }
        return nil
       // return documentTypeAttributeModels.last?.typeSystemName ?? nil
    }
    
}

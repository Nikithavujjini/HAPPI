//
//  RedactResponseModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 20/10/23.
//

import Foundation
import Swift

struct RedactedResponseModel:Decodable {
    var redactedImage:String
    
    
    enum CodingKeys: String, CodingKey {
        case redactedImage
        
    }
}




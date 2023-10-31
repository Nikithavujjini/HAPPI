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


//extension RedactedResponseModel {
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let base64DataEncoded = try container.decode(String.self, forKey: .redactedImage)
//
//            self.redactedImage = base64DataEncoded
//        
//    }
//}

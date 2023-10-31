//
//  AuthenticationModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 13/10/23.
//

import Foundation

struct AuthenticationModel:Decodable {
    
    //MARK: - Variables
    var accessToken:String
    var refreshToken:String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

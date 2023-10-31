//
//  EnvironmentModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 11/10/23.
//

import Foundation


final class EnvironmentModel {
    
    //MARK: - Variables
    var nameLocalizedKey:String
    var domain:String
    var authenticationUrl:String
    var sharedAuthenticationUrl:String
    var tokenUrl:String
    var publicKey:String
    var isHidden:Bool
    var cmsDomain: String
    var cssDomain:String
    var gcpDomain: String
    var gcpApiKey: String
    //MARK: - Initialization
    init(nameLocalizedKey:String, domain:String, authenticationUrl:String, sharedAuthenticationUrl:String, tokenUrl:String, publicKey:String, isHidden:Bool, cmsDomain: String, cssDomain:String, gcpDomain:String, gcpApiKey: String) {
        self.nameLocalizedKey = nameLocalizedKey
        self.domain = domain
        self.authenticationUrl = authenticationUrl
        self.sharedAuthenticationUrl = sharedAuthenticationUrl
        self.tokenUrl = tokenUrl
        self.publicKey = publicKey
        self.isHidden = isHidden
        self.cmsDomain = cmsDomain
        self.cssDomain = cssDomain
        self.gcpDomain = gcpDomain
        self.gcpApiKey = gcpApiKey
    }
    
}

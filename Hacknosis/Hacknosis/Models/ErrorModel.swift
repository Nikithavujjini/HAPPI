//
//  ErrorModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation

/**
 Used to store the error information
 */
struct ErrorModel:Decodable {
    
    //MARK: - Variables
    var error:String?
    var errorDescription:String?
    var message:String?
    var status:Int?
    var title:String?
    var details:String?
    var code:Int?
    var developerMessage:String?
    
    enum CodingKeys: String, CodingKey {
        case error
        case errorDescription = "error_description"
        case message
        case status
        case title
        case details
        case code
        case developerMessage
    }
    
    //MARK: - Initialization
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let error = try container.decodeIfPresent(String.self, forKey: .error) {
            self.error = error
        } else {
            self.error = nil
        }
        
        if let errorDescription = try? container.decodeIfPresent(String.self, forKey: .errorDescription) {
            self.errorDescription = errorDescription
        } else {
            self.errorDescription = nil
        }
        
        if let message = try container.decodeIfPresent(String.self, forKey: .message) {
            self.message = message
        } else {
            self.message = nil
        }
        
        if let status = try? container.decodeIfPresent(String.self, forKey: .status), let statusInt = Int(status) {
            self.status = statusInt
        } else if let status = try? container.decodeIfPresent(Int.self, forKey: .status) {
            self.status = status
        } else {
            self.status = nil
        }
        
        if let title = try container.decodeIfPresent(String.self, forKey: .title) {
            self.title = title
        } else {
            self.title = nil
        }
        
        if let details = try container.decodeIfPresent(String.self, forKey: .details) {
            self.details = details
        } else {
            self.details = nil
        }
        
        if let details = try container.decodeIfPresent(Int.self, forKey: .code) {
            self.code = details
        } else {
            self.code = nil
        }
        
        if let details = try container.decodeIfPresent(String.self, forKey: .developerMessage) {
            self.developerMessage = details
        } else {
            self.developerMessage = nil
        }
    }
    
}


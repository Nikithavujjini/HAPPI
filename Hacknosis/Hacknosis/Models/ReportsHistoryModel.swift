//
//  ReportsHistoryModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 29/10/23.
//

import Foundation

struct ReportsHistoryModel:Decodable {
    
    struct Embedded:Decodable {
        var collection:[HistoryModel]
    }
    
    //MARK: - Variables
    var embedded:Embedded?
    var page:Int?
    
    enum CodingKeys: String, CodingKey {
        case embedded = "_embedded"
       // case page = "page"
    }
    
}

struct HistoryModel: Decodable, Hashable, Identifiable {
    var id: ObjectIdentifier?
    
    var action_name: String
    var event_source: String
    var event_user: String
    var create_time: String
    var update_time: String
    enum CodingKeys: String, CodingKey {
        case action_name
        case event_user
        case create_time
        case update_time
        case event_source
       // case page = "page"
    }
//    var updatedTime: String {
//
//        //return create_time.fo
//    }
   
  
}

//
//  MultiPart.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 19/10/23.
//

import Foundation



public struct MultipartFormDataUploadHelper {
    
    //Per instance random multipart boundary string
    fileprivate let CRLF = "\r\n"
    fileprivate let PADDING = "--"
    let BOUNDARY = String(format: "core.content.boundary.%@", UUID().uuidString)
    
    public init(){}
        
    //MARK: - Private functions
    //Multipart header
     func buildMultipartHeader(fileName:String, contentType:String) -> Data {
        var part = ""
       // part.append(contentsOf:"\(PADDING)\(BOUNDARY)\(CRLF)")
        part.append(contentsOf:"Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\(CRLF)")
        part.append(contentsOf:"Content-Type: \(contentType)\(CRLF)\(CRLF)")
        return part.data(using: .utf8)!
    }
    
    //Multipart footer
     func buildMultipartFooter() -> Data {
        return "\(CRLF)\(PADDING)\(BOUNDARY)\(PADDING)".data(using: .utf8)!
    }

}

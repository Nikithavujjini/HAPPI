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
    
    public func buildMultipartFormDataUploadFile(sourceFileUrl:URL, fileName:String, contentType:String, completion:@escaping(_ url:URL?) -> Void) {
        DispatchQueue.global().async {
            let tempFileName = UUID().uuidString
            var tempURL = CoreFileUtils.getMultipartTempDirectory()
            CoreFileUtils.createDirectoriesIfNeeded(path: tempURL.path)
            tempURL.appendPathComponent(tempFileName)
            CoreFileUtils.removeFile(at: tempURL)
            //Write multipart form data file
            if let outputStream = OutputStream(toFileAtPath: tempURL.path, append: true), let inputStream = InputStream(url: sourceFileUrl) {
                outputStream.open()
                //multipart header
                let header = self.buildMultipartHeader(fileName: fileName, contentType: contentType)
                _ = header.withUnsafeBytes { (result) -> Bool in
                    outputStream.write(result.bindMemory(to: UInt8.self).baseAddress!, maxLength: header.count)
                    return true
                }
                //Write file to output stream
                inputStream.open()
                let bufferSize = 1024*10
                let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                while inputStream.hasBytesAvailable {
                    let read = inputStream.read(buffer, maxLength: bufferSize)
                    if read > 0 {
                        outputStream.write(buffer, maxLength: read)
                    } else {
                        break
                    }
                }
                buffer.deallocate()
                //multipart footer
                var footer = self.buildMultipartFooter()
                if contentType == "application/json" {
                    footer = "\n".data(using: .utf8)! + footer
                }
                _ = footer.withUnsafeBytes { (result) -> Bool in
                    outputStream.write(result.bindMemory(to: UInt8.self).baseAddress!, maxLength: footer.count)
                    return true
                }
                //Close streams
                outputStream.close()
                inputStream.close()
                
                CoreFileUtils.removeFile(at: sourceFileUrl)
                //Set file protection level to `complete unless open` so that background uploads will continue after user locks the device.
                do {
                    try (tempURL as NSURL).setResourceValue( URLFileProtection.completeUntilFirstUserAuthentication, forKey: .fileProtectionKey)
                } catch {
                    completion(nil)
                }
                completion(tempURL)
            } else {
                CoreFileUtils.removeFile(at: sourceFileUrl)
                completion(nil)
            }
        }
    }
    
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

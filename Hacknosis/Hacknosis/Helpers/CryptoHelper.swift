//
//  CryptoHelper.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation
import CommonCrypto

public struct CryptoHelper {
    ///Used to create Base64url encoding without padding as described in https://tools.ietf.org/html/rfc7636#appendix-A
    public static func encodeBase64urlNoPadding( data:Data ) -> String {
        var base64string:String = data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        // converts base64 to base64url
        base64string = base64string.replacingOccurrences(of: "+", with: "-")
        base64string = base64string.replacingOccurrences(of: "/", with: "_")
        // strips padding
        base64string = base64string.replacingOccurrences(of: "=", with: "")
        return base64string
    }
    
    ///Generates random url safe string with given length
    public static func randomURLSafeStringWithSize(size:Int) -> String? {
        var data = Data(count: size)
        let result = data.withUnsafeMutableBytes { unsafeMutableRawBufferPointer -> Bool in
            if let bytes = unsafeMutableRawBufferPointer.bindMemory(to: UInt8.self).baseAddress {
                _ = SecRandomCopyBytes(kSecRandomDefault, size, bytes)
                return true
            } else {
                return false
            }
        }
        if !result {
            return nil
        }
        return String(CryptoHelper.encodeBase64urlNoPadding(data: data).prefix(size))
    }
    
    ///Used to create the code challenge for PKCE for Oauth as described [here](https://tools.ietf.org/html/rfc7636#appendix-B)
    public static func sha256( string:String ) -> Data {
        let data = string.data(using: .utf8)
        var sha256HashData = Data(count:Int(CC_SHA256_DIGEST_LENGTH))
        _ = sha256HashData.withUnsafeMutableBytes { (digestBytes) -> Bool in
            _ = data!.withUnsafeBytes({ (messageBytes) -> Bool in
                CC_SHA256(messageBytes.bindMemory(to: UInt8.self).baseAddress, CC_LONG(data!.count), digestBytes.bindMemory(to: UInt8.self).baseAddress)
                return true
            })
            return true
        }
        return sha256HashData
    }
}


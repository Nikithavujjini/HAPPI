//
//  SSLHelper.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 31/10/23.
//

import Foundation
import Security
import CommonCrypto

public class SSLPinningHandler: NSObject  {
    var sslErrorOccured = false
    
    let rsa2048Asn1Header:[UInt8] = [
        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
    ]
    
    func sha256(data : Data) -> String {
        var keyWithHeader = Data(rsa2048Asn1Header)
        keyWithHeader.append(data)
        var hash = [UInt8](repeating: 0,  count: Int(CC_SHA256_DIGEST_LENGTH))

        keyWithHeader.withUnsafeBytes { ptr in
            _ = CC_SHA256(ptr.baseAddress, CC_LONG(keyWithHeader.count), &hash)
        }

        return Data(hash).base64EncodedString()
    }
    
    func sslPinning(for challenge: URLAuthenticationChallenge,with completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        sslErrorOccured = false
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil);
            return
        }
        var publickKeyLocal = ""
        
        // Local Hash Key
        if let env = EnvironmentManager.shared.currentEnvironment {
            publickKeyLocal = env.publicKey
        }
        
        if publickKeyLocal.isEmpty {
            completionHandler(.useCredential, URLCredential(trust:serverTrust))
            return
        }

        if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 1) {
            // Server public key
            let serverPublicKey = SecCertificateCopyKey(serverCertificate)
            let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey!, nil )!
            let data:Data = serverPublicKeyData as Data
            // Server Hash key
            let serverHashKey = sha256(data: data)
           
            // Success! This is our server
            if (serverHashKey == publickKeyLocal) {
                //Public key pinning is successfully
                completionHandler(.useCredential, URLCredential(trust:serverTrust))
            } else {
                //Public key pinning is failed
                sslErrorOccured = true
                completionHandler(.cancelAuthenticationChallenge, nil);
            }
        }
    }
}

//
//  KryptoHelper.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 12/10/23.
//

import Foundation

/**
 Used to read, update delete items from the Keychain.
 */
class KeychainHelper {
    ///Save or update token by token type.
    public class func store(_ tokenType: AuthTokenType, token: String) {
        if let _ = fetch(tokenType) {
            update(tokenType.rawValue, token: token)
        } else {
            add(tokenType.rawValue, token: token)
        }
    }
    
    ///Get token by token type.
    public class func fetch(_ tokenType: AuthTokenType) -> String? {
        fetchWithString(tokenType.rawValue)
    }
    
    ///Save or update token by String.

    public class func fetchWithString(_ tokenString: String) -> String? {
        let query:[String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                  kSecAttrAccount as String: tokenString,
                                  kSecReturnAttributes as String: true,
                                  kSecReturnData as String: true]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return nil }
        guard status == errSecSuccess else { return nil }
        guard let resultItem = item as? [String:Any], let tokenData = resultItem[kSecValueData as String] as? Data, let token = String(data: tokenData, encoding: .utf8) else {
            return nil
        }
        return token
    }
    
    ///Get token by String.
    public class func storeWithString(_ tokenType: String, token: String) {
        if let _ = fetchWithString(tokenType) {
            update(tokenType, token: token)
        } else {
            add(tokenType, token: token)
        }
    }

    
    ///Add token to keychain by token type
    public class func add(_ tokenType: String, token: String) {
        let tokenData = token.data(using: .utf8)!
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: tokenType,
                                    kSecValueData as String: tokenData,
                                    kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly]
        _ = SecItemAdd(query as CFDictionary, nil)
    }
    
    ///Update existing token by token type
    public class func update(_ tokenType: String, token: String) {
        let searchQuery: [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                         kSecAttrAccount as String: tokenType]
        let tokenData = token.data(using: .utf8)!
        let changeQuery: [String: Any] = [kSecValueData as String: tokenData, kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly]
        _ = SecItemUpdate(searchQuery as CFDictionary, changeQuery as CFDictionary)
    }
    
    ///Delete all token in the keychain.
    public class func deleteTokenKeychainItems() {
        let query: [String:Any] = [kSecClass as String: kSecClassGenericPassword]
        _ = SecItemDelete(query as CFDictionary)
    }
    
    public class func deleteKeyChainItem(_ tokenType: AuthTokenType) {
        let searchQuery: [String:Any] = [kSecClass as String: kSecClassGenericPassword,
                                         kSecAttrAccount as String: tokenType.rawValue,
                                         kSecReturnAttributes as String: true,
                                         kSecReturnData as String: true]
        _ = SecItemDelete(searchQuery as CFDictionary)
    }
}



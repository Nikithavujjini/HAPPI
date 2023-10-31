//
//  DictionaryExtensions.swift
//  Core Content
//
//  Created by Gopireddy Amarnath Reddy on 14/12/22.
//

import Foundation

extension Dictionary {
  func percentEncoded() -> Data? {
    return map { key, value in
      let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
        if let val = value as? [Any] {
            var escapedValue = ""
            for (i, v) in val.enumerated() {
                let escaped = "\(v)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
                escapedValue += escapedKey + "=" + escaped
                if i != val.count - 1 {
                    escapedValue += "&"
                }
            }
            return escapedValue
        } else {
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
    }
    .joined(separator: "&")
    .data(using: .utf8)
  }
}

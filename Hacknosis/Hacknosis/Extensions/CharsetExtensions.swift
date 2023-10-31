//
//  CharsetExtensions.swift
//  Core Content
//
//  Created by Gopireddy Amarnath Reddy on 14/12/22.
//

import Foundation

//https://sagar-r-kothari.github.io/swift/2020/02/20/Swift-Form-Data-Request.html

extension CharacterSet {
  static let urlQueryValueAllowed: CharacterSet = {
    let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
    let subDelimitersToEncode = "!$&'()*+,;="

    var allowed = CharacterSet.urlQueryAllowed
    allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
    return allowed
  }()
    
}

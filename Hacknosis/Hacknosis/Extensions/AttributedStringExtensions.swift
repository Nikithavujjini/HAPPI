//
//  AttributedStringExtensions.swift
//  Core Content
//
//  Created by Navpreet Gogana on 2021-08-12.
//

import Foundation

public extension NSMutableAttributedString {
    
    var range: NSRange {
        NSRange(location: 0, length: self.length)
    }
    
}

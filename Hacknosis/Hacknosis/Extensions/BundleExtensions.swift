//
//  BundleExtensions.swift
//  Core Content
//
//  Created by Jamie Klapwyk on 2021-07-16.
//

import Foundation

public extension Bundle {
    
    ///Application bundle id.
    var appBundleId: String {
        return (infoDictionary?["App Bundle Id"] as? String)!
    }
    
    ///This is the full year that was created at compile time. This is required for Copyright information.
    var yearWhenCompiled: String? {
        return (object(forInfoDictionaryKey: "Year When Compiled") as? String)
    }
    
    //Application current version
    var appVersion: String? {
        return(object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
    }
}

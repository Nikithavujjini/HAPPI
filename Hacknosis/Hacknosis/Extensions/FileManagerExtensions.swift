//
//  FileManagerExtensions.swift
//  Core Content
//
//  Created by Jamie Klapwyk on 2021-07-27.
//

import Foundation

extension FileManager {
    
    ///Returns the file url for the app group container.
    public class var appGroupContainer: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroup)
    }
}

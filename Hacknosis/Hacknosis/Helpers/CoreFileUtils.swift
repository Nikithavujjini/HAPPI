//
//  CoreFileUtils.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import Foundation

class CoreFileUtils: NSObject {

    static func documentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    static func userSubscriptionUniqueDirectory() -> URL {
        let userKey = EnvironmentManager.shared.userSubscriptionUniqueKey ?? "anonymous"
        createDirectoryIfNotExists(withName: userKey, in: documentsDirectory())
        return documentsDirectory().appendingPathComponent(userKey)
    }
    
    @discardableResult
    static func createDirectoryIfNotExists(withName name:String, in directory:URL) -> (Bool, Error?)  {
        let directoryUrl = UserHelper.isCurrentUserADoctor() ? directory.appendingPathComponent("\(name)-redacted") : directory.appendingPathComponent(name)
        if FileManager.default.fileExists(atPath: directoryUrl.path) {
            return (true, nil)
        }
        do {
            try FileManager.default.createDirectory(at: directoryUrl, withIntermediateDirectories: true, attributes: nil)
            return (true, nil)
        } catch  {
            return (false, error)
        }
    }
    
    @discardableResult
    static func createDirectoriesIfNeeded( path:String ) -> Bool {
        if !checkIfFileExists(path: path) {
            do {
                try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
                return true
            } catch {
                return false
            }
        }
        return true
    }
    
    static func checkIfFileExists(path:String) -> Bool {
        return FileManager.default.fileExists(atPath:path)
    }
    
    static func getFileStoragePathURL(nodeId:String, fileName:String) -> URL {
        var userDirectory = userSubscriptionUniqueDirectory()
        createDirectoryIfNotExists(withName: nodeId, in: userDirectory)
        userDirectory = userDirectory.appendingPathComponent(nodeId)
        return UserHelper.isCurrentUserADoctor() ? userDirectory.appendingPathComponent("\(fileName)-redacted") : userDirectory.appendingPathComponent(fileName)
    }
    
//    static func getFilePathToStoreInRealm(nodeId:String, fileName:String) -> String {
//        let userKey = OfflineFilesManager.shared.userSubscriptionUniqueKey ?? "anonymous"
//        return userKey + "/" + nodeId + "/" + fileName
//    }
    
    static func removeFile(at url:URL?) {
        if let url = url, FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(atPath: url.path)
        }
    }
    
    static func removeFolder(name folderName:String) {
        let url = userSubscriptionUniqueDirectory().appendingPathComponent(folderName)
        if FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.removeItem(atPath: url.path)
        }
    }
    
    static func getMultipartTempDirectory() -> URL {
        return CoreFileUtils.getTempDirectory().appendingPathComponent(MULTIPART_TEMP_FOLDER)
    }
    
    static func getCacheDirectory() -> String {
        return NSSearchPathForDirectoriesInDomains( .cachesDirectory, .userDomainMask, true )[0]
    }
        
    static func getTempDirectory() -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(AppBundleIdentifier)
    }
    
    //Clear all files in the Temp directory
    static func clearTempDirectory() {
        CoreFileUtils.removeFile(at: CoreFileUtils.getTempDirectory())
    }
    
    //MARK: - Clear directories
    
   
    
    
    static func clearLocalTempFiles() {
      //  CoreFileUtils.clearCacheDirectory()
        CoreFileUtils.clearTempDirectory()
    }

}

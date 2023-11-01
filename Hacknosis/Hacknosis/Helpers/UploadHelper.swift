//
//  UploadHelper.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import Foundation
class UploadHelper {
    static var uploadTypeList: [UploadType] = [.photosAndVideos]
}

extension UploadHelper {
    static var versionUploadCameraTypeList: [UploadType] = [.versionCamera, .gallery, .versionFile]
    static var versionUploadFileTypeList: [UploadType] = [.versionFile]
}

enum UploadType {
    case none, photosAndVideos, files, camera, versionFile, versionCamera, gallery
    
}

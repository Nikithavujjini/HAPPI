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
    
//    var value: String {
//        switch self {
//        case .photosAndVideos:
//            return PHOTOS_TEXT
//        case .versionCamera:
//            return CAPTURE_TEXT
//        case .files:
//            return FILES_TEXT
//        case .gallery:
//            return GALLERY_PHOTO_TEXT
//        default:
//            return EMPTY_STRING
//        }
//    }
}

//
//  PhotoPicker.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import SwiftUI
import PhotosUI

enum MediaSelectionType{
    case image
    case video
    case live
    case media
}

struct PhotoPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    
    @Environment(\.presentationMode) var presentationMode

    var mediaType:MediaSelectionType = .image
    var limit = 0
    var didFinishPicking: (_ didSelectItems: [PHPickerResult]) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        switch mediaType {
        case .image:
            config.filter = .any(of: [.images])
        case .video:
            config.filter = .any(of: [.videos])
        case .live:
            config.filter = .any(of: [.livePhotos])
        case .media:
            config.filter = .any(of: [.images, .videos, .livePhotos])
        }
        config.selectionLimit = limit
        config.preferredAssetRepresentationMode = .current
        
        let controller = PHPickerViewController(configuration: config)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    
    func makeCoordinator() -> Coordinator {
        Coordinator(with: self)
    }
    
    
    class Coordinator: PHPickerViewControllerDelegate {
        var photoPicker: PhotoPicker
        init(with photoPicker: PhotoPicker) {
            self.photoPicker = photoPicker
        }
        
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            self.photoPicker.didFinishPicking(results)
            self.photoPicker.presentationMode.wrappedValue.dismiss()
        }
    }

}


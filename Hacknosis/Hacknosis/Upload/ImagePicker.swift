//
//  ImagePicker.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import SwiftUI
import UIKit
import MobileCoreServices
import UniformTypeIdentifiers
import Photos

struct ImagePicker: UIViewControllerRepresentable {
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    @ObservedObject var mediaItems: PickedMediaItems
    var didFinishPicking: (_ didSelectItems: Bool) -> Void

    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        #if targetEnvironment(simulator)
        imagePicker.sourceType = .photoLibrary
        #else
        imagePicker.sourceType = sourceType
        #endif
        imagePicker.mediaTypes = [UTType.movie.identifier, UTType.image.identifier]

        imagePicker.delegate = context.coordinator
        
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.didFinishPicking(false)
            self.parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Using the full key
            if let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL,let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
                guard let targetURL = documentsDirectory?.appendingPathComponent(imageUrl.lastPathComponent) else { return }
                
                do {
                    if FileManager.default.fileExists(atPath: targetURL.path) {
                        try FileManager.default.removeItem(at: targetURL)
                    }
                    
                    try FileManager.default.copyItem(at: imageUrl, to: targetURL)
                    self.parent.mediaItems.items = [PhotoPickerModel]()
                    DispatchQueue.main.async {
                        self.parent.mediaItems.append(item: PhotoPickerModel(with: targetURL, name:targetURL.absoluteString.removingPercentEncoding?.components(separatedBy: "/").last ?? "", media: .photo, image: image))
                        self.parent.didFinishPicking(true)
                        self.parent.presentationMode.wrappedValue.dismiss()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
//            else if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
//                let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
//                let videoName = String.localizedStringWithFormat(UPLOAD_VIDEO_NAME, (DateHelper.ISO8601MediaDateFormatter.string(from: Date())))
//                guard let targetURL = documentsDirectory?.appendingPathComponent(videoName) else { return }
//
//                do {
//                    if FileManager.default.fileExists(atPath: targetURL.path) {
//                        try FileManager.default.removeItem(at: targetURL)
//                    }
//
//                    try FileManager.default.copyItem(at: videoUrl, to: targetURL)
//                    self.parent.mediaItems.items = [PhotoPickerModel]()
//
//                    DispatchQueue.main.async {
//                        self.parent.mediaItems.append(item: PhotoPickerModel(with: targetURL, name:targetURL.absoluteString.removingPercentEncoding?.components(separatedBy: "/").last ?? "", media: .video))
//                        self.parent.didFinishPicking(true)
//                        self.parent.presentationMode.wrappedValue.dismiss()
//                    }
//                } catch {
//                    print(error.localizedDescription)
//                }
//            }
            else if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
                let imageName = "img"
                guard let targetURL = documentsDirectory?.appendingPathComponent(imageName) else { return }
                
                do {
                    if FileManager.default.fileExists(atPath: targetURL.path) {
                        try FileManager.default.removeItem(at: targetURL)
                    }
                    
                    if let data = pickedImage.jpegData(compressionQuality: 0.5) {
                           let filename = targetURL
                           try? data.write(to: filename)
                    }
                    
                    self.parent.mediaItems.items = [PhotoPickerModel]()

                    DispatchQueue.main.async {
                        self.parent.mediaItems.append(item: PhotoPickerModel(with: targetURL, name:targetURL.absoluteString.removingPercentEncoding?.components(separatedBy: "/").last ?? "", media: .photo, image: pickedImage))
                        self.parent.didFinishPicking(true)
                        self.parent.presentationMode.wrappedValue.dismiss()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}




enum SelectedFileMediaType {
    case photo, video, livePhoto, document, scan, none
}

protocol SelectedFileData {
    var name:String { get }
    var url:URL? { get }
    var mediaType: SelectedFileMediaType { get }
}

struct PhotoPickerModel: SelectedFileData {
    var id: String
    var photo: UIImage?
    var url: URL?
    var livePhoto: PHLivePhoto?
    var mediaType: SelectedFileMediaType = .photo
    var name: String
    var fileAttributes:UploadFileAttributesModel?
    var image: UIImage?

    init(with mediaUrl: URL, name: String, media: SelectedFileMediaType, image: UIImage?) {
        id = UUID().uuidString
        url = mediaUrl
        mediaType = media
        self.name = name
        self.image = image
    }
    
    mutating func updateFileAttributes(_ fileAttributes:UploadFileAttributesModel) {
        self.fileAttributes = fileAttributes
    }
    
}


class PickedMediaItems: ObservableObject {
    @Published var items = [PhotoPickerModel]()
    
    func append(item: PhotoPickerModel) {
        items.append(item)
    }
    

}

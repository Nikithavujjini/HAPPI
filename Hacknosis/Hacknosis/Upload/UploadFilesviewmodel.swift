//
//  UploadFilesviewmodel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import Foundation
import SwiftUI
import AVFoundation
import PhotosUI

class UploadFilesViewModel:AbstractViewModel, ObservableObject  {
    
    var node:NodeModel? = nil
    
    @ObservedObject var selectedMediaItems = PickedMediaItems()

    @Published var isShowingPhotoPicker = false
    @Published var isShowingCamera = false
    @Published var isShowingDocumentPicker = false
    @Published var isShowingCameraErrorAlert:Bool = false
    @Published var showUploadAlert:Bool = false
    @Published var documentTypesFetched:Bool = false
    @Published var isShowingDuplicateFilesView = false
    @Published var shouldShowDuplicateAlert:Bool = false
    var mediaItems: PickedMediaItems = PickedMediaItems()
    var galleryItems = [PHPickerResult]()
    var duplicateFileNames:[String] = [String]()
    var count = 0
    var nodeService = FilesService()
    var onSelection:((PickedMediaItems, [String])->Void)?
    
    
    func onViewAppear(node:NodeModel?, onSelection:((PickedMediaItems, [String])->Void)?) {
        if let node = node {
            self.node = node
            nodeService = FilesService()
            self.onSelection = onSelection
        }
    }
    
    func showMediaPicker() {
       // NavigationImageManager.setNavigationBarColorToBlue()
        self.isShowingSheet = true
        self.isShowingPhotoPicker = true
    }
    
    func closeMediaPicker() {
       // NavigationImageManager.setNavigationBarColorToWhite()
        self.isShowingPhotoPicker = false
    }
    
    func photoPickerDidSelectPhotos(results: [PHPickerResult]) {
        self.selectedMediaItems = PickedMediaItems()
        self.mediaItems.items = [PhotoPickerModel]()
        count = 0
        isLoading = true
        for result in results {
            let itemProvider = result.itemProvider
            self.getMediaUrl(from: itemProvider, resultsCount: results.count)
        }
    }
    
    func photoPickerDidPickPhotos() {
        DispatchQueue.main.async {
         self.isLoading = true
        }
        self.duplicateFileNames.removeAll()
         if let nodeId = node?.fileId {
             self.onSelection?(self.selectedMediaItems, duplicateFileNames)
        }
    }
    
  
    
    
       
    
    

    
    func getNamesOfAllSelectedFiles() -> [String] {
        var names = [String]()
        for item in selectedMediaItems.items {
            if let nameString = item.url?.lastPathComponent, nameString.count > 0 {
                names.append(nameString)
            }
        }
        return names
    }
    
    func captureAlert() {
        showUploadAlert = true
    }
    
    func showCamera() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if authorizationStatus == .notDetermined {
            checkForCameraPermission()
        } else if authorizationStatus == .denied || authorizationStatus == .restricted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.isShowingCameraErrorAlert = true
            }
        } else {
            UIBarButtonItem.appearance().tintColor = .systemBlue
            UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(named:COLOR_NAVIGATION_BAR_TITLE)!

            DispatchQueue.main.async {
                self.isShowingSheet = false
                self.isShowingCamera = true
            }
        }
    }
    
    func checkForCameraPermission() {
        let _ = AVCaptureDevice.requestAccess(for: .video) { isSuccess in
            if isSuccess == false {
                DispatchQueue.main.async {
                    self.isShowingCamera = false
                    self.isShowingSheet = false
                    self.onSelection?(PickedMediaItems(), [])
                }
            } else {
                DispatchQueue.main.async {
                    self.isShowingSheet = false
                    self.isShowingCamera = true
                }
            }
        }
    }
    
    func closeCamera() {
        UIBarButtonItem.appearance().tintColor = UIColor(named:COLOR_NAVIGATION_BAR_TITLE)!
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(named:COLOR_NAVIGATION_BAR_TITLE)!
        
        self.isShowingCamera = false
    }
    
    func showVersionPicker() {
        UIBarButtonItem.appearance().tintColor = .systemBlue
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(named:COLOR_NAVIGATION_BAR_TITLE)!
        self.isShowingSheet = false
        self.isShowingCamera = true
    }

    func showDocumentPicker() {
        UIBarButtonItem.appearance().tintColor = .systemBlue
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(named:COLOR_NAVIGATION_BAR_TITLE)!
        self.isShowingSheet = true
        self.isShowingDocumentPicker = true
    }
    
    func closeDocumentPicker() {
        UIBarButtonItem.appearance().tintColor = UIColor(named:COLOR_NAVIGATION_BAR_TITLE)!
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(named:COLOR_NAVIGATION_BAR_TITLE)!
        
        self.isShowingDocumentPicker = false
    }

    
    
    private func getMediaUrl(from itemProvider: NSItemProvider, resultsCount: Int) {
        guard let typeIdentifier = itemProvider.registeredTypeIdentifiers.first,
              let utType = UTType(typeIdentifier) else{
                  return
              }
        
        itemProvider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in

            if let error = error {
                print(error.localizedDescription)
                self.updateCount(resultsCount: resultsCount)
            }
            
            guard let url = url else { return }
            
            let documentsDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            guard let targetURL = documentsDirectory?.appendingPathComponent(url.lastPathComponent) else { return }
            
            do {
                if FileManager.default.fileExists(atPath: targetURL.path) {
                    try FileManager.default.removeItem(at: targetURL)
                }
                
                try FileManager.default.copyItem(at: url, to: targetURL)
                
                DispatchQueue.main.async {
                    if utType.conforms(to: .image) || utType.conforms(to: .movie) {
                        self.mediaItems.append(item: PhotoPickerModel(with: targetURL, name: targetURL.absoluteString.removingPercentEncoding?.components(separatedBy: "/").last ?? "", media: .document, image: nil))
                    } else {
                        var mediaUrl = targetURL
                        if mediaUrl.lastPathComponent.hasSuffix(".pvt") {
                            let lastComponent = mediaUrl.lastPathComponent.replacingOccurrences(of: "pvt", with: "HEIC")
                            mediaUrl = targetURL.appendingPathComponent(lastComponent)
                            self.mediaItems.append(item: PhotoPickerModel(with: mediaUrl, name: lastComponent , media: .document,image: nil))
                        } else {
                            self.mediaItems.append(item: PhotoPickerModel(with: mediaUrl, name: targetURL.absoluteString.removingPercentEncoding?.components(separatedBy: "/").last ?? "", media: .document,image: nil))
                        }
                    }
                    self.updateCount(resultsCount: resultsCount)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateCount(resultsCount: Int) {
        self.count = self.count + 1
        if self.count == resultsCount {
            self.selectedMediaItems = mediaItems
            self.photoPickerDidPickPhotos()
            galleryItems.removeAll()
        }
    }
}


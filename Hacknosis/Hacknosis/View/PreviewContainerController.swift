//
//  PreviewContainerController.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import Foundation
import UIKit
import SwiftUI
import QuickLook

class PreviewContainerController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate, UIGestureRecognizerDelegate {
    
    var nodeName:String = ""
    var nodeId:String = ""
    var url:URL
    var mimeType: String?
    var isReadOnly = false
    var corePreviewController:CorePreviewController? = nil
    init(with nodeName:String, nodeId:String, url:URL, mimeType: String? = nil, isReadOnly: Bool) {
        self.nodeId = nodeId
        self.nodeName = nodeName
        self.url = url
        self.isReadOnly = isReadOnly
        if url.pathExtension.isEmpty, let mimeType, let type = MimeTypes.filenameExtension(forType: mimeType) {
            self.url = url.appendingPathExtension(type)
        } else if let mimeType {
            let types = MimeTypes.filenameExtensions(forType: mimeType)
            if types.contains(url.pathExtension) {
                print("matching")
            } else if let type = types.first {
                self.url = url.appendingPathExtension(type)
            }
        }
        super.init(nibName: nil, bundle: nil)
        self.store(self.url , currentPath: url)
    }
    
    private func store(_ destination:URL, currentPath:URL) {
        if FileManager.default.fileExists(atPath: destination.path) == false {
            do {
                try FileManager.default.copyItem(atPath:currentPath.path , toPath: destination.path)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = nodeName
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        corePreviewController = CorePreviewController()
        corePreviewController?.url = url
        corePreviewController?.dataSource = self
        corePreviewController?.delegate = self
       // corePreviewController?.addDefaultTint()
        corePreviewController?.isReadOnly = isReadOnly
        //to hide the save to files and share options available in navigation controller when file has only read permission
        if isReadOnly {
            if let vc = corePreviewController {
                self.view.addSubview(vc.view)
                vc.view.translatesAutoresizingMaskIntoConstraints = false
                //to fit to the uidevice view using contraints provided
                vc.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
                vc.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
                vc.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
                vc.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
                //gesture recogniser to hide navigation bar on tap of the preview
                let singleTapGesture = UITapGestureRecognizer(
                    target: self, action: #selector(didSingleTap(_:)))
                singleTapGesture.delegate = self
                vc.view.addGestureRecognizer(singleTapGesture)
            }
        } else {
            if animated == false {
                self.navigationController?.pushViewController(corePreviewController!, animated: false)
            } else {
                self.navigationController?.popViewController(animated: false)
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //self.corePreviewController?.addWhiteTint()
    }
    
    //makes UIview  recognise the tap gesture
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }


//MARK: QLPreviewControllerDataSource  methods
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return FilePreviewItem(url: url, title: nodeName)
    }
    
    // in iOS 15, by default editing mode is enabled for a document
    // disabled editing mode for now as it has to sync with server if it is edited
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        .disabled
    }
    
    @objc
    func didSingleTap(_ recognizer: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.25, animations: {
            //hides and unhides navigation bar when users taps on the view
            self.navigationController?.hidesBarsOnTap = true
        })
    }
    
}

class FilePreviewItem: NSObject, QLPreviewItem {
     var previewItemURL: URL?
     var previewItemTitle: String?
     
     init(url: URL?, title: String?) {
         previewItemURL = url
         previewItemTitle = title
     }
}

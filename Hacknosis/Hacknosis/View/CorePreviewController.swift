//
//  CorePreviewController.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//
import UIKit
import QuickLook
import SwiftUI

class CorePreviewController: QLPreviewController {
    var navBarObserver:NSKeyValueObservation?
    var url:URL?
    var isReadOnly = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // override back button.
        let imageConfig = UIImage.SymbolConfiguration(weight: .semibold)
        var backImage = UIImage(systemName: "chevron-down", withConfiguration: imageConfig)
        var colorName = Color.blue
        let backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonPressed))

    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //addWhiteTint()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       // addDefaultTint()

        if let url = url, QLPreviewController.canPreview(url as QLPreviewItem) == false {
            if let sel = self.navigationController?.navigationBar.items?.last?.rightBarButtonItem?.action {
                Thread.detachNewThreadSelector(sel, toTarget: self as Any, with: nil)
            }
        }
    }

    //listen to this from filesviewmodel
    
    @objc func backButtonPressed() {
        NotificationCenter.default.post(name: .popFromViewer, object: nil)
    }
}

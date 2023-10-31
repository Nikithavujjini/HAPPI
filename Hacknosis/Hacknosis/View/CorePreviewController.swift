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
    
//    deinit{
//        UserStateManager.shared.isViewerScreenPresented = false
//        NotificationCenter.default.post(name: .showHideNetworkOverlay, object: nil)
//    }
//
//    func addDefaultTint() {
//        var colorName = COLOR_NAVIGATION_BAR_TITLE
//        if !NetworkReachability.shared.isConnected && UserStateManager.shared.isOfflineModeEnabled {
//            colorName = COLOR_TEXT_DEFAULT
//        }
//        UIBarButtonItem.appearance().tintColor = .systemBlue
//        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(named:colorName)!
//    }
//
//    func addWhiteTint() {
//        var colorName = COLOR_NAVIGATION_BAR_TITLE
//        if !NetworkReachability.shared.isConnected  && UserStateManager.shared.isOfflineModeEnabled {
//            colorName = COLOR_TEXT_DEFAULT
//        }
//
//        UIBarButtonItem.appearance().tintColor = UIColor(named:colorName)!
//        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(named:colorName)!
//    }
//
    //listen to this from filesviewmodel
    
    @objc func backButtonPressed() {
        NotificationCenter.default.post(name: .popFromViewer, object: nil)
    }
}

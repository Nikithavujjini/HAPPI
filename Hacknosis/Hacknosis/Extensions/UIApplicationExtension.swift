//
//  UIApplicationExtension.swift
//  Core Content
//
//  Created by Gopireddy Amarnath Reddy  on 07/12/21.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing(_ force: Bool) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }
}

extension UIApplication {
    func addInteractionRecognizer() {
        // Notification observer to track text changes from keyboard
        guard let window = windows.first else { return }
        
        // Gestures recognizers to track
        let gestureRecognizers = [
            UITapGestureRecognizer(target: self, action: #selector(didInteractWithApp)),
            UIPanGestureRecognizer(target: self, action: #selector(didInteractWithApp))
        ]
        
        gestureRecognizers.forEach {
            $0.requiresExclusiveTouchType = false
            $0.cancelsTouchesInView = false
            $0.delegate = self
            window.addGestureRecognizer($0)
        }
    }
    
    @objc func didInteractWithApp(_ sender: UIGestureRecognizer) {
        let allowedStates: [UIGestureRecognizer.State] = [.began]
        if sender as? UIPanGestureRecognizer != nil, !allowedStates.contains(sender.state) {
            return
        }
        NotificationCenter.default.post(name: .interactedWithApp, object: nil)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Set to true to recognize gestures specified above while allowing user interact with other gestures in the app and not to block them with them
        return true
    }
}

extension UIApplication {
      // 1. Function that we can call via `UIApplication.setStatusBarStyle(...)`
    class func setStatusBarStyle(_ style: UIStatusBarStyle) {
          // Get the root view controller, which we've set to be `ContentHostingController`
        if let vc = UIApplication.getKeyWindow()?.rootViewController as? ContentHostingController {
                 // Call the method we've defined
            vc.changeStatusBarStyle(style)
        }
    }
      // 2. Helper function to get the key window
    class func getKeyWindow() -> UIWindow? {
        return UIApplication.shared.windows.first{ $0.isKeyWindow }
    }
}

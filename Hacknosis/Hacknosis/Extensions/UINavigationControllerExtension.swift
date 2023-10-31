//
//  UINavigationControllerExtension.swift
//  Core Content
//
//  Created by Jamie Klapwyk on 2021-08-13.
//

import UIKit

extension UINavigationController {
    // Remove back button text
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backButtonDisplayMode = .minimal
        if UIAccessibility.isVoiceOverRunning {
            navigationBar.topItem?.backButtonTitle = NAVIGATION_BACK_BUTTON_TITLE
        }
    }
}

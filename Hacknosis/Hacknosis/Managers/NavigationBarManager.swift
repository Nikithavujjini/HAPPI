//
//  NavigationBarManager.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 30/10/23.
//

import Foundation
import UIKit

class NavigationImageManager {
    //MARK: - Variables
    static let shared = NavigationImageManager()
    var navBarBackgroungImage:UIImage? = nil
    var offlineNavBarBackgroungImage:UIImage? = nil
    var toolbarBackgroungImage:UIImage? = nil
    var offlineToolbarBackgroungImage:UIImage? = nil

    //MARK: - Initialization
    fileprivate init() {}

    func navBarBackgroungImage(withColors colors: [Any], frame:CGRect) -> UIImage? {
        if navBarBackgroungImage == nil {
            navBarBackgroungImage = gradientImage(withColors: colors, frame: frame)
        }
        return navBarBackgroungImage
    }
    
    func offlineNavBarBackgroungImage(withColors colors: [Any], frame:CGRect) -> UIImage? {
        if offlineNavBarBackgroungImage == nil {
            offlineNavBarBackgroungImage = gradientImage(withColors: colors, frame: frame)
        }
        return offlineNavBarBackgroungImage
    }
    
    func toolbarBackgroungImage(withColors colors: [Any], frame:CGRect) -> UIImage? {
        if toolbarBackgroungImage == nil {
            toolbarBackgroungImage = gradientImage(withColors: colors, frame: frame)
        }
        return toolbarBackgroungImage
    }
    
    func offlineToolbarBackgroungImage(withColors colors: [Any], frame:CGRect) -> UIImage? {
        if offlineToolbarBackgroungImage == nil {
            offlineToolbarBackgroungImage = gradientImage(withColors: colors, frame: frame)
        }
        return offlineToolbarBackgroungImage
    }
    
    private func gradientImage(withColors colors: [Any], frame:CGRect) -> UIImage? {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.frame = frame
        gradient.colors = colors;
        
        UIGraphicsBeginImageContext(gradient.frame.size)
        gradient.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return outputImage
    }
    
    static func setNavigationBarColorToBlue() {
        UIBarButtonItem.appearance().tintColor = .systemBlue
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(named:COLOR_NAVIGATION_BAR_TITLE)!
        UINavigationBar.appearance().tintColor = UIColor(named: ACCENT_COLOR)
    }
    
    static func setNavigationBarColorToWhite() {
        UIBarButtonItem.appearance().tintColor = UIColor(named:COLOR_NAVIGATION_BAR_TITLE)!
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(named:COLOR_NAVIGATION_BAR_TITLE)!
        var colorName = COLOR_NAVIGATION_BAR_TITLE
        if !NetworkReachability.shared.isConnected {
            colorName = COLOR_TEXT_DEFAULT
        }
        UINavigationBar.appearance().tintColor = UIColor(named: colorName)
    }
}


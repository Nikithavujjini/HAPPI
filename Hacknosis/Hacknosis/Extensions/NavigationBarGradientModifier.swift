//
//  NavigationBarGradientModifier.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 23/10/23.
//

import SwiftUI

struct NavigationGradientBarModifier:ViewModifier {
    
    init(shouldRefresh:Bool) {
        if shouldRefresh == false {
            return
        }
        //Set background color of the navigation bar to clear and text to white
       let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = .clear
        var colorName = COLOR_NAVIGATION_BAR_DARK
        if !NetworkReachability.shared.isConnected {
            colorName = COLOR_NAVIGATION_BAR_DARK
        }
        
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor(named:colorName)!, NSAttributedString.Key.font: UIFont.interRegular(size: 17, relativeTo: .title1)]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named:colorName)!]
        let imageConfig = UIImage.SymbolConfiguration(weight: .semibold)
        let backImage = UIImage(systemName: SYSTEM_IMAGE_ARROW_BACKWARD, withConfiguration: imageConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(UIColor(named:colorName)!).withAlignmentRectInsets(UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8))
        coloredAppearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        coloredAppearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named:colorName)!, NSAttributedString.Key.font: UIFont.interSemiBold(size: 17, relativeTo: .title1)]
        coloredAppearance.doneButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named:colorName)!, NSAttributedString.Key.font: UIFont.interRegular(size: 17, relativeTo: .title1)]
        coloredAppearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named:colorName)!, NSAttributedString.Key.font: UIFont.interRegular(size: 17, relativeTo: .title1)]

        //Add Gradient color image to NavigationBar to support UIKit
        let height = (UIApplication.shared.windows.last?.safeAreaInsets.top ?? 0) + 44
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height)
        var navBarImage:UIImage? = nil
        if NetworkReachability.shared.isConnected {
            navBarImage = NavigationImageManager.shared.navBarBackgroungImage(withColors: [UIColor(named: COLOR_NAVIGATION_BAR_GRADIENT_BOTTOM)!.cgColor, UIColor(named: COLOR_NAVIGATION_BAR_GRADIENT_BOTTOM)!.cgColor], frame: frame)
        }
       
        

        coloredAppearance.backgroundImage = navBarImage
        
        //Assign to the various appearances
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().compactScrollEdgeAppearance = coloredAppearance
        }

        UINavigationBar.appearance().tintColor = UIColor(named:colorName)
        
        
        //Set Gradient color and text colors to bottom Toolbar
        let toolbarHeight = (UIApplication.shared.windows.last?.safeAreaInsets.top ?? 0) + 44
        var toolBarFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: toolbarHeight)
        toolBarFrame.size.height += UIApplication.shared.windows.last?.safeAreaInsets.bottom ?? 0
        var toolBarGradientImage:UIImage? = nil
        if NetworkReachability.shared.isConnected {
            toolBarGradientImage = NavigationImageManager.shared.toolbarBackgroungImage(withColors: [UIColor(named: COLOR_NAVIGATION_BAR_GRADIENT_BOTTOM)!.cgColor, UIColor(named: COLOR_NAVIGATION_BAR_GRADIENT_BOTTOM)!.cgColor], frame: toolBarFrame)
        }
        
        let toolBarAppearance = UIToolbarAppearance()
        toolBarAppearance.configureWithTransparentBackground()
        toolBarAppearance.backgroundColor = .clear
        toolBarAppearance.backgroundImage = toolBarGradientImage
        toolBarAppearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named:colorName)!, NSAttributedString.Key.font: UIFont.interRegular(size: 17, relativeTo: .title1)]
        toolBarAppearance.doneButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(named:colorName)!, NSAttributedString.Key.font: UIFont.interRegular(size: 17, relativeTo: .title1)]

        let toolbar = UIToolbar.appearance()
        toolbar.standardAppearance = toolBarAppearance
        toolbar.compactAppearance = toolBarAppearance
        if #available(iOS 15.0, *) {
            toolbar.compactScrollEdgeAppearance = toolBarAppearance
        }

        UIBarButtonItem.appearance().tintColor = UIColor(named:colorName)!
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(named:colorName)!
    }
    
    func body(content: Content) -> some View {
        ZStack{
            content
            //Apply gradient background
            VStack {
                GeometryReader { geometry in
                    LinearGradient(gradient: Gradient(colors: NetworkReachability.shared.isConnected ? [Color.blue, Color(COLOR_NAVIGATION_BAR_GRADIENT_BOTTOM)] : [Color(COLOR_NAVIGATION_BAR_OFFLINE), Color(COLOR_NAVIGATION_BAR_OFFLINE)]), startPoint: .bottom, endPoint: .top)
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                        .edgesIgnoringSafeArea(.leading)
                        .edgesIgnoringSafeArea(.trailing)
                    Spacer()
                }
            }
        }
    }
    
    static func setNavigationBarColorToBlue() {
        UIBarButtonItem.appearance().tintColor = .systemBlue
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UIToolbar.self]).tintColor = UIColor(named:COLOR_NAVIGATION_BAR_TITLE)!
        UINavigationBar.appearance().tintColor = UIColor(named: ACCENT_COLOR)
    }
    
}

extension View {
    func navigationGradientBarColor(shouldRefresh:Bool = true) -> some View {
        self.modifier(NavigationGradientBarModifier(shouldRefresh: shouldRefresh))
    }
}

extension UINavigationController {
    // Remove back button text
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backButtonDisplayMode = .minimal
        if UIAccessibility.isVoiceOverRunning {
            navigationBar.topItem?.backButtonTitle = "back"
        }
    }
}

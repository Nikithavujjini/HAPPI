

import UIKit

extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    class func sceneOrientation() -> UIDeviceOrientation {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let sceneDelegate = scene as? UIWindowScene else { return .portrait }
        
        let orientation =  sceneDelegate.interfaceOrientation
        switch orientation {
            case .portrait: return .portrait
            case .portraitUpsideDown: return .portraitUpsideDown
            case .landscapeLeft: return .landscapeLeft
            case .landscapeRight: return .landscapeRight
            default: return .unknown
        }
    }
    
    class func deviceLayout() -> LayoutStyle {
        
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .iPhoneFullScreen
        }

        let screenSize = UIScreen.main.bounds.size
        let appSize = applicationSize()
        let screenWidth = screenSize.width
        let appWidth = appSize.width

        if screenSize == appSize {
             return .iPadFullscreen
        }

        let persent = CGFloat(appWidth / screenWidth) * 100.0

        if persent <= 55.0 && persent >= 45.0 {
            return .iPadHalfScreen
        } else if persent > 55.0 {
            return .iPadTwoThirdScreeen
        } else {
            return .iPadOneThirdScreen
        }
    }
    
    class func applicationSize() -> CGSize {
        if UIApplication.shared.windows.isNotEmpty {
            return UIApplication.shared.windows[0].bounds.size
        }
        return .zero
    }
}


enum LayoutStyle: String {
    case iPadFullscreen = "iPad Full Screen"
    case iPadHalfScreen = "iPad 1/2 Screen"
    case iPadTwoThirdScreeen = "iPad 2/3 Screen"
    case iPadOneThirdScreen = "iPad 1/3 Screen"
    case iPhoneFullScreen = "iPhone"
}


public extension Bundle {
    
    ///Application bundle id.
    var appBundleId: String {
        return (infoDictionary?["App Bundle Id"] as? String)!
    }
}

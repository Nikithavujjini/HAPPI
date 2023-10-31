//
//  FontExtension.swift
//  Core Content
//
//  Created by Amarnath Gopireddy on 06/10/21.
//

import SwiftUI

extension Font {
    
    public static func interRegular(size: CGFloat, relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        if let textStyle = textStyle {
            return custom(INTER_REGULAR_FONT, size: size, relativeTo: textStyle)
        }
        return custom(INTER_REGULAR_FONT, size: size)
    }
    
    public static func interMedium(size: CGFloat, relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        if let textStyle = textStyle {
            return custom(INTER_MEDIUM_FONT, size: size, relativeTo: textStyle)
        }
        return custom(INTER_MEDIUM_FONT, size: size)
    }
    
    public static func interBold(size: CGFloat, relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        if let textStyle = textStyle {
            return custom(INTER_BOLD_FONT, size: size, relativeTo: textStyle)
        }
        return custom(INTER_BOLD_FONT, size: size)
    }
    
    public static func interSemiBold(size: CGFloat, relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        if let textStyle = textStyle {
            return custom(INTER_SEMIBOLD_FONT, size: size, relativeTo: textStyle)
        }
        return custom(INTER_SEMIBOLD_FONT, size: size)
    }
    
    public static func interExtraBold(size: CGFloat, relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        if let textStyle = textStyle {
            return custom(INTER_EXTRABOLD_FONT, size: size, relativeTo: textStyle)
        }
        return custom(INTER_EXTRABOLD_FONT, size: size)
    }
    
    public static func interBlack(size: CGFloat, relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        if let textStyle = textStyle {
            return custom(INTER_BLACK_FONT, size: size, relativeTo: textStyle)
        }
        return custom(INTER_BLACK_FONT, size: size)
    }
    
    public static func interLight(size: CGFloat, relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        if let textStyle = textStyle {
            return custom(INTER_LIGHT_FONT, size: size, relativeTo: textStyle)
        }
        return custom(INTER_LIGHT_FONT, size: size)
    }
    
    public static func interExtraLight(size: CGFloat, relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        if let textStyle = textStyle {
            return custom(INTER_EXTRALIGHT_FONT, size: size, relativeTo: textStyle)
        }
        return custom(INTER_EXTRALIGHT_FONT, size: size)
    }
    
    public static func interThin(size: CGFloat, relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        if let textStyle = textStyle {
            return custom(INTER_THIN_FONT, size: size, relativeTo: textStyle)
        }
        return custom(INTER_THIN_FONT, size: size)
    }
}

extension UIFont {
    public static func interRegular(size: CGFloat, relativeTo textStyle: UIFont.TextStyle? = nil) -> UIFont {
        let font = UIFont(name: INTER_REGULAR_FONT, size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
        if let textStyle = textStyle {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        }
        return font
    }
    
    public static func interMedium(size: CGFloat, relativeTo textStyle: UIFont.TextStyle? = nil) -> UIFont {
        let font = UIFont(name: INTER_MEDIUM_FONT, size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
        if let textStyle = textStyle {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        }
        return font
    }
    
    public static func interBold(size: CGFloat, relativeTo textStyle: UIFont.TextStyle? = nil) -> UIFont {
        let font = UIFont(name: INTER_BOLD_FONT, size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
        if let textStyle = textStyle {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        }
        return font
    }
    
    public static func interSemiBold(size: CGFloat, relativeTo textStyle: UIFont.TextStyle? = nil) -> UIFont {
        let font = UIFont(name: INTER_SEMIBOLD_FONT, size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
        if let textStyle = textStyle {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        }
        return font
    }
    
    public static func interExtraBold(size: CGFloat, relativeTo textStyle: UIFont.TextStyle? = nil) -> UIFont {
        let font = UIFont(name: INTER_EXTRABOLD_FONT, size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
        if let textStyle = textStyle {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        }
        return font
    }
    
    public static func interBlack(size: CGFloat, relativeTo textStyle: UIFont.TextStyle? = nil) -> UIFont {
        let font = UIFont(name: INTER_BLACK_FONT, size: size) ?? UIFont.systemFont(ofSize: size, weight: .black)
        if let textStyle = textStyle {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        }
        return font
    }
    
    public static func interLight(size: CGFloat, relativeTo textStyle: UIFont.TextStyle? = nil) -> UIFont {
        let font = UIFont(name: INTER_LIGHT_FONT, size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
        if let textStyle = textStyle {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        }
        return font
    }
    
    public static func interExtraLight(size: CGFloat, relativeTo textStyle: UIFont.TextStyle? = nil) -> UIFont {
        let font = UIFont(name: INTER_EXTRALIGHT_FONT, size: size) ?? UIFont.systemFont(ofSize: size, weight: .ultraLight)
        if let textStyle = textStyle {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        }
        return font

    }
    
    public static func interThin(size: CGFloat, relativeTo textStyle: UIFont.TextStyle? = nil) -> UIFont {
        let font = UIFont(name: INTER_THIN_FONT, size: size) ?? UIFont.systemFont(ofSize: size, weight: .thin)
        if let textStyle = textStyle {
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: font)
        }
        return font
    }
}

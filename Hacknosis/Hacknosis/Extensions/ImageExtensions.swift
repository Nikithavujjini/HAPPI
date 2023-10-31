//
//  ImageExtensions.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 20/10/23.
//

import Foundation
import UIKit

extension UIImage {
    
    var base64: String? {
        self.jpegData(compressionQuality: 1)?.base64EncodedString()
    }
}

extension String {
    var imageFromBase64: UIImage? {
        guard let imageData = Data(base64Encoded: self, options: .ignoreUnknownCharacters) else {
            return nil
        }
        return UIImage(data: imageData)
    }
}


//
//  Previewcontroller.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 18/10/23.
//

import SwiftUI
import QuickLook

struct PreviewController: UIViewControllerRepresentable {
    var nodeName:String = ""
    var nodeId:String = ""
    var documentLink:URL
    var mimeType:String?
    var isReadOnly: Bool = false
    let onDismiss:(()->Void)? = nil

    func makeUIViewController(context: Context) -> UIViewController {
        let vc = PreviewContainerController(with: nodeName, nodeId: nodeId, url: documentLink, mimeType: mimeType,isReadOnly: isReadOnly)
        return vc
    }

    func updateUIViewController(
        _ uiViewController: UIViewController, context: Context) {}

}

//
//  MailHelper.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 29/10/23.
//

import Foundation

import UIKit
import MessageUI
import SwiftUI

struct MailView: UIViewControllerRepresentable {
    @Binding var result: Bool
    @Binding var email: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["nvujjini@opentext.com"])
        vc.setSubject("HAPPI: Reports update")
        vc.setMessageBody("Your report have been reviwed.", isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView

        init(_ parent: MailView) {
            self.parent = parent
        }

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.result = false
            controller.dismiss(animated: true)
        }
    }
}


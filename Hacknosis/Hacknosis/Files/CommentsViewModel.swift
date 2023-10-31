//
//  CommentsViewModel.swift
//  Hacknosis
//
//  Created by Vujjini Nikitha on 25/10/23.
//



import Foundation
import Combine
import MessageUI

class CommentsViewModel:FilesViewModel {
   // var requests:Set<AnyCancellable> = Set<AnyCancellable>()
    @Published var isShowingMail: Bool = false
    func addComment(nodeId:String, comment:String, completion:@escaping(_ node:NodeModel?, _ error:CoreError?) -> Void)  {
        let request = FilesService().addComment(nodeId: nodeId, comment: comment) { node, error in
            if node != nil {
                self.updateReports(nodeId: nodeId)
            }
            NotificationCenter.default.post(name: .refreshUI, object: nil)
            if MFMailComposeViewController.canSendMail() {
                self.isShowingMail = true
            }
          completion(node, error)
        }
        if let request = request {
            self.requests.insert(request)
        }
    }
}


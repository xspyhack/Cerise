//
//  FeedbackController.swift
//  Cerise
//
//  Created by bl4ckra1sond3tre on 2019/3/2.
//  Copyright © 2019 blessingsoftware. All rights reserved.
//

import Foundation
import MessageUI

/// 反馈
class FeedbackContoller: NSObject, MFMessageComposeViewControllerDelegate {
    var completionHandler: (() -> Void)?

    static let shared = FeedbackContoller()

    func feedback(in presenting: UIViewController?, completionHandler: @escaping () -> Void) {
        self.completionHandler = completionHandler

        let vc = MFMessageComposeViewController()
        vc.recipients = ["alligator@zhihu.com"]
        vc.messageComposeDelegate = self
        presenting?.present(vc, animated: true, completion: nil)
    }

    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        completionHandler?()
    }
}

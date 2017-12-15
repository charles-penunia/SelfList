//
//  UIViewControllerExtensions.swift
//  SelfList
//
//  Created by Charles Penunia on 11/12/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func presentErrorAlert(_ title: String, withMessage message: String, andButtonTitle buttonTitle: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

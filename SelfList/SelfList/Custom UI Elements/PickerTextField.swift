//
//  PickerTextField.swift
//  SelfList
//
//  Created by Charles Penunia on 11/7/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import Foundation
import UIKit

class PickerTextField: UITextField {
    override func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    override func selectionRects(for range: UITextRange) -> [Any] {
        return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        UIMenuController.shared.isMenuVisible = false
        return false
    }
}

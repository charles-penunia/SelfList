//
//  ForcePressModalButton.swift
//  SelfList
//
//  Created by Charles Penunia on 11/4/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import Foundation
import UIKit

class ForcePressModalButton: UIButton {
    private var didForcePress = false
    var rootController: UIViewController?
    var pressSegueIdentifier: String?
    var forcePressSegueIdentifier: String?
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {return}
        if traitCollection.forceTouchCapability == .available {
            if touch.force/touch.maximumPossibleForce >= 0.5 && !didForcePress {
                didForcePress = true
                if let identifier = forcePressSegueIdentifier {
                    rootController?.performSegue(withIdentifier: identifier, sender: rootController)
                }
                didForcePress = false
                self.isHighlighted = false
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let identifier = pressSegueIdentifier {
            rootController?.performSegue(withIdentifier: identifier, sender: rootController)
        }
        didForcePress = false
        self.isHighlighted = false
    }
}

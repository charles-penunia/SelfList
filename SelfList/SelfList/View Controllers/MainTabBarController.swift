//
//  MainTabBarController.swift
//  SelfList
//
//  Created by Charles Penunia on 11/2/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit

let numberOfButtons = 5
let middleImage = UIImage(named: "icons8-add-filled-2")

class MainTabBarController: UITabBarController, AddTaskViewDelegate, AddRoleViewDelegate {

    let centerButton = ForcePressModalButton(type: UIButtonType.custom)
    let buttonHeight: CGFloat = 49.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = defaultTintColor
        
        // Set up custom button for the middle of the tab bar
        centerButton.setImage(middleImage, for: .normal)
        centerButton.addTarget(self, action: #selector(MainTabBarController.pressButton(_:)), for: UIControlEvents.touchUpInside)
        centerButton.rootController = self
        centerButton.pressSegueIdentifier = "AddTaskSegue"
        centerButton.forcePressSegueIdentifier = "AddRoleSegue"
        self.view.addSubview(centerButton)
    }
    
    override func viewDidLayoutSubviews() {
        let buttonWidth = self.tabBar.frame.width / CGFloat(numberOfButtons)
        let originX = buttonWidth * 2
        let originY = self.tabBar.frame.origin.y
        centerButton.frame = CGRect(x: originX, y: originY, width: buttonWidth, height: buttonHeight)
    }
    
    // MARK: - Interface Builder actions
    
    @IBAction func cancelAddTask(_ sender: UIStoryboardSegue) {
        
    }
    
    // MARK: - Objective-C actions
    
    @objc func pressButton(_ sender: UIButton) {
        self.performSegue(withIdentifier: "AddTaskSegue", sender: self)
    }
    
    // MARK: - AddTaskViewDelegate methods
    
    func addTaskViewWillExit(_ sender: AddTaskViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - AddRoleViewDelegate methods
    
    func addRoleViewWillExit(_ sender: AddRoleViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "AddTaskSegue":
            let navigationViewController = segue.destination as! UINavigationController
            let addTaskViewController = navigationViewController.viewControllers[0] as! AddTaskViewController
            addTaskViewController.delegate = self
        case "AddRoleSegue":
            let navigationViewController = segue.destination as! UINavigationController
            let addRoleViewController = navigationViewController.viewControllers[0] as! AddRoleViewController
            addRoleViewController.delegate = self
        default:
            break
        }
    }
    
}

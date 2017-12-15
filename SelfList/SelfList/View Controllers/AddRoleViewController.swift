//
//  AddRoleViewController.swift
//  SelfList
//
//  Created by Charles Penunia on 11/2/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit
import CoreData

@objc protocol AddRoleViewDelegate: class {
    @objc optional func addRoleViewWillExit(_ sender: AddRoleViewController)
    @objc optional func addRoleView(_ sender: AddRoleViewController, didAddRole role: RoleMO)
}

let textFieldBorderColor = UIColor(red: 238/255.0, green: 238/255.0, blue: 238/255.0, alpha: 1.0)

class AddRoleViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var roleTextField: UITextView!
    @IBOutlet weak var roleDescriptionTextView: UITextView!
    
    let dataManager = DataManager.sharedInstance
    let keyboardToolbar = UIToolbar()
    
    var delegate: AddRoleViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.tintColor = defaultTintColor
        
        // Do any additional setup after loading the view.
        roleTextField.delegate = self
        roleDescriptionTextView.delegate = self
        
        roleDescriptionTextView.layer.borderColor = textFieldBorderColor.cgColor
        roleDescriptionTextView.layer.borderWidth = 0.5
        roleDescriptionTextView.layer.cornerRadius = 6
        roleDescriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddRoleViewController.dismissKeyboard))
        keyboardToolbar.items = [flexSpace, doneButton]
        roleDescriptionTextView.inputAccessoryView = keyboardToolbar
        keyboardToolbar.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Interface Builder actions
    
    @IBAction func finshedEditingRoleName(_ sender: UITextField){
        self.view.endEditing(true)
    }
    
    @IBAction func addRole(_ sender: UIButton) {
        if roleTextField.text!.isEmpty {
            self.presentErrorAlert("Add Role Failed", withMessage: "Please fill out the role name.", andButtonTitle: "Dismiss")
            return
        }
        let newRole = NSEntityDescription.insertNewObject(forEntityName: "Role", into: dataManager.managedObjectContext) as! RoleMO
        newRole.name = roleTextField.text
        newRole.roleDescription = roleDescriptionTextView.text
        newRole.color = UIColor.generateBrightColor()
        dataManager.saveContext()
        delegate?.addRoleView?(self, didAddRole: newRole)
        delegate?.addRoleViewWillExit?(self)
    }
    
    @IBAction func willCancel(_ sender: UIBarButtonItem) {
        delegate?.addRoleViewWillExit?(self)
    }
    
    // MARK: - Objective-C actions
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

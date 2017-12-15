//
//  EditRoleViewController.swift
//  SelfList
//
//  Created by Charles Penunia on 12/8/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit
import UserNotifications

protocol EditRoleViewDelegate {
    func editRoleView(_ sender: EditRoleViewController, willDeleteRole role: RoleMO)
}

class EditRoleViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    let dataManager = DataManager.sharedInstance
    let keyboardToolbar = UIToolbar()
    
    let center = UNUserNotificationCenter.current()
    
    var selectedRole: RoleMO?
    var delegate: EditRoleViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.tintColor = defaultTintColor
        
        // Do any additional setup after loading the view.
        nameTextField.delegate = self
        nameTextField.text = selectedRole?.name
        descriptionTextView.delegate = self
        descriptionTextView.text = selectedRole?.roleDescription
        
        descriptionTextView.layer.borderColor = textFieldBorderColor.cgColor
        descriptionTextView.layer.borderWidth = 0.5
        descriptionTextView.layer.cornerRadius = 6
        descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(EditRoleViewController.dismissKeyboard))
        keyboardToolbar.items = [flexSpace, doneButton]
        descriptionTextView.inputAccessoryView = keyboardToolbar
        keyboardToolbar.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configure(selectedRole role: RoleMO) {
        selectedRole = role
    }
    
    // MARK: - Interface Builder actions
    
    @IBAction func finshedEditingRoleName(_ sender: UITextField){
        self.view.endEditing(true)
    }
    
    @IBAction func willDeleteRole(_ sender: UIButton){
        let confirmDeleteController = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete the role?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { (alertAction) in
            let tasks = self.selectedRole!.contains!.allObjects as! [TaskMO]
            for task in tasks {
                self.center.removePendingNotificationRequests(withIdentifiers: [task.identifier!])
                self.center.removeDeliveredNotifications(withIdentifiers: [task.identifier!])
            }
            self.delegate?.editRoleView(self, willDeleteRole: self.selectedRole!)
        }
        let denyAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        confirmDeleteController.addAction(denyAction)
        confirmDeleteController.addAction(confirmAction)
        self.present(confirmDeleteController, animated: true, completion: nil)
    }
    
    // MARK: - Objective-C actions
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if nameTextField.text == nil || nameTextField.text!.isEmpty {
            self.presentErrorAlert("Invalid Role Name", withMessage: "Please write in a non-empty role name.", andButtonTitle: "Dismiss")
            nameTextField.text = selectedRole?.name
            return false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        selectedRole?.name = nameTextField.text
        dataManager.saveContext()
        
        let tasks = selectedRole!.contains!.allObjects as! [TaskMO]
        for task in tasks {
            center.removePendingNotificationRequests(withIdentifiers: [task.identifier!])
            center.removeDeliveredNotifications(withIdentifiers: [task.identifier!])
            if let date = task.alertDate {
                let alertContent = UNMutableNotificationContent()
                alertContent.title = "\(selectedRole!.name!) task"
                alertContent.body = task.name!
                alertContent.categoryIdentifier = "TASK"
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: date.components, repeats: false)
                let request = UNNotificationRequest(identifier: task.identifier!, content: alertContent, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                    if let theError = error {
                        print(theError.localizedDescription)
                    }
                })
            }
        }
    }
    
    // MARK: - UITextViewDelegate methods
    
    func textViewDidEndEditing(_ textView: UITextView) {
        selectedRole?.roleDescription = descriptionTextView.text
        dataManager.saveContext()
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

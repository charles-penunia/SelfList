//
//  AddTaskViewController.swift
//  SelfList
//
//  Created by Charles Penunia on 11/2/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

@objc protocol AddTaskViewDelegate {
    @objc optional func addTaskViewWillExit(_ sender: AddTaskViewController)
    @objc optional func addTaskView(_ sender: AddTaskViewController, didAddTask task: TaskMO)
}

class AddTaskViewController: UIViewController, UITextFieldDelegate, PickerDataSourceConfigurer, AddRoleViewDelegate {
    
    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var roleTextField: PickerTextField!
    @IBOutlet weak var alertTextField: PickerTextField!
    @IBOutlet weak var prioritySlider: UISlider!
    
    let alertPickerToolbar = UIToolbar()
    let rolePickerTollbar = UIToolbar()
    let datePickerView = UIDatePicker()
    let rolePickerView = UIPickerView()
    
    var selectedRole: RoleMO?
    var selectedDate: Date?
    var selectedPickerRow: Int = 0
    var selectedPickerComponent: Int = 0
    var delegate: AddTaskViewDelegate?
    
    let dataManager = DataManager.sharedInstance
    lazy var pickerDataSource = PickerDataSource(entity: "Role", sortKeys: ["name"], predicate: nil, sectionNameKeyPath: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.tintColor = defaultTintColor
        
        // Do any additional setup after loading the view.
        pickerDataSource.pickerView = rolePickerView
        rolePickerView.dataSource = pickerDataSource
        rolePickerView.delegate = pickerDataSource
        
        pickerDataSource.delegate = self
        
        datePickerView.datePickerMode = .dateAndTime
        datePickerView.minuteInterval = minuteInterval
        datePickerView.setMinimumDateRoundedUpByMinuteInterval()
        datePickerView.addTarget(self, action: #selector(AddTaskViewController.datePickerValueDidChange(_:)), for: UIControlEvents.valueChanged)
        
        let clearAlertButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddTaskViewController.clearAlert(_:)))
        let clearRoleButon = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddTaskViewController.clearRole(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneAlertButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddTaskViewController.updateAlertDate(_:)))
        let doneRoleButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(AddTaskViewController.finishedEditing(_:)))
        
        alertPickerToolbar.items = [clearAlertButton, flexSpace, doneAlertButton]
        alertPickerToolbar.sizeToFit()
        rolePickerTollbar.items = [clearRoleButon, flexSpace, doneRoleButton]
        rolePickerTollbar.sizeToFit()
        
        roleTextField.inputView = rolePickerView
        roleTextField.inputAccessoryView = rolePickerTollbar
        roleTextField.delegate = self
        roleTextField.tintColor = UIColor.clear
        roleTextField.selectedTextRange = nil
        
        alertTextField.inputView = datePickerView
        alertTextField.inputAccessoryView = alertPickerToolbar
        alertTextField.delegate = self
        alertTextField.tintColor = UIColor.clear
        alertTextField.selectedTextRange = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Interface Builder actions
    
    @IBAction func finishedEditing(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func addTask(_ sender: UIButton) {
        if taskTextField.text!.isEmpty || roleTextField.text!.isEmpty {
            self.presentErrorAlert("Add Task Failed", withMessage: "Please fill out the task and role.", andButtonTitle: "Dismiss")
            return
        }
        let newTask = NSEntityDescription.insertNewObject(forEntityName: "Task", into: dataManager.managedObjectContext) as! TaskMO
        newTask.name = taskTextField.text
        newTask.groupedIn = selectedRole
        newTask.startDate = Date()
        newTask.alertDate = selectedDate
        newTask.priority = prioritySlider.value
        newTask.identifier = UUID().uuidString
        newTask.updateDynamicPriority()
        dataManager.saveContext()
        
        if let date = selectedDate {
            let alertContent = UNMutableNotificationContent()
            alertContent.title = "\(selectedRole!.name!) task"
            alertContent.body = newTask.name!
            alertContent.categoryIdentifier = "TASK"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: date.components, repeats: false)
            let request = UNNotificationRequest(identifier: newTask.identifier!, content: alertContent, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            })
        }
        delegate?.addTaskViewWillExit?(self)
    }
    
    // MARK: - Objective-C actions
    
    @objc func datePickerValueDidChange(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        alertTextField.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func clearAlert(_ sender: Any) {
        alertTextField.text = nil
        selectedDate = nil
        finishedEditing(alertTextField)
    }
    
    @objc func clearRole(_ sender: Any) {
        roleTextField.text = nil
        selectedRole = nil
        finishedEditing(roleTextField)
    }
    
    @objc func updateAlertDate(_ sender: Any) {
        selectedDate = datePickerView.date
        finishedEditing(alertTextField)
    }
    
    // MARK: - UITextFieldDelegate methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if pickerDataSource.isEmpty {
            self.presentErrorAlert("No Roles Stored", withMessage: "Please add a role through the Add Role button.", andButtonTitle: "OK")
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        switch textField {
        case alertTextField:
            datePickerView.setMinimumDateRoundedUpByMinuteInterval()
            datePickerValueDidChange(datePickerView)
        case roleTextField:
            rolePickerView.selectRow(selectedPickerRow, inComponent: selectedPickerComponent, animated: true)
            let indexPath = IndexPath(row: selectedPickerRow, section: selectedPickerComponent)
            let defaultObject = pickerDataSource.fetchedResultsController.object(at: indexPath) as! RoleMO
            selectedRole = defaultObject
            roleTextField.text = defaultObject.name
        default:
            break
        }
    }
    
    // MARK: - PickerDataSourceConfigurer methods
    
    func rowTitleForPickerObject(_ object: NSManagedObject) -> String? {
        let role = object as! RoleMO
        return role.name
    }
    
    func pickerViewDidSelectObject(_ object: NSManagedObject, atRow row: Int, andComponent component: Int) {
        let role = object as! RoleMO
        roleTextField.text = role.name
        selectedRole = role
        selectedPickerRow = row
        selectedPickerComponent = component
    }
    
    // MARK: - AddRoleViewDelegate methods
    
    func addRoleViewWillExit(_ sender: AddRoleViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
    func addRoleView(_ sender: AddRoleViewController, didAddRole role: RoleMO) {
        roleTextField.text = role.name
        selectedRole = role
        let indexPath = pickerDataSource.fetchedResultsController.indexPath(forObject: role)
        selectedPickerComponent = indexPath!.section
        selectedPickerRow = indexPath!.row
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier! {
        case "AddTaskToAddRole":
            let navigationViewController = segue.destination as! UINavigationController
            let addRoleViewController = navigationViewController.viewControllers[0] as! AddRoleViewController
            addRoleViewController.delegate = self
        default:
            break
        }
    }
    

}

//
//  TaskDetailViewController.swift
//  SelfList
//
//  Created by Charles Penunia on 11/12/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

protocol TaskDetailViewDelegate {
    func taskDetailView(_ sender: TaskDetailViewController, willDeleteTask task: TaskMO)
    func taskDetailViewWillExit(_ sender: TaskDetailViewController)
}

class TaskDetailViewController: UIViewController, UITextFieldDelegate, PickerDataSourceConfigurer {

    @IBOutlet weak var taskTextField: UITextField!
    @IBOutlet weak var roleTextField: PickerTextField!
    @IBOutlet weak var alertTextField: PickerTextField!
    @IBOutlet weak var prioritySlider: UISlider!
    
    let alertPickerToolbar = UIToolbar()
    let rolePickerTollbar = UIToolbar()
    let datePickerView = UIDatePicker()
    let rolePickerView = UIPickerView()
    let center = UNUserNotificationCenter.current()
    
    var selectedTask: TaskMO?
    var selectedRole: RoleMO?
    var selectedDate: Date?
    var selectedPickerRow: Int = 0
    var selectedPickerComponent: Int = 0
    var delegate: TaskDetailViewDelegate?
    
    let dataManager = DataManager.sharedInstance
    lazy var pickerDataSource = PickerDataSource(entity: "Role", sortKeys: ["name"], predicate: nil, sectionNameKeyPath: nil)
    
    func configure(selectedTask task: TaskMO) {
        selectedTask = task
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.tintColor = defaultTintColor
        
        // Do any additional setup after loading the view.
        taskTextField.text = selectedTask!.name
        roleTextField.text = selectedTask!.groupedIn!.name
        prioritySlider.value = selectedTask!.dynamicPriority
        
        let indexPath = pickerDataSource.fetchedResultsController.indexPath(forObject: selectedTask!.groupedIn!)
        selectedPickerRow = indexPath!.row
        selectedPickerComponent = indexPath!.section
        
        selectedRole = selectedTask!.groupedIn
        
        pickerDataSource.pickerView = rolePickerView
        rolePickerView.dataSource = pickerDataSource
        rolePickerView.delegate = pickerDataSource
        
        pickerDataSource.delegate = self
        
        datePickerView.datePickerMode = .dateAndTime
        datePickerView.minuteInterval = minuteInterval
        datePickerView.setMinimumDateRoundedUpByMinuteInterval()
        datePickerView.addTarget(self, action: #selector(TaskDetailViewController.datePickerValueDidChange(_:)), for: UIControlEvents.valueChanged)
        
        selectedDate = selectedTask!.alertDate
        if let currentDate = selectedTask!.alertDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            alertTextField.text = dateFormatter.string(from: currentDate)
            
            datePickerView.date = currentDate
        }
        
        let clearAlertButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(TaskDetailViewController.clearAlert(_:)))
        let clearRoleButon = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(TaskDetailViewController.undoRoleChange(_:)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneAlertButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(TaskDetailViewController.updateAlertDate(_:)))
        let doneRoleButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(TaskDetailViewController.updateRole(_:)))
        
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
    
    @IBAction func cancelEditingTask(_ sender: UIBarButtonItem) {
        delegate?.taskDetailViewWillExit(self)
    }
    
    @IBAction func updateTask(_ sender: UIButton) {
        selectedTask!.name = taskTextField.text
        selectedTask!.alertDate = selectedDate
        selectedTask!.startDate = Date()
        selectedTask!.priority = prioritySlider.value
        selectedTask!.groupedIn = selectedRole
        selectedTask!.updateDynamicPriority()
        dataManager.saveContext()
        
        center.removePendingNotificationRequests(withIdentifiers: [selectedTask!.identifier!])
        center.removeDeliveredNotifications(withIdentifiers: [selectedTask!.identifier!])
        if let date = selectedDate {
            let alertContent = UNMutableNotificationContent()
            alertContent.title = "\(selectedRole!.name!) task"
            alertContent.body = selectedTask!.name!
            alertContent.categoryIdentifier = "TASK"
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: date.components, repeats: false)
            let request = UNNotificationRequest(identifier: selectedTask!.identifier!, content: alertContent, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
                if let theError = error {
                    print(theError.localizedDescription)
                }
            })
        }
        delegate?.taskDetailViewWillExit(self)
    }
    
    @IBAction func deleteTask(_ sender: UIButton) {
        let confirmDeleteController = UIAlertController(title: "Confirm Delete", message: "Are you sure you want to delete the task?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Yes", style: .destructive) { (alertAction) in
            self.center.removePendingNotificationRequests(withIdentifiers: [self.selectedTask!.identifier!])
            self.center.removeDeliveredNotifications(withIdentifiers: [self.selectedTask!.identifier!])
            self.delegate?.taskDetailView(self, willDeleteTask: self.selectedTask!)
        }
        let denyAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        confirmDeleteController.addAction(denyAction)
        confirmDeleteController.addAction(confirmAction)
        self.present(confirmDeleteController, animated: true, completion: nil)
    }
    
    // MARK: - Objective-C actions
    
    @objc func datePickerValueDidChange(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let shownDate = max(sender.minimumDate!, sender.date)
        alertTextField.text = dateFormatter.string(from: shownDate)
    }
    
    @objc func undoRoleChange(_ sender: Any) {
        roleTextField.text = selectedRole!.name
        let oldIndexPath = pickerDataSource.fetchedResultsController.indexPath(forObject: selectedRole!)!
        selectedPickerRow = oldIndexPath.row
        selectedPickerComponent = oldIndexPath.section
        finishedEditing(roleTextField)
    }
    
    @objc func clearAlert(_ sender: Any) {
        alertTextField.text = nil
        selectedDate = nil
        finishedEditing(alertTextField)
    }
    
    @objc func updateRole(_ sender: Any) {
        let indexPath = IndexPath(row: selectedPickerRow, section: selectedPickerComponent)
        selectedRole = pickerDataSource.fetchedResultsController.object(at: indexPath) as? RoleMO
        finishedEditing(roleTextField)
    }
    
    @objc func updateAlertDate(_ sender: Any) {
        selectedDate = max(datePickerView.date, datePickerView.minimumDate!)
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
            roleTextField.text = defaultObject.name
        default:
            break
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if taskTextField.text == nil {
            self.presentErrorAlert("Invalid Task Name", withMessage: "Please write in a non-empty task name.", andButtonTitle: "Dismiss")
            taskTextField.text = selectedTask!.name
            return false
        }
        return true
    }
    
    // MARK: - PickerDataSourceConfigurer methods
    
    func rowTitleForPickerObject(_ object: NSManagedObject) -> String? {
        let role = object as! RoleMO
        return role.name
    }
    
    func pickerViewDidSelectObject(_ object: NSManagedObject, atRow row: Int, andComponent component: Int) {
        let role = object as! RoleMO
        roleTextField.text = role.name
        selectedPickerRow = row
        selectedPickerComponent = component
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

//
//  ListTableViewController.swift
//  SelfList
//
//  Created by Charles Penunia on 11/11/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class ListTableViewController: UITableViewController, DataSourceCellConfigurer, TaskDetailViewDelegate {
    
    let reuseIdentifier = "TaskCell"
    let noRoleReuseIdentifier = "TaskWithoutRoleCell"
    let duration: TimeInterval = 2.0
    let taskCellHeight: CGFloat = 80.0
    let taskWithoutRoleCellHeight: CGFloat = 56.0
    
    var refresher = UIRefreshControl()
    var selectedTask: TaskMO?
    var selectedRole: RoleMO?
    var predicate: NSPredicate?
    let center = UNUserNotificationCenter.current()
    
    var shouldShowRoles = true
    
    let dataManager = DataManager.sharedInstance
    lazy var dataSource = DataSource(entity: "Task", sortKeys: ["dynamicPriority", "startDate", "groupedIn"], predicate: predicate, sectionNameKeyPath: nil)
    
    func configure(selectedRole role: RoleMO?, showRoles willShowRoles: Bool) {
        shouldShowRoles = willShowRoles
        selectedRole = role
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.tintColor = defaultTintColor
        
        refresher.tintColor = defaultTintColor
        refresher.backgroundColor = UIColor.white
        refresher.attributedTitle = NSAttributedString(string: "Pull to clear")
        refresher.addTarget(self, action: #selector(ListTableViewController.refreshList(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            self.tableView.refreshControl = refresher
        } else {
            self.tableView.addSubview(refresher)
        }
        
        dataSource.delegate = self
        dataSource.tableView = self.tableView
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let role = selectedRole {
            if let name = role.name {
                self.title = name
            } else {
               self.navigationController!.popViewController(animated: true)
            }
        }
        dataSource.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Objective-C actions
    
    @objc func refreshList(_ sender: Any) {
        updateDynamicPriorities()
        let objects = dataSource.fetchedResultsController.fetchedObjects as! [TaskMO]
        for object in objects {
            if object.isCompleted {
                center.removePendingNotificationRequests(withIdentifiers: [object.identifier!])
                center.removeDeliveredNotifications(withIdentifiers: [object.identifier!])
                dataManager.managedObjectContext.delete(object)
            }
        }
        dataManager.saveContext()
        refresher.endRefreshing()
    }
    
    // MARK: - UITableViewDelegate methods
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        selectedTask = dataSource.fetchedResultsController.object(at: indexPath) as? TaskMO
        self.performSegue(withIdentifier: "ViewTaskDetail", sender: self)
    }

    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    // MARK: - DataSourceCellConfigurer methods
    
    func configureCell(_ cell: UITableViewCell, withObject object: NSManagedObject) {
        let task = object as! TaskMO
        if shouldShowRoles {
            let taskCell = cell as! TaskTableViewCell
            taskCell.taskLabel.text = task.name
            taskCell.roleLabel.text = task.groupedIn?.name
            taskCell.initializeCheckbox(withTask: task)
        }
        else {
            let taskCell = cell as! TaskWithoutRoleTableViewCell
            taskCell.taskLabel.text = task.name
            taskCell.initializeCheckbox(withTask: task)
        }
    }
    
    func cellIdentifierForObject(_ object: NSManagedObject) -> String {
        return shouldShowRoles ? reuseIdentifier : noRoleReuseIdentifier
    }
    
    // MARK: - TaskDetailViewDelegate methods
    
    func taskDetailViewWillExit(_ sender: TaskDetailViewController) {
        updateDynamicPriorities()
        sender.dismiss(animated: true, completion: nil)
    }
    
    func taskDetailView(_ sender: TaskDetailViewController, willDeleteTask task: TaskMO) {
        updateDynamicPriorities()
        sender.dismiss(animated: true) {
            self.dataManager.managedObjectContext.delete(task)
            self.dataManager.saveContext()
        }
    }
    
    // MARK: - Helper functions
    
    func updateDynamicPriorities() {
        let objects = dataSource.fetchedResultsController.fetchedObjects as! [TaskMO]
        for object in objects {
            object.updateDynamicPriority()
        }
        dataManager.saveContext()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier! {
        case "ViewTaskDetail":
            let navigationViewController = segue.destination as! UINavigationController
            let taskDetailViewController = navigationViewController.viewControllers[0] as! TaskDetailViewController
            taskDetailViewController.configure(selectedTask: selectedTask!)
            taskDetailViewController.delegate = self
        default:
            break
        }
    }
}

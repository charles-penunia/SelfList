//
//  ManageRolesTableViewController.swift
//  SelfList
//
//  Created by Charles Penunia on 12/8/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit
import CoreData

class ManageRolesTableViewController: UITableViewController, DataSourceCellConfigurer, AddRoleViewDelegate, EditRoleViewDelegate {
    let reuseIdentifier = "EditRoleCell"
    var selectedRole: RoleMO?
    
    let dataManager = DataManager.sharedInstance
    lazy var dataSource = DataSource(entity: "Role", sortKeys: ["name"], predicate: nil, sectionNameKeyPath: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.tintColor = defaultTintColor
        
        dataSource.delegate = self
        dataSource.tableView = self.tableView
        self.tableView.dataSource = dataSource
        self.tableView.delegate = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - DataSourceCellConfigurer methods
    
    func configureCell(_ cell: UITableViewCell, withObject object: NSManagedObject) {
        let role = object as! RoleMO
        cell.textLabel?.text = role.name
    }
    
    func cellIdentifierForObject(_ object: NSManagedObject) -> String {
        return reuseIdentifier
    }
    
    // MARK: - AddRoleViewDelegate methods
    
    func addRoleViewWillExit(_ sender: AddRoleViewController) {
        sender.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - EditRoleViewDelegate methods
    
    func editRoleView(_ sender: EditRoleViewController, willDeleteRole role: RoleMO) {
        self.navigationController?.popViewController(animated: true)
        dataManager.managedObjectContext.delete(role)
        dataManager.saveContext()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier! {
        case "EditRole":
            let editRoleViewController = segue.destination as! EditRoleViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            selectedRole = dataSource.fetchedResultsController.object(at: selectedIndexPath) as? RoleMO
            editRoleViewController.delegate = self
            editRoleViewController.configure(selectedRole: selectedRole!)
        case "AddRoleFromTable":
            let navigationViewController = segue.destination as! UINavigationController
            let addRoleViewController = navigationViewController.viewControllers[0] as! AddRoleViewController
            addRoleViewController.delegate = self
        default:
            break
        }
    }

}

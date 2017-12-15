//
//  RoleTableViewController.swift
//  SelfList
//
//  Created by Charles Penunia on 11/11/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit
import CoreData

class RoleTableViewController: UITableViewController, DataSourceCellConfigurer {
    let reuseIdentifier = "RoleCell"
    var selectedRole: RoleMO?
    
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

    // MARK: - UITableViewDelegate methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRole = dataSource.fetchedResultsController.object(at: indexPath) as? RoleMO
        self.performSegue(withIdentifier: "ViewTasksFromRole", sender: self)
    }
    
    // MARK: - DataSourceCellConfigurer methods
    
    func configureCell(_ cell: UITableViewCell, withObject object: NSManagedObject) {
        let role = object as! RoleMO
        cell.textLabel?.text = role.name
    }
    
    func cellIdentifierForObject(_ object: NSManagedObject) -> String {
        return reuseIdentifier
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        switch segue.identifier! {
        case "ViewTasksFromRole":
            let listViewController = segue.destination as! ListTableViewController
            listViewController.predicate = NSPredicate(format: "groupedIn.name == %@", selectedRole!.name!)
            listViewController.title = selectedRole!.name
            listViewController.configure(selectedRole: selectedRole, showRoles: false)
        default:
            break
        }
    }
    

}

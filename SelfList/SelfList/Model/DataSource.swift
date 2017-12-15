//
//  DataSource.swift
//  SelfList
//
//  Created by Charles Penunia on 11/11/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//  Code is from Dr. John Hannan

import Foundation
import UIKit
import CoreData

protocol DataSourceCellConfigurer {
    func configureCell(_ cell: UITableViewCell, withObject object: NSManagedObject)
    func cellIdentifierForObject(_ object: NSManagedObject) -> String
}

class DataSource: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    let dataManager = DataManager.sharedInstance
    var delegate: DataSourceCellConfigurer?
    var tableView: UITableView! {
        didSet {
            fetchedResultsController.delegate = self
        }
    }
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult>
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    
    init (entity: String, sortKeys:[String], predicate: NSPredicate?, sectionNameKeyPath: String?) {
        let sortDescriptors: [NSSortDescriptor] = {
            let descendingSortDescriptors = ["dynamicPriority"]
            var _sortDescriptors = [NSSortDescriptor]()
            for key in sortKeys {
                var descriptor: NSSortDescriptor
                if descendingSortDescriptors.contains(key) {
                    descriptor = NSSortDescriptor(key: key, ascending: false)
                } else {
                    descriptor = NSSortDescriptor(key: key, ascending: true)
                }
                _sortDescriptors.append(descriptor)
            }
            return _sortDescriptors
        }()
        
        fetchRequest = NSFetchRequest(entityName: entity)
        fetchRequest.sortDescriptors = sortDescriptors
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataManager.managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            let nsError = error as NSError
            print("Unresolved error: \(String(describing: nsError)), \(nsError.userInfo)")
        }
    }
    
    // MARK: - Table View
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = fetchedResultsController.object(at: indexPath) as! NSManagedObject
        let identifier = delegate!.cellIdentifierForObject(event)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        delegate?.configureCell(cell, withObject: event)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath) as! NSManagedObject)
            
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Fetched results controller delegate methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            if let cell = tableView.cellForRow(at: indexPath!) {
                delegate?.configureCell(cell, withObject: anObject as! NSManagedObject)
            }
        case .move:
            if let cell = tableView.cellForRow(at: indexPath!) {
                delegate?.configureCell(cell, withObject: anObject as! NSManagedObject)
            }
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

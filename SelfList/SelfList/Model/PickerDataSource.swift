//
//  PickerDataSource.swift
//  SelfList
//
//  Created by Charles Penunia on 11/11/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol PickerDataSourceConfigurer {
    func rowTitleForPickerObject(_ object: NSManagedObject) -> String?
    func pickerViewDidSelectObject(_ object: NSManagedObject, atRow row: Int, andComponent component: Int)
}

class PickerDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate, NSFetchedResultsControllerDelegate {
    
    let dataManager = DataManager.sharedInstance
    var delegate: PickerDataSourceConfigurer?
    var pickerView: UIPickerView! {
        didSet {
            fetchedResultsController.delegate = self
        }
    }
    var isEmpty: Bool
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult>
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>
    
    init (entity: String, sortKeys:[String], predicate: NSPredicate?, sectionNameKeyPath: String?) {
        let sortDescriptors: [NSSortDescriptor] = {
            var _sortDescriptors = [NSSortDescriptor]()
            for key in sortKeys {
                let descriptor = NSSortDescriptor(key: key, ascending: true)
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
            let count = try dataManager.managedObjectContext.count(for: fetchRequest)
            isEmpty = count > 0 ? false : true
        } catch {
            isEmpty = true
            let nsError = error as NSError
            print("Unresolved error: \(String(describing: nsError)), \(nsError.userInfo)")
        }
    }
    
    // MARK: - Picker view data source methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let section = fetchedResultsController.sections {
            return section[component].numberOfObjects
        }
        return 0
    }
    
    // MARK: - Picker view delegate methods
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let indexPath = IndexPath(row: row, section: component)
        let object = fetchedResultsController.object(at: indexPath) as! NSManagedObject
        return delegate?.rowTitleForPickerObject(object)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPath = IndexPath(row: row, section: component)
        let object = fetchedResultsController.object(at: indexPath) as! NSManagedObject
        delegate?.pickerViewDidSelectObject(object, atRow: row, andComponent: component)
    }
    
    // MARK: - Fetched results controller delegate methods
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        do {
            let count = try dataManager.managedObjectContext.count(for: fetchRequest)
            isEmpty = count > 0 ? false : true
        } catch {
            isEmpty = true
            let nsError = error as NSError
            print("Unresolved error: \(String(describing: nsError)), \(nsError.userInfo)")
        }
        pickerView.reloadAllComponents()
    }
    
}

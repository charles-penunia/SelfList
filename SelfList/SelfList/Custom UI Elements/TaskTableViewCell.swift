//
//  TaskTableViewCell.swift
//  SelfList
//
//  Created by Charles Penunia on 11/12/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit
import CoreData

let dataManager = DataManager.sharedInstance

class TaskTableViewCell: UITableViewCell {

    let checkedImage = UIImage(named: "icons8-checked-checkbox")
    let uncheckedImage = UIImage(named: "icons8-unchecked-checkbox")
    var task: TaskMO?
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var checkboxButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initializeCheckbox(withTask newTask: TaskMO) {
        task = newTask
        if task!.isCompleted {
            checkboxButton.setImage(checkedImage, for: .normal)
            taskLabel.attributedText = NSAttributedString(string: taskLabel.text!, attributes: [NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleSingle.rawValue])
            roleLabel.attributedText = NSAttributedString(string: roleLabel.text!, attributes: [NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleSingle.rawValue])
        }
        else {
            checkboxButton.setImage(uncheckedImage, for: .normal)
            taskLabel.attributedText = NSAttributedString(string: taskLabel.text!, attributes: [NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleNone.rawValue])
            roleLabel.attributedText = NSAttributedString(string: roleLabel.text!, attributes: [NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleNone.rawValue])
        }
    }
    
    @IBAction func toggleCheckmark(_ sender: UIButton) {
        task!.isCompleted = !(task!.isCompleted)
        dataManager.saveContext()
    }
    

}

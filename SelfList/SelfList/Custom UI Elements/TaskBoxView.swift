//
//  TaskBoxView.swift
//  SelfList
//
//  Created by Charles Penunia on 12/5/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit

class TaskBoxView: UIView {

    @IBOutlet weak var checkboxButton: UIButton!
    @IBOutlet weak var taskLabel: UILabel!
    
    let checkedImage = UIImage(named: "icons8-checked-checkbox")
    let uncheckedImage = UIImage(named: "icons8-unchecked-checkbox")
    var task: TaskMO?
    
    class func instanceFromNib() -> TaskBoxView {
        let nib = UINib(nibName: "TaskBoxView", bundle: nil)
        return nib.instantiate(withOwner: nil, options: nil)[0] as! TaskBoxView
    }
    
    func initializeCheckbox(withTask newTask: TaskMO) {
        task = newTask
        if task!.isCompleted {
            checkboxButton.setImage(checkedImage, for: .normal)
            taskLabel.attributedText = NSAttributedString(string: taskLabel.text!, attributes: [NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleSingle.rawValue])
        }
        else {
            checkboxButton.setImage(uncheckedImage, for: .normal)
            taskLabel.attributedText = NSAttributedString(string: taskLabel.text!, attributes: [NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleNone.rawValue])
        }
    }
    
    @IBAction func toggleCheckBox(_ sender: Any) {
        task!.isCompleted = !(task!.isCompleted)
        initializeCheckbox(withTask: task!)
        dataManager.saveContext()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    

}

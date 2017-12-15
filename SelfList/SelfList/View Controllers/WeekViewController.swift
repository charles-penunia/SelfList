//
//  WeekViewController.swift
//  SelfList
//
//  Created by Charles Penunia on 12/4/17.
//  Copyright © 2017 Charles Penunia. All rights reserved.
//

import UIKit
import CoreData

class WeekViewController: UIViewController {

    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var currentWeekLabel: UILabel!
    
    let numberOfColumns = 7
    let borderWidth: CGFloat = 0.5
    let columnWidth: CGFloat = 175.0
    let dayHeaderHeight: CGFloat = 60.0
    let taskboxHeight: CGFloat = 175.0
    
    let taskboxSize: CGSize
    let dateLabels: [UILabel]
    var subScrollViews: [UIScrollView] = [UIScrollView]()
    
    var firstDay: Date
    let currentCalendar = Calendar.current
    let dateFormatter = DateFormatter()
    let formatStringTemplate = "MMdd"
    
    var fetchedTasks: [TaskMO]
    let dataManager = DataManager.sharedInstance
    
    required init?(coder aDecoder: NSCoder) {
        firstDay = Date().getFirstDayOfWeek()
        dateFormatter.calendar = currentCalendar
        dateFormatter.setLocalizedDateFormatFromTemplate(formatStringTemplate)
        
        fetchedTasks = [TaskMO]()
        
        let dateLabelSize = CGSize(width: columnWidth, height: dayHeaderHeight)
        var _dateLabels = [UILabel]()
        for i in 0..<numberOfColumns {
            let dateLabelPoint = CGPoint(x: columnWidth * CGFloat(i), y: 0.0)
            let dateLabelFrame = CGRect(origin: dateLabelPoint, size: dateLabelSize)
            let dateLabel = UILabel(frame: dateLabelFrame)
            
            dateLabel.textAlignment = .center
            
            dateLabel.backgroundColor = UIColor.white
            dateLabel.layer.borderColor = UIColor.black.cgColor
            dateLabel.layer.borderWidth = borderWidth
            
            _dateLabels.append(dateLabel)
        }
        dateLabels = _dateLabels
        taskboxSize = CGSize(width: columnWidth, height: taskboxHeight)
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainScrollView.contentSize.width = CGFloat(numberOfColumns) * columnWidth
        let minimumScrollHeight = mainScrollView.frame.size.height - dayHeaderHeight
        let scrollViewSize = CGSize(width: columnWidth, height: minimumScrollHeight)
        for i in 0..<numberOfColumns {
            let point = CGPoint(x: columnWidth * CGFloat(i), y: dayHeaderHeight)
            let scrollViewFrame = CGRect(origin: point, size: scrollViewSize)
            let scrollView = UIScrollView(frame: scrollViewFrame)
            scrollView.contentSize = scrollViewSize
            scrollView.backgroundColor = UIColor.white
            scrollView.layer.borderColor = UIColor.black.cgColor
            scrollView.layer.borderWidth = borderWidth
            
            subScrollViews.append(scrollView)
            mainScrollView.addSubview(subScrollViews.last!)
        }
        for label in dateLabels {
            mainScrollView.addSubview(label)
        }
        fixScrollOffset()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        updateWeekView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Interface builder actions
    
    @IBAction func loadPreviousWeek(_ sender: Any) {
        firstDay = firstDay.getDate(byAddingWeek: -1)
        updateWeekView()
    }
    
    @IBAction func loadNextWeek(_ sender: Any) {
        firstDay = firstDay.getDate(byAddingWeek: 1)
        updateWeekView()
    }
    
    
    @IBAction func loadCurrentWeek(_ sender: Any) {
        firstDay = Date().getFirstDayOfWeek()
        fixScrollOffset()
        updateWeekView()
    }
    
    // MARK: - Helper functions
    
    func updateWeekView() {
        let lastDay = firstDay.getDate(byAddingDay: 6)
        currentWeekLabel.text = "\(dateFormatter.string(from: firstDay)) - \(dateFormatter.string(from: lastDay))"
        let nextWeekDay = firstDay.getDate(byAddingWeek: 1)
        
        for i in 0..<numberOfColumns {
            let currentDate = firstDay.getDate(byAddingDay: i)
            let dayOfWeek = currentCalendar.shortWeekdaySymbols[i]
            let day = currentCalendar.component(.day, from: currentDate)
            dateLabels[i].text = "\(dayOfWeek) \(day)"
        }
        
        let fetchRequest = NSFetchRequest<TaskMO>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "(alertDate >= %@ && alertDate < %@) || (alertDate == nil && startDate >= %@ && startDate < %@)", argumentArray: [firstDay, nextWeekDay, firstDay, nextWeekDay])
        do {
            fetchedTasks = try dataManager.managedObjectContext.fetch(fetchRequest).sorted(by: { (task1, task2) -> Bool in
                if task1.alertDate != nil && task2.alertDate != nil {
                    return task1.alertDate! <= task2.alertDate!
                }
                // Either task1.alertDate or task2.alertDate is nil
                if let task1Alert = task1.alertDate {
                    return task1Alert <= task2.startDate!
                }
                if let task2Alert = task2.alertDate {
                    return task1.startDate! <= task2Alert
                }
                return task1.startDate! <= task2.startDate!
            })
            loadTasks()
        } catch {
            let nsError = error as NSError
            print("Unresolved error: \(String(describing: nsError)), \(nsError.userInfo)")
        }
    }
    
    func loadTasks() {
        let minimumScrollHeight = mainScrollView.frame.size.height - dayHeaderHeight
        clearTaskBoxes()
        for i in 0..<numberOfColumns {
            let startTime = firstDay.getDate(byAddingDay: i)
            let endTime = startTime.getDate(byAddingDay: 1)
            let taskArray = fetchedTasks.filter({ (task) -> Bool in
                var compareDate = task.startDate!
                if let taskAlert = task.alertDate {
                    compareDate = taskAlert
                }
                return compareDate >= startTime && compareDate < endTime
            })
            let taskBoxesHeight = CGFloat(taskArray.count) * taskboxHeight
            let newScrollHeight = max(minimumScrollHeight, taskBoxesHeight)
            subScrollViews[i].contentSize.height = newScrollHeight
            for j in 0..<taskArray.count {
                let point = CGPoint(x: 0.0, y: taskboxHeight * CGFloat(j))
                let frame = CGRect(origin: point, size: taskboxSize)
                
                let task = taskArray[j]
                let taskBox = TaskBoxView.instanceFromNib()
                taskBox.frame = frame
                taskBox.taskLabel.text = task.name
                taskBox.initializeCheckbox(withTask: task)
                taskBox.backgroundColor = task.groupedIn!.color as? UIColor
                taskBox.layer.borderColor = UIColor.black.cgColor
                taskBox.layer.borderWidth = borderWidth
                subScrollViews[i].addSubview(taskBox)
            }
        }
    }
    
    func clearTaskBoxes() {
        for scrollView in subScrollViews {
            for subView in scrollView.subviews {
                if subView is TaskBoxView {
                    subView.removeFromSuperview()
                }
            }
        }
    }
    
    func fixScrollOffset() {
        let columnNumber = currentCalendar.component(.weekday, from: Date()) - 1
        let defaultXOffset = CGFloat(columnNumber) * columnWidth
        let maxXOffset = mainScrollView.contentSize.width - mainScrollView.frame.size.width
        mainScrollView.contentOffset.x = min(defaultXOffset, maxXOffset)
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

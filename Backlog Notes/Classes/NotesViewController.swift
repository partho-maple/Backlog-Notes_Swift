import UIKit
import Foundation


class NotesViewController: UITableViewController, AddItemViewControllerDelegate {

    
    var items: NSMutableArray?
    var itemDatesUnsorted: NSMutableArray?
    var itemDatesSorted: NSMutableArray?
    var tableDataSections: NSMutableArray = []
    var tableDataSectionsDict: CHOrderedDictionary?
    var tableDataSectionsDictKeyOrder: NSMutableOrderedSet?

    
    
    func documentsDirectory() -> String {
        var paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory: String = paths[0] as! String
        return documentsDirectory
    }

    
    func dataFilePath() -> String {
        return (self.documentsDirectory() as NSString).stringByAppendingPathComponent("Notes.plist")
    }

    
    func saveChecklistItems() {
        let data: NSMutableData = NSMutableData()
        let archiver: NSKeyedArchiver = NSKeyedArchiver(forWritingWithMutableData: data)
        archiver.encodeObject(items, forKey: "ChecklistItems")
        archiver.finishEncoding()
        data.writeToFile(self.dataFilePath(), atomically: true)
    }

    
    func loadChecklistItems() {
        let path: String = self.dataFilePath()
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            let data: NSData = NSData(contentsOfFile: path)!
            let unarchiver: NSKeyedUnarchiver = NSKeyedUnarchiver(forReadingWithData: data)
            items = unarchiver.decodeObjectForKey("ChecklistItems") as? NSMutableArray
            unarchiver.finishDecoding()
        }
        else {
            items = NSMutableArray(capacity: 20)
        }
        let sortDescriptor: NSSortDescriptor = NSSortDescriptor(key: "dueDate", ascending: false)
        let sortedArray: NSArray = items!.sortedArrayUsingDescriptors([sortDescriptor])
        items = sortedArray as? NSMutableArray

        self.sortTableDateToIndecesByDateWith(items! as NSMutableArray)
    }

    
    func sortTableDateToIndecesByDateWith(listItems: NSMutableArray) {
        tableDataSectionsDict = CHOrderedDictionary()
        tableDataSectionsDictKeyOrder = NSMutableOrderedSet()
        let cal: NSCalendar = NSCalendar.currentCalendar()
        let unitFlags: NSCalendarUnit = [.Hour, .Minute, .Second]
        var components: NSDateComponents = cal.components(unitFlags, fromDate: NSDate())
        components.timeZone = NSTimeZone.defaultTimeZone()
        let df: NSDateFormatter = NSDateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let now: NSDate = NSDate()
        components.hour = -components.hour
        components.minute = -components.minute
        components.second = -components.second
        let today: NSDate = cal.dateByAddingComponents(components, toDate: NSDate(), options: NSCalendarOptions(rawValue: 0))!
        //    This variable should now be pointing at a date object that is the start of today (midnight);
        components.hour = -24
        components.minute = 0
        components.second = 0
        let unitFlags2: NSCalendarUnit = [.Year, .Month, .Weekday, .Day]
        let yesterday: NSDate = cal.dateByAddingComponents(components, toDate: today, options: NSCalendarOptions(rawValue: 0))!
        components = cal.components(unitFlags2, fromDate: NSDate())
        components.day = (components.day - (components.weekday - 1))
        let thisWeek: NSDate = cal.dateFromComponents(components)!
        components.day = (components.day - 7)
        let lastWeek: NSDate = cal.dateFromComponents(components)!
        components.day = (components.day - 7)
        let twoWeeksAgo: NSDate = cal.dateFromComponents(components)!
        components.day = (components.day - (components.day - 1))
        let thisMonth: NSDate = cal.dateFromComponents(components)!
        components.month = (components.month - 1)
        let lastMonth: NSDate = cal.dateFromComponents(components)!
        components.month = (components.month - 1)
        let twoMonthsAgo: NSDate = cal.dateFromComponents(components)!
        
        var TodayArray: [AnyObject] = NSMutableArray() as [AnyObject]
        var YesterdayArray: [AnyObject] = NSMutableArray() as [AnyObject]
        var ThisWeekArray: [AnyObject] = NSMutableArray() as [AnyObject]
        var LastWeekArray: [AnyObject] = NSMutableArray() as [AnyObject]
        var TwoWeeksAgoArray: [AnyObject] = NSMutableArray() as [AnyObject]
        var ThisMonthArray: [AnyObject] = NSMutableArray() as [AnyObject]
        var LastMonthArray: [AnyObject] = NSMutableArray() as [AnyObject]
        var TwoMonthsAgoArray: [AnyObject] = NSMutableArray() as [AnyObject]
        var LongAgoArray: [AnyObject] = NSMutableArray() as [AnyObject]
        var AllTimeArray: [AnyObject] = NSMutableArray() as [AnyObject]
        
        for i in 0 ..< items!.count {
            var item: ChecklistItem = items![i] as! ChecklistItem
            var addingDate: NSDate = item.dueDate
            var count = UInt(tableDataSectionsDict!.count)
            if NotesViewController.date(addingDate, isBetweenDate: today, andDate: now) {
                TodayArray.append(item)
                
                let containsKey = tableDataSectionsDict!.allKeys.contains { return $0 as? String == "Today" }
                if !containsKey {
                    tableDataSectionsDict!.insertObject(TodayArray, forKey: "Today", atIndex: count)
                }
                
            }
            else if NotesViewController.date(addingDate, isBetweenDate: yesterday, andDate: today) {
                YesterdayArray.append(item)
                
                let containsKey = tableDataSectionsDict!.allKeys.contains { return $0 as? String == "Yesterday" }
                if !containsKey {
                    tableDataSectionsDict!.insertObject(YesterdayArray, forKey: "Yesterday", atIndex: count)
                }
                
            }
            else if NotesViewController.date(addingDate, isBetweenDate: thisWeek, andDate: yesterday) {
                ThisWeekArray.append(item)
                
                let containsKey = tableDataSectionsDict!.allKeys.contains { return $0 as? String == "This Week" }
                if !containsKey {
                    tableDataSectionsDict!.insertObject(ThisWeekArray, forKey: "This Week", atIndex: count)
                }
                
            }
            else if NotesViewController.date(addingDate, isBetweenDate: lastWeek, andDate: thisWeek) {
                LastWeekArray.append(item)
                
                let containsKey = tableDataSectionsDict!.allKeys.contains { return $0 as? String == "Last Week" }
                if !containsKey {
                    tableDataSectionsDict!.insertObject(LastWeekArray, forKey: "Last Week", atIndex: count)
                }
 
            }
            else if NotesViewController.date(addingDate, isBetweenDate: twoWeeksAgo, andDate: lastWeek) {
                TwoWeeksAgoArray.append(item)
                
                let containsKey = tableDataSectionsDict!.allKeys.contains { return $0 as? String == "Two Weeks Ago" }
                if !containsKey {
                    tableDataSectionsDict!.insertObject(TwoWeeksAgoArray, forKey: "Two Weeks Ago", atIndex: count)
                }

            }
            else if NotesViewController.date(addingDate, isBetweenDate: thisMonth, andDate: twoWeeksAgo) {
                ThisMonthArray.append(item)
                
                let containsKey = tableDataSectionsDict!.allKeys.contains { return $0 as? String == "This Month" }
                if !containsKey {
                    tableDataSectionsDict!.insertObject(ThisMonthArray, forKey: "This Month", atIndex: count)
                }

            }
            else if NotesViewController.date(addingDate, isBetweenDate: lastMonth, andDate: thisMonth) {
                LastMonthArray.append(item)
                
                let containsKey = tableDataSectionsDict!.allKeys.contains { return $0 as? String == "Last Month" }
                if !containsKey {
                    tableDataSectionsDict!.insertObject(LastMonthArray, forKey: "Last Month", atIndex: count)
                }

            }
            else if NotesViewController.date(addingDate, isBetweenDate: twoMonthsAgo, andDate: lastMonth) {
                TwoMonthsAgoArray.append(item)
                
                let containsKey = tableDataSectionsDict!.allKeys.contains { return $0 as? String == "Two Months Ago" }
                if !containsKey {
                    tableDataSectionsDict!.insertObject(TwoMonthsAgoArray, forKey: "Two Months Ago", atIndex: count)
                }

            }
            else {
                LongAgoArray.append(item)
                
                let containsKey = tableDataSectionsDict!.allKeys.contains { return $0 as? String == "Long Ago" }
                if !containsKey {
                    tableDataSectionsDict!.insertObject(LongAgoArray, forKey: "Long Ago", atIndex: count)
                }

            }
        }
        
    }

    
    func getIndexOf(c: String, Into string: String) -> Int {
        for var i = 0; i < string.length; i += 1 {
            if c.characterAtIndex(0) == string.characterAtIndex(i) {
                return i
            }
        }
        return -1
    }

    
    class func date(date: NSDate, isBetweenDate beginDate: NSDate, andDate endDate: NSDate) -> Bool {
        if date.compare(beginDate) == NSOrderedAscending {
            return false
        }
        if date.compare(endDate) == NSOrderedDescending {
            return false
        }
        return true
    }

    
    func configureTextForCell(cell: UITableViewCell, withChecklistItem item: ChecklistItem) {
        var notesLabel: UILabel = (cell.viewWithTag(1500) as! UILabel)
        var rangeOfString: NSRange = item.notes.rangeOfString(".")
        if rangeOfString.location == NSNotFound {
            // error condition — the text searchKeyword wasn't in 'string'
            notesLabel.text = item.notes
        }
        else {
            notesLabel.text = item.notes.substringToIndex((rangeOfString.location + 1))
        }
        if item.shouldRemind == true {
            var dueDateLabel: UILabel = (cell.viewWithTag(1600) as! UILabel)
            var formatter: NSDateFormatter = NSDateFormatter()
            formatter.dateStyle = NSDateFormatterShortStyle
            formatter.timeStyle = NSDateFormatterShortStyle
            dueDateLabel.text = formatter.stringFromDate(item.dueDate)
        }
        else {
            var dueDateLabel: UILabel = (cell.viewWithTag(1600) as! UILabel)
            dueDateLabel.text = nil
        }
    }

    
    func refresh() {
        self.performSegueWithIdentifier("AddItem", sender: self)
        self.refreshControl!.endRefreshing()
    }

    
    override func customizeAppearance() {
        ///table view background with our own custom image
        //    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blue-background.png"]];
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: TableSectionHeaderTextColorYellow]
        ///initialize pull to refresh control
        self.refreshControl!.addTarget(self, action: #selector(NotesViewController.refresh), forControlEvents: .ValueChanged)
        /// configure left navigation bar button item as edit button. This edit button has a mechanism of changing its title to "Done" when it pressed
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.tableView.reloadData()
        self.navigationController!.navigationBar.barTintColor = NavBarBackgroundColor
        self.navigationController!.navigationBar.translucent = false
        self.tableView.separatorColor = UIColor.clearColor()
        UITableViewHeaderFooterView.appearance().tintColor = NavBarBackgroundColor
            // Create the colors
        let lightOp: UIColor = backgroundColorGradientTop
        let darkOp: UIColor = backgroundColorGradientBottom
            // Create the gradient
        let gradient: CAGradientLayer = CAGradientLayer.layer()
        // Set colors
        gradient.colors = [(lightOp.CGColor as AnyObject), (darkOp.CGColor as AnyObject)]
        // Set bounds
        gradient.frame = self.view.bounds
        let gradientImage: UIImage = self.imageFromLayer(gradient)
        let worldBGImage: UIImage = UIImage(named: "blue-background.png")!
        let size: CGSize = CGSizeMake(gradientImage.size.width, gradientImage.size.height)
        worldBGImage.drawInRect(CGRectMake(0, 0, size.width, size.height))
        gradientImage.drawInRect(CGRectMake(0, 0, size.width, size.height))
            //    [worldBGImage drawInRect:CGRectMake(0,0,size.width, size.height)];
        let finalImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.tableView.backgroundView = UIImageView(image: finalImage)
    }
    

    convenience required init(coder aDecoder: NSCoder) {
        if (self.init(coder: aDecoder)) {
            self.loadChecklistItems()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.customizeAppearance()
    }

    
    func imageFromLayer(layer: CALayer) -> UIImage {
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let outputImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage
    }

    
    @IBAction func accessoryButtonTapped(sender: AnyObject, event: AnyObject) {
        var touches: Set<AnyObject> = event.allTouches()
        var touch: UITouch = touches.first!
        var currentTouchPosition: CGPoint = touch.locationInView(self.tableView)
        var indexPath: NSIndexPath = self.tableView(forRowAtPoint: currentTouchPosition)
        if indexPath != nil {
            self.tableView(self.tableView, accessoryButtonTappedForRowWithIndexPath: indexPath)
        }
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableDataSectionsDict!.count
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var keys: [AnyObject] = tableDataSectionsDict!.allKeys
        let aKey: String = keys[section] as! String
        let eventsOnThisDay: [AnyObject] = (tableDataSectionsDict![aKey] as! [AnyObject])
        return eventsOnThisDay.count
    }

    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String {
        var keys: [AnyObject] = tableDataSectionsDict!.allKeys
        let aKey: String = keys[section] as! String
        return aKey
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("ChecklistItem")!
            //    ChecklistItem *item = [items objectAtIndex:indexPath.row];
            //    [self configureTextForCell:cell withChecklistItem:item];
        var keys: [AnyObject] = tableDataSectionsDict!.allKeys
        let aKey: String = keys[indexPath.section] as! String
            //    NSDate *dateRepresentingThisDay = [items objectAtIndex:indexPath.section];
        var eventsOnThisDay: [AnyObject] = (tableDataSectionsDict![aKey] as! [AnyObject])
        let item: ChecklistItem = eventsOnThisDay[indexPath.row] as! ChecklistItem
        self.configureTextForCell(cell, withChecklistItem: item)
        return cell
    }
    

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var keys: [AnyObject] = tableDataSectionsDict!.allKeys
        var aKey: String = keys[indexPath.section] as! String
        var eventsOnThisDay: [AnyObject] = (tableDataSectionsDict![aKey] as! [AnyObject])
        var item: ChecklistItem = eventsOnThisDay[indexPath.row] as! ChecklistItem
        for i in 0 ..< items!.count {
            var itemToDelete: ChecklistItem = items![i] as! ChecklistItem
            if item.dueDate.isEqualToDate(itemToDelete.dueDate) {

                items.removeAtIndex(i)
            }
        }
        self.saveChecklistItems()
        self.loadChecklistItems()

        self.tableView.reloadData()
    }

    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        var objectToMove: AnyObject = items![fromIndexPath.row]
        items.removeAtIndex(fromIndexPath.row)
        items!.insertObject(objectToMove, atIndex: toIndexPath.row)
        tableView.reloadData()
        self.saveChecklistItems()
    }
    

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let tempView: UIView = UIView(frame: CGRectMake(0, 200, 300, 244))
        tempView.backgroundColor = NavBarBackgroundColor
        let tempLabel: UILabel = UILabel(frame: CGRectMake(15, 0, 300, 20))
        tempLabel.backgroundColor = UIColor.clearColor()
        //    tempLabel.shadowColor = [UIColor blackColor];
        //    tempLabel.shadowOffset = CGSizeMake(0,2);
        tempLabel.textColor = TableSectionHeaderTextColorYellow
        var keys: [AnyObject] = tableDataSectionsDict!.allKeys
        let aKey: String = keys[section] as! String
        tempLabel.text = aKey
        // probably from array
        tempView.addSubview(tempLabel)
        return tempView
    }

    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = TableCellBackgroundColor
        self.tableView.separatorStyle = .None
    }


    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 53
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var keys: [AnyObject] = tableDataSectionsDict!.allKeys
        let aKey: String = keys[indexPath.section] as! String
        var eventsOnThisDay: [AnyObject] = (tableDataSectionsDict![aKey] as! [AnyObject])
        let item: ChecklistItem = eventsOnThisDay[indexPath.row] as! ChecklistItem
        self.performSegueWithIdentifier("EditItem", sender: item)
    }

    

    override func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
        var keys: [AnyObject] = tableDataSectionsDict!.allKeys
        let aKey: String = keys[indexPath.section] as! String
        var eventsOnThisDay: [AnyObject] = (tableDataSectionsDict![aKey] as! [AnyObject])
        let item: ChecklistItem = eventsOnThisDay[indexPath.row] as! ChecklistItem
        self.performSegueWithIdentifier("EditItem", sender: item)
    }


    func addItemViewControllerDidCancel(controller: AddNoteViewController) {
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }

    
    func addItemViewController(controller: AddNoteViewController, didFinishAddingItem item: ChecklistItem) {
        let newRowIndex: Int = items!.count
        self.items.append(item)
        self.saveChecklistItems()
        self.loadChecklistItems()
        let indexPath: NSIndexPath = NSIndexPath(forRow: newRowIndex, inSection: 0)
        var indexPaths: [AnyObject] = [indexPath]
        self.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }

    
    func addItemViewController(controller: AddNoteViewController, didFinishEditingItem item: ChecklistItem) {
        let index: Int = items!.indexOfObject(item)
        let indexPath: NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
        let cell: UITableViewCell = self.tableView.cellForRowAtIndexPath(indexPath)!
        self.configureTextForCell(cell, withChecklistItem: item)
        self.saveChecklistItems()
        self.loadChecklistItems()
        self.tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: { _ in })
    }


    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        if (segue.identifier == "AddItem") {
            let navigationController: UINavigationController = segue.destinationViewController
            let controller: AddNoteViewController = (navigationController.topViewController as! AddNoteViewController)
            controller.delegate = self
        }
        else if (segue.identifier == "EditItem") {
            let navigationController: UINavigationController = segue.destinationViewController
            let controller: AddNoteViewController = (navigationController.topViewController as! AddNoteViewController)
            controller.delegate = self
            controller.itemToEdit = sender as! ChecklistItem
        }

    }
}
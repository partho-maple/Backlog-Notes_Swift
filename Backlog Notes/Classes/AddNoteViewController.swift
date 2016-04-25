import UIKit


protocol AddItemViewControllerDelegate {
    ///This method declares when user tap on the cancel button, it will dismiss the addnote view controller presenting without saving the data
    func addItemViewControllerDidCancel(controller: AddNoteViewController)
    ///This method pass the relevant "added" information such as notes, whether to remind to checklistview controller

    func addItemViewController(controller: AddNoteViewController, didFinishAddingItem item: ChecklistItem)
    ///This method pass the relevant "edited" information such as task, notes, whether to remind to checklistview controller

    func addItemViewController(controller: AddNoteViewController, didFinishEditingItem item: ChecklistItem)
}
/// confirm that textfield, datpicker and actionsheet delegates to self
class AddNoteViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate {
    /// textField is a field where user key in the task information. 
    //@property (strong, nonatomic) IBOutlet UITextField *textField;
    /// notesField is a field where user key in the additional information.
    @IBOutlet var notesField: UITextView!
    /// We create doneBarButton as IBOutlet so that we can disable the done button if the text field is empty.
    //@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneBarButton;
    ///confirms delegate method
    var delegate: AddItemViewControllerDelegate
    ///We declare itemtoedit method to display information for user to edit 
    var itemToEdit: ChecklistItem {
        get {
            return self.itemToEdit
        }
        set(newItem) {
            if itemToEdit != newItem {
                itemToEdit = newItem
                notes = itemToEdit.notes
                shouldRemind = itemToEdit.shouldRemind
                dueDate = itemToEdit.dueDate
            }
        }
    }

    ///this is the notification time which user selects
    @IBOutlet var dueDateLabel: UILabel!
    ///This outlet will be only enables if the notes is editing mode
    @IBOutlet var shareButton: UIBarButtonItem!
    ///When the user tap on the share button we bring up this activity controller
    var activityViewController: UIActivityViewController
    ///create IBActions
    ///We create cancel IBAction. when user tap on cancel button, we dismiss the presenting view controller by calling AddItemViewControllerDelegate using delegate method
    
    required init?(coder aDecoder: NSCoder) {
        
    }

    @IBAction func cancel() {
        self.delegate.addItemViewControllerDidCancel(self)
    }
    ///We create done IBAction. when user tap done button, we dismiss the presenting view controller by calling didFinishAddingItem using delegate method which will pass the added/edited information to checklistviewcontroller

    @IBAction func done() {
        if (self.notesField.text! == " ") || (self.notesField.text! == "") {
            var message: UIAlertView = UIAlertView(title: "Empty !!!", message: "Note is empty. Click OK to write again, or Cancel to dismiss.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
            message.tag = emptyNoteAlertViewsTag
            message.show()
        }
        else {
            if self.itemToEdit == "" {
                var item: ChecklistItem = ChecklistItem()
                item.notes = self.notesField.text!
                item.shouldRemind = true
                item.dueDate = dueDate
                //        Shows the notification on the given date
                //        [item scheduleNotification];
                self.delegate.addItemViewController(self, didFinishAddingItem: item)
            }
            else {
                self.itemToEdit.notes = self.notesField.text!
                self.itemToEdit.shouldRemind = true
                self.itemToEdit.dueDate = dueDate
                //        Shows the notification on the given date
                //        [self.itemToEdit scheduleNotification];
                self.delegate.addItemViewController(self, didFinishEditingItem: self.itemToEdit)
            }
        }
    }
    ///We create share button for user to tap to share the notes

    @IBAction func shareButtonClicked(sender: AnyObject) {
        let emailBody: String = notesField.text!
        self.activityViewController = UIActivityViewController(activityItems: [emailBody], applicationActivities: nil)
        self.presentViewController(self.activityViewController, animated: true, completion: { _ in })
    }

    func customizeAppearance() {
        self.navigationController!.navigationBar.barTintColor = NavBarBackgroundColor
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: TableSectionHeaderTextColorYellow]
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
        //    [notesField setBackgroundColor:[UIColor clearColor]];
        notesField.backgroundColor = TableCellBackgroundColor
    }
    var notes: String
    var shouldRemind: Bool
    var dueDate: NSDate


    ///synthesize properties
    ///we display current date and time when we present the addnotevewcontroller to user

    convenience required init(coder a
        Decoder: NSCoder) {
        if (self.init(coder: aDecoder)) {
            notes = ""
            shouldRemind = true
            dueDate = NSDate()
        }
    }
    /// NSdate formetter to format date and update the label when user picked different date 

    func updateDueDateLabel() {
        var formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterShortStyle
        formatter.timeStyle = NSDateFormatterShortStyle
        self.dueDateLabel.text = formatter.stringFromDate(dueDate)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
            ///wecreate
        var doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(AddNoteViewController.done))
        var shareButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(AddNoteViewController.shareButtonClicked(_:)))
        self.navigationItem.rightBarButtonItems = [doneButton, shareButton]
        ///we check whether it is editing mode or adding mode, then set the title and fields appropriately.
        if self.itemToEdit != nil {
            self.title = "Edit Note"
        }
        else {
            self.title = "Add Note"
        }
        self.notesField.text = notes
        self.updateDueDateLabel()
        shareButton.enabled = true
        //    Sets the TextView delegate
        self.notesField.delegate = self
        self.customizeAppearance()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.title != NSLocalizedString("Edit Note") {
            self.notesField.becomeFirstResponder()
            self.notesField.resignFirstResponder()
            //        [self.notesField becomeFirstResponder];
        }
        else {
            self.notesField.resignFirstResponder()
        }
    }
    /// method to call addItemViewControllerDidCancel method when cancel button pressed
    /// method to call didFinishAddingItem method when Done button pressed
    ///optionally we can dismiss keyboard if the user starts to scroll the tableview

    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.notesField.resignFirstResponder()
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            cell.backgroundColor = TableCellBackgroundColor
        }
        else {

        }
    }
    ///to prevent the uitableview cell turns blue when user taps on it

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath {
        if indexPath.row == 0 {
            return indexPath
        }
        else {
            return nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    ///release te memory by setting nil to these fields as we no loner need them

    override func viewDidUnload() {
        self.notesField = nil
        self.dueDateLabel = nil
        super.viewDidUnload()
    }
    ///we present stored item if the user editing an item
    ///we use prepare for segue method to display date picker controller

    func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
    }

    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == emptyNoteAlertViewsTag {
            if buttonIndex == alertView.cancelButtonIndex {
                    // Cancel was tapped
                self.dismissViewControllerAnimated(true, completion: { _ in })
            }
            else if buttonIndex == alertView.firstOtherButtonIndex {
                    // The other button was tapped
            }
        }
    }

    func textViewDidBeginEditing(textView: UITextView) {
        //    self.notesField.frame.origin.y = self.navigationController.navigationBar.frame.origin.y + self.dueDateLabel.frame.origin.y;
        //    [self.notesField setFrame:CGRectMake(0, (self.navigationController.navigationBar.frame.origin.y + self.dueDateLabel.frame.origin.y), 320.0, 500)];
    }

    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return true
    }

    func imageFromLayer(layer: CALayer) -> UIImage {
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let outputImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return outputImage
    }
}
let emptyNoteAlertViewsTag = 0
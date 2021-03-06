import UIKit
import QuartzCore


let emptyNoteAlertViewsTag = 0


protocol AddItemViewControllerDelegate {
    func addItemViewControllerDidCancel(controller: AddNoteViewController)
    func addItemViewController(controller: AddNoteViewController, didFinishAddingItem item: ChecklistItem)
    func addItemViewController(controller: AddNoteViewController, didFinishEditingItem item: ChecklistItem)
}


class AddNoteViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIAlertViewDelegate {

    @IBOutlet var notesField: UITextView!

    var notes: String = ""
    var shouldRemind: Bool = false
    var dueDate: NSDate = NSDate()
    var delegate: AddItemViewControllerDelegate! // Question here
    var itemToEdit: ChecklistItem {
        get {
            return self.itemToEdit
        }
        set(newItem) {
            if itemToEdit != newItem {
                self.itemToEdit = newItem
                notes = itemToEdit.notes
                shouldRemind = itemToEdit.shouldRemind
                dueDate = itemToEdit.dueDate
            }
        }
    }
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var shareButton: UIBarButtonItem!
    var activityViewController: UIActivityViewController!
    

    convenience required init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        notes = ""
        shouldRemind = true
        dueDate = NSDate()
    }


    @IBAction func cancel() {
        self.delegate.addItemViewControllerDidCancel(self)
    }

    @IBAction func done() {
        if (self.notesField.text! == " ") || (self.notesField.text! == "") {
            let message: UIAlertView = UIAlertView(title: "Empty !!!", message: "Note is empty. Click OK to write again, or Cancel to dismiss.", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
            message.tag = emptyNoteAlertViewsTag
            message.show()
        }
        else {
            if self.itemToEdit == "" {
                let item: ChecklistItem = ChecklistItem()
                item.notes = self.notesField.text!
                item.shouldRemind = true
                item.dueDate = dueDate
                self.delegate.addItemViewController(self, didFinishAddingItem: item)
            }
            else {
                self.itemToEdit.notes = self.notesField.text!
                self.itemToEdit.shouldRemind = true
                self.itemToEdit.dueDate = dueDate
                self.delegate.addItemViewController(self, didFinishEditingItem: self.itemToEdit)
            }
        }
    }

    
    @IBAction func shareButtonClicked(sender: AnyObject) {
        let emailBody: String = notesField.text!
        self.activityViewController = UIActivityViewController(activityItems: [emailBody], applicationActivities: nil)
        self.presentViewController(self.activityViewController, animated: true, completion: { _ in })
    }

    func customizeAppearance() {
        self.navigationController!.navigationBar.barTintColor = NavBarBackgroundColor
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: TableSectionHeaderTextColorYellow]
        let lightOp: UIColor = backgroundColorGradientTop
        let darkOp: UIColor = backgroundColorGradientBottom
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [(lightOp.CGColor as AnyObject), (darkOp.CGColor as AnyObject)]
        gradient.frame = self.view.bounds
        let gradientImage: UIImage = self.imageFromLayer(gradient)
        let worldBGImage: UIImage = UIImage(named: "blue-background.png")!
        let size: CGSize = CGSizeMake(gradientImage.size.width, gradientImage.size.height)
        worldBGImage.drawInRect(CGRectMake(0, 0, size.width, size.height))
        gradientImage.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let finalImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.tableView.backgroundView = UIImageView(image: finalImage)
        notesField.backgroundColor = TableCellBackgroundColor
    }
    

    func updateDueDateLabel() {
        let formatter: NSDateFormatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        formatter.timeStyle = NSDateFormatterStyle.ShortStyle
        self.dueDateLabel.text = formatter.stringFromDate(dueDate)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
            ///wecreate
        let doneButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(AddNoteViewController.done))
        let shareButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(AddNoteViewController.shareButtonClicked(_:)))
        self.navigationItem.rightBarButtonItems = [doneButton, shareButton]

        if self.itemToEdit.itemId != 0 {
            self.title = "Edit Note"
        }
        else {
            self.title = "Add Note"
        }
        self.notesField.text = notes
        self.updateDueDateLabel()
        shareButton.enabled = true
        self.notesField.delegate = self
        self.customizeAppearance()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if self.title != "Edit Note" {
            self.notesField.becomeFirstResponder()
            self.notesField.resignFirstResponder()
        }
        else {
            self.notesField.resignFirstResponder()
        }
    }

    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.notesField.resignFirstResponder()
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            cell.backgroundColor = TableCellBackgroundColor
        }
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row == 0 {
            return indexPath
        } else {
            return nil;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.tag == emptyNoteAlertViewsTag {
            if buttonIndex == alertView.cancelButtonIndex {
                self.dismissViewControllerAnimated(true, completion: { _ in })
            }
            else if buttonIndex == alertView.firstOtherButtonIndex {
                    // The other button was tapped
            }
        }
    }

    func textViewDidBeginEditing(textView: UITextView) {

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





import Foundation
import UIKit
import Swift


class ChecklistItem: NSObject, NSCoding {

    var notes: String = ""
    var dueDate: NSDate = NSDate()
    var shouldRemind: Bool = false
    var itemId: Int = 0
    
    
    convenience required init(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        
        self.notes = aDecoder.decodeObjectForKey("Notes") as! String
        self.dueDate = aDecoder.decodeObjectForKey("DueDate") as! NSDate
        self.shouldRemind = aDecoder.decodeBoolForKey("ShouldRemind")
        self.itemId = Int(aDecoder.decodeIntForKey("ItemID"))
    }


    func scheduleNotification() {
        var existingNotification: UILocalNotification = self.notificationForThisItem()!
        UIApplication.sharedApplication().cancelLocalNotification(self.notificationForThisItem()!)
        
        if self.shouldRemind && self.dueDate.compare(NSDate()) != NSComparisonResult.OrderedAscending {
            let localNotification: UILocalNotification = UILocalNotification()
            localNotification.fireDate = self.dueDate
            localNotification.timeZone = NSTimeZone.defaultTimeZone()
            localNotification.alertBody = self.notes
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.userInfo = [
                "ItemID" : Int(self.itemId)
            ]

            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
            NSLog("Scheduled notification %@ for itemId %d", localNotification, self.itemId)
        }
    }

    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.notes, forKey: "Notes")
        aCoder.encodeObject(self.dueDate, forKey: "DueDate")
        aCoder.encodeBool(self.shouldRemind, forKey: "ShouldRemind")
        aCoder.encodeInt(Int32(self.itemId), forKey: "ItemID")
    }

    override init() {
        self.itemId = DataModel.nextChecklistItemId()
    }

    func notificationForThisItem() -> UILocalNotification? {
        let allNotifications: [UILocalNotification] = UIApplication.sharedApplication().scheduledLocalNotifications!
        for notification: UILocalNotification in allNotifications {
            let number: Int = (notification.userInfo!["ItemID"] as! Int)
            if number == self.itemId {
                return notification
            }
        }
        return nil
    }

    deinit {
        let existingNotification: UILocalNotification = self.notificationForThisItem()!
        UIApplication.sharedApplication().cancelLocalNotification(existingNotification)
    }
}





